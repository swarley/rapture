# frozen_string_literal: true

require 'faraday'

# Module containing Faraday and HTTP "wetworks"
module Rapture::HTTP
  # Base URL to Discord's API for all requests
  BASE_URL = 'https://discordapp.com/api/v6'

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

      faraday.response :logger do |logger|
        logger.filter(/Authorization: .*/, "Authorization: #{@type} REDACTED")
      end

      faraday.use RateLimiter

      faraday.headers['User-Agent'] = user_agent

      faraday.adapter Faraday.default_adapter
    end
  end

  # Middleware for processing rate limiting across all requests.
  class RateLimiter < Faraday::Middleware
    def call(env)
      # Pre-processing here

      @app.call(env).on_complete do |response_env|
        # Post-processing here
      end
    end
  end

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(method, endpoint, body = nil, headers = {})
    faraday.run_request(method, endpoint, body, headers)
  end
end
