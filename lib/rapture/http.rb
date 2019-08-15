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

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(key, major_param, method, endpoint, body = nil, headers = {})
    @limiter ||= RateLimiter.new

    rl_key = [key, major_param].freeze
    body = Rapture.encode_json(body) if body

    begin
      run_request(rl_key, method, endpoint, body, headers)
    rescue Rapture::TooManyRequests => e
      limited_key = e.global ? :global : rl_key
      rl = @limiter.get_from_key(limited_key)

      log_too_many_requests(limited_key, e.retry_after)

      if rl.locked?
        rl.wait_until_available
      else
        rl.lock_for e.retry_after
      end

      retry
    end
  end

  # @!visibility private
  # Handle preemtive rate limiting, running the request, and logging the response
  def run_request(key, *args)
    preemptive_rl_wait(key)
    preemptive_rl_wait(:global)

    resp = faraday.run_request(*args)
    handle_http_response(key, resp)
  end

  # @!visibility private
  # Lock a rate limit mutex preemptively if the next request would deplete the bucket.
  def preemptive_rl_wait(key)
    return if (bucket = @limiter.get_from_key(key)).nil?

    bucket.wait_until_available
    return unless bucket&.will_limit?

    log_ratelimit_lock(key, bucket.reset_time - Time.now)
    bucket.lock_until_reset
  end

  # @!visibility private
  # Handle a HTTP response based on the status code
  def handle_http_response(key, response)
    @limiter.update_from_headers(key, response.headers)

    case response.status
    when 200, 201, 204
      response
    when 429
      @limiter.update_from_headers(:global, response.headers) if response.headers["x-ratelimit-global"]
      raise Rapture::TooManyRequests.from_json(response.body)
    when 400..502
      raise Rapture::HTTPException.from_json(response.body)
    else
      Rapture::LOGGER.warn("HTTP") { "Received an unknown response code: #{response.status}" }
    end
  end

  # @!visibility private
  def log_ratelimit_lock(key, reset)
    duration = reset.truncate(2)
    key_name = key == :global ? "global" : key.join("_")
    Rapture::LOGGER.info("HTTP") do
      "[RATELIMIT] Preemptively locking #{key_name} mutex for #{duration} seconds."
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
