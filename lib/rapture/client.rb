# frozen_string_literal: true

module Rapture
  # The `Client` abstracts away the token from making REST API requests
  # and provides a means to connect to Discord's websocket.
  class Client
    include REST

    def initialize(token)
      @type, @token = token.split(' ')
    end
  end
end
