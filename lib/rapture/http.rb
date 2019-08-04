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
    "DiscordBot (https://github.com/z64/rapture, #{Rapture::VERSION})"
  end

  # Faraday client to issue all requests.
  private def faraday
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

    # Checks that we have enough data cached to perform
    # preemptive ratelimit checks
    private def headers?
      @remaining && @now && @reset
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
    MAJOR_PARAMETERS = %w[guild_id channel_id webhook_id].freeze

    # Returns the {RateLimit} for the givin `path`
    # @return [RateLimit]
    def ratelimit(path)
      key = parse_path(path)
      (@ratelimits ||= {})[key] ||= RateLimit.new
    end

    # Parses a URI path into the relevant component for rate limiting
    # @return [Symbol]
    private def parse_path(path)
      parts = path.split("/")
      if MAJOR_PARAMETERS.include? parts[4]
        parts.take(5)
      else
        parts.take(4)
      end.join("_").to_sym
    end

    # Handle requests
    def call(env)
      # Preserve a copy of the original env
      original_env = env.dup

      rl = ratelimit(env.url.path)

      # Handle preemptive rate limiting
      rl.sleep_until_reset if rl.will_be_rate_limited?

      # Make the request, and update our cached rate limit headers
      # If we get a 429, sleep it off and retry
      response = @app.call(env)

      # Update our cached headers
      rl.headers = response.headers

      # Handle rate limiting
      if response.status == 429
        tmq = TooManyRequests.from_json(response.body)
        rl.sleep_for tmq.retry_after
        @app.call(original_env)
      else
        response
      end
    end
  end

  # Helper method for optional JSON body params. `nil` valued keys are
  # removed, and `:null` value keys serialize to JSON `null`.
  # @!visibility private
  def encode_json(object = {})
    object.delete_if { |_, v| v.nil? }
    object.each do |k, v|
      object[k] = nil if v == :null
    end
    Oj.dump(object)
  end

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(method, endpoint, body = nil, headers = {})
    resp = faraday.run_request(method, endpoint, body, headers)

    case resp.status
    when 200, 201, 204
      resp
    when 400..502
      raise Rapture::HTTPException.from_json(resp.body)
    else
      # @todo unknown response code
    end
  end
end
