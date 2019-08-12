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
      Rapture::LOGGER.info("HTTP") { "-> #{env[:method].upcase} /#{env[:url]}" }
      Rapture::LOGGER.debug("HTTP") do
        str = "-> #{env[:method].upcase} #{env[:url]}"
        str += " body: #{Oj.generate(env[:body])}"
        str += " headers: #{Oj.generate(env[:request_headers])}"
        str
      end
    end

    # @!visibility private
    def log_response(url, env)
      Rapture::LOGGER.info("HTTP") { "<- #{url} (#{env[:status]})" }
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

  # @!visibility private
  # Lock a rate limit mutex preemptively if the next request would deplete the bucket.
  def preemptive_rl_wait(key, rl)
    if rl.will_be_rate_limited?
      log_ratelimit_lock(key, rl)
      rl.sleep_until_reset
    end
  end

  # @!visibility private
  # Handle a HTTP response based on the status code
  def handle_http_response(rl, response)
    rl.headers = response.headers
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

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(key, major_param, method, endpoint, body = nil, headers = {})
    @rate_limits ||= Hash.new { |hash, key| hash[key] = RateLimit.new }
    key = [key, major_param].freeze

    begin
      rl = @rate_limits[key]
      preemptive_rl_wait(key, rl)
      preemptive_rl_wait(:global, @rate_limits[:global])

      resp = faraday.run_request(method, endpoint, body, headers)
      handle_http_response(rl, resp)
    rescue Rapture::TooManyRequests => ex
      rl = @rate_limits[:global] if resp.headers["x-ratelimit-global"]
      log_too_many_requests(rl == global_rl ? :global : key, ex.retry_after)
      rl.sleep_for ex.retry_after
      retry
    end
  end

  # @!visibility private
  def log_ratelimit_lock(key, rl)
    time = Time.at(rl.reset_time) - Time.now
    key_name = (key == :global) ? "global" : key.join("_")
    Rapture::LOGGER.info("HTTP") do
      "[RATELIMIT] Preemptively locking %s mutex for %.2f seconds." % [key_name, time]
    end
  end

  # @!visibility private
  def log_too_many_requests(key, retry_after)
    key_name = (key == :global) ? "global" : key.join("_")
    Rapture::LOGGER.info("HTTP") do
      "[RATELIMIT] You are being ratelimited. Locking %s mutex for %.2f seconds" % [key_name, retry_after]
    end
  end
end
