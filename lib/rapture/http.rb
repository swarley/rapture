# frozen_string_literal: true

require "faraday_middleware"

# Module containing Faraday and HTTP "wetworks"
module Rapture::HTTP
  # Base URL to Discord's API for all requests
  BASE_URL = "https://discordapp.com/api/v7"

  # Yields the {BASE_URL} constant. Can be redefined to point at a custom
  # API location.
  def base_url
    BASE_URL
  end

  # Returns the required User-Agent string
  def user_agent
    "DiscordBot (https://github.com/swarley/rapture, #{Rapture::VERSION})"
  end

  private

  # Faraday client to issue all requests.
  def faraday
    @faraday ||= Faraday.new(url: base_url) do |faraday|
      faraday.authorization(@type, @token)

      # faraday.response :logger do |logger|
      #   logger.filter(/Authorization: .*/, "Authorization: #{@type} REDACTED")
      # end

      faraday.use RateLimiter

      faraday.request :multipart
      faraday.request :json

      faraday.headers["User-Agent"] = user_agent

      faraday.adapter Faraday.default_adapter
    end
  end

  # Class for tracking requests and their rate limits
  class RateLimit
    def initialize
      @mutex = Mutex.new
    end

    # Caches new headers
    def headers=(headers)
      @global = headers["x-ratelimit-global"]

      @limit = headers["x-ratelimit-limit"]&.to_i

      @remaining = headers["x-ratelimit-remaining"]&.to_i

      @now = Time.rfc2822(headers["date"])

      reset_time = headers["x-ratelimit-reset"]&.to_i
      @reset = Time.at(reset_time) if reset_time
    end

    # @return [true, false] if the next request would be rate limited
    def will_be_rate_limited?
      return false unless headers?
      return false if Time.now > @reset

      @remaining.zero?
    end

    # Locks the mutex until the reset time has elapsed
    def sleep_until_reset
      sleep_for @reset - @now
    end

    # Locks the mutex for the specified amount of time
    # @param time [Integer] amount of time to sleep during synchronization
    def sleep_for(time)
      @mutex.synchronize { sleep time }
    end

    private

    # Checks that we have enough data cached to perform
    # preemptive ratelimit checks
    def headers?
      @remaining && @now && @reset
    end
  end

  # Middleware for processing rate limiting across all requests.
  class RateLimiter < Faraday::Middleware
    # Exception to raise on a 429
    class TooManyRequests < RuntimeError
      include Rapture::Mapping

      # @!attribute [r] message
      # @return [String] Rate limit message
      getter :message

      # @!attribute [r] retry_after
      # @return [Integer] seconds until a retry can be performed
      getter :retry_after, from_json: proc { |v| v / 1000.0 }

      # @!attribute [r] global
      # @return [true, false] if this request exceeded the global rate limit
      getter :global
    end

    # Major parameters to consider
    MAJOR_PARAMETERS = %w[guilds channels webhooks].freeze

    # Returns the {RateLimit} for the givin `path`
    # @return [RateLimit]
    def ratelimit(method, path)
      key = parse_path(method, path)
      (@ratelimits ||= {})[key] ||= RateLimit.new
    end

    # Handle requests
    def call(env)
      # Preserve a copy of the original env
      original_env = env.dup

      rl = ratelimit(env.method, env.url.path)

      # Handle preemptive rate limiting
      rl.sleep_until_reset if rl.will_be_rate_limited?

      # Make the request, and update our cached rate limit headers
      # If we get a 429, sleep it off and retry
      @app.call(env).on_complete do |response|

        # Update our cached headers
        rl.headers = response[:response_headers]

        # Handle rate limiting
        if response[:status] == 429
          tmq = TooManyRequests.from_json(response[:body])
          rl.sleep_for tmq.retry_after
          @app.call(original_env)
        else
          response
        end
      end
    end

    private

    # Parses a URI path into the relevant component for rate limiting
    # @return [Symbol]
    def parse_path(method, path)
      route = path.split("/")[3..-1]

      if MAJOR_PARAMETERS.include? route[0]
        [method] + route.take(3)
      else
        [method] + route.take(1)
      end.join("_").to_sym
    end
  end

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(method, endpoint, body = nil, headers = {})
    log_request(method, endpoint, body, headers)
    resp = faraday.run_request(method, endpoint, body, headers)
    log_response(endpoint, resp)

    case resp.status
    when 200, 201, 204
      resp
    when 400..502
      ex = Rapture::HTTPException.from_json(resp.body)
      raise ex
    else
      LOGGER.warn("HTTP") { "Received an unknown response code: #{resp.status}" }
    end
  end

  # @!visibilty private
  def log_request(method, endpoint, body, headers)
    Rapture::LOGGER.info("HTTP") { "-> #{method.upcase} /#{endpoint}" }
    Rapture::LOGGER.debug("HTTP") do
      str = "-> #{method.upcase} /#{endpoint}"
      str += " body: #{Oj.generate(body)}"
      str += " headers: #{Oj.generate(headers)}"
      str
    end
  end

  # @!visibility private
  def log_response(endpoint, resp)
    Rapture::LOGGER.info("HTTP") { "<- /#{endpoint} (#{resp.status})" }
  end
end
