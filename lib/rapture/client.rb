require 'rapture/mappings/user'

module Rapture
  # The `Client` abstracts away the token from making REST API requests
  # and provides a means to connect to Discord's websocket.
  class Client
    include REST

    def initialize(token)
      @type, @token = token.split(' ')
      faraday
    end

    # Faraday client to issue all requests.
    private def faraday
      @faraday = Faraday.new(url: base_url) do |faraday|
        faraday.authorization(@type, @token)

        faraday.response :logger do |logger|
          logger.filter(/Authorization: .*/, 'REDACTED')
        end

        faraday.headers['User-Agent'] = "DiscordBot (https://github.com/z64/rapture, #{Rapture::VERSION})"

        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
