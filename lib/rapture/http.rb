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

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(key, major_param, method, endpoint, body = nil, headers = {})
    @rate_limits ||= {}
    key = [key, major_param].freeze

    begin
      rl = (@rate_limits[key] ||= RateLimit.new)
      global_rl = (@rate_limits[:global] ||= RateLimit.new)

      if rl.will_be_rate_limited?
        Rapture::LOGGER.info("HTTP") do
          "[RATELIMIT] Preemtively locking mutex for #{key}"
        end
        rl.sleep_until_reset
      elsif global_rl.will_be_rate_limited?
        Rapture::LOGGER.info("HTTP") do
          "[RATELIMIT] Preemptively locking global mutex"
        end
        global_rl.sleep_until_reset
      end

      log_request(method, endpoint, body, headers)
      resp = faraday.run_request(method, endpoint, body, headers)
      log_response(endpoint, resp)

      rl.headers = resp.headers
      global_rl.headers = resp.headers if resp.headers["x-ratelimit-global"]
      case resp.status
      when 200, 201, 204
        resp
      when 429
        raise Rapture::TooManyRequests.from_json(resp.body)
      when 400..502
        raise Rapture::HTTPException.from_json(resp.body)
      else
        LOGGER.warn("HTTP") { "Received an unknown response code: #{resp.status}" }
      end
    rescue Rapture::TooManyRequests => ex
      rl = global_rl if resp.headers["x-ratelimit-global"]

      Rapture::LOGGER.info("HTTP") do
        if rl == global_rl
          "You are being ratelimited. Locking global mutex."
        else
          "You are being ratelimited. Locking #{key} mutex."
        end
      end

      rl.sleep_for ex.retry_after

      retry
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
