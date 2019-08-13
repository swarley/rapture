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

  class LoggerMiddleware < Faraday::Middleware
    # @!visibility private
    def log_request(env)
      Rapture::LOGGER.info("HTTP") { "-> #{env[:method].upcase} #{env[:url]}" }
      Rapture::LOGGER.debug("HTTP") do
        str = "-> #{env[:method].upcase} #{env[:url]}"
        str += "   body: #{Oj.generate(env[:body])}"
        str += "   headers: #{Oj.generate(env[:request_headers])}"
        str
      end
    end

    # @!visibility private
    def log_response(url, env)
      Rapture::LOGGER.info("HTTP") { "<- #{url} (#{env[:status]})" }
      # Debug log raw response?
    end

    def call(req_env)
      log_request(req_env)

      @app.call(req_env).on_complete do |resp_env|
        log_response(req_env[:url], resp_env)
      end
    end
  end

  # Faraday client to issue all requests.
  def faraday
    @faraday ||= Faraday.new(url: base_url) do |faraday|
      faraday.authorization(@type, @token)

      faraday.use LoggerMiddleware

      faraday.request :multipart
      faraday.request :json

      faraday.headers["User-Agent"] = user_agent
      faraday.headers["X-RateLimit-Precision"] = "millisecond"

      faraday.adapter Faraday.default_adapter
    end
  end

  # Class for tracking requests and their rate limits
  class RateLimit
    attr_reader :reset
    attr_reader :remaining
    attr_reader :limit

    def initialize
      @mutex = Mutex.new
    end

    # Caches new headers
    def headers=(headers)
      @global = headers["x-ratelimit-global"]

      @limit = headers["x-ratelimit-limit"]&.to_i

      @remaining = headers["x-ratelimit-remaining"]&.to_i

      @now = Time.rfc2822(headers["date"])

      reset_time = headers["x-ratelimit-reset"]&.to_f
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

    # Check to see if this limiter is currently being locked.
    def locked?
      @mutex.locked?
    end

    # Wait for this to limiter to become available again.
    def wait_for_unlock
      @mutex.lock
      @mutex.unlock
    end

    private

    # Checks that we have enough data cached to perform
    # preemptive ratelimit checks
    def headers?
      @remaining && @now && @reset
    end
  end

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(key, major_param, method, endpoint, body = nil, headers = {})
    @rate_limits ||= Hash.new { |hash, rl_key| hash[rl_key] = RateLimit.new }
    rl_key = [key, major_param].freeze
    body = Rapture.encode_json(body) if body

    begin
      run_request(rl_key, method, endpoint, body, headers)
    rescue Rapture::TooManyRequests => e
      limited_key = e.global ? :global : rl_key
      rl = @rate_limits[limited_key]

      log_too_many_requests(limited_key, e.retry_after)

      if rl.locked?
        rl.wait_for_unlock
      else
        @rate_limits[limited_key].sleep_for e.retry_after
      end

      retry
    end
  end

  # @!visibility private
  # Handle preemtive rate limiting, running the request, and logging the response
  def run_request(key, *args)
    rl = @rate_limits[key]
    preemptive_rl_wait(key)
    preemptive_rl_wait(:global)

    resp = faraday.run_request(*args)
    handle_http_response(rl, resp)
  end

  # @!visibility private
  # Lock a rate limit mutex preemptively if the next request would deplete the bucket.
  def preemptive_rl_wait(key)
    rate_limit = @rate_limits[key]
    return unless rate_limit.will_be_rate_limited?

    log_ratelimit_lock(key, rate_limit)
    rate_limit.sleep_until_reset
  end

  # @!visibility private
  # Handle a HTTP response based on the status code
  def handle_http_response(rate_limit, response)
    rate_limit.headers = response.headers
    @rate_limits[:global].headers = response.headers if response.headers["x-ratelimit-global"]

    case response.status
    when 200, 201, 204
      response
    when 429
      raise Rapture::TooManyRequests.from_json(response.body)
    when 400..502
      raise Rapture::HTTPException.from_json(response.body)
    else
      Rapture::LOGGER.warn("HTTP") { "Received an unknown response code: #{response.status}" }
    end
  end

  # @!visibility private
  def log_ratelimit_lock(key, rate_limit)
    time = rate_limit.reset - Time.now
    key_name = key == :global ? "global" : key.join("_")
    Rapture::LOGGER.info("HTTP") do
      "[RATELIMIT] Preemptively locking #{key_name} mutex for #{time.truncate(2)} seconds."
    end
  end

  # @!visibility private
  def log_too_many_requests(key, retry_after)
    key_name = key == :global ? "global" : key.join("_")
    Rapture::LOGGER.info("HTTP") do
      "[RATELIMIT] You are being ratelimited. Locking #{key_name} mutex for #{retry_after.truncate(2)} seconds."
    end
  end
end
