# frozen_string_literal: true

module Rapture
  # Information about the location of Discord's gateway host
  class GatewayInfo
    include Mapping

    # @return [String] the URL of the gateway
    property :url

    # return [Integer, nil] the recommended amount of shards for this client
    property :shards
  end
end
