# frozen_string_literal: true

require 'faraday'

# Binding to Discord's HTTPS REST API
module Rapture::REST
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
        logger.filter(/Authorization: .*/, 'REDACTED')
      end

      faraday.headers['User-Agent'] = user_agent

      faraday.adapter Faraday.default_adapter
    end
  end

  # Makes a raw request to the API, without any rate limit handling
  def raw_request(method, endpoint, body = nil, headers = {})
    faraday.run_request(method, endpoint, body, headers)
  end

  # Makes a request to the API, applying handling for preemptive rate limits
  # and additional exception handling
  def request(method, endpoint, body = nil, headers = {})
    raw_request(method, endpoint, body, headers)
  end

  # Returns a {User} object for a given user ID.
  # https://discordapp.com/developers/docs/resources/user#get-user
  # @return [User]
  def get_user(id)
    response = request(:get, "users/#{id}")
    Rapture::User.from_json(response.body)
  end

  # Returns the {User} associated with the current authorization token.
  # https://discordapp.com/developers/docs/resources/user#get-current-user
  # @return [User]
  def get_current_user
    get_user('@me')
  end
end
