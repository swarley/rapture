# frozen_string_literal: true

module Rapture
  # Information about the location of Discord's gateway host
  class GatewayInfo
    include Mapping

    # @return [String] the URL of the gateway
    property :url

    # @return [Integer, nil] the recommended amount of shards for this client
    property :shards
  end

  module Gateway
    class Hello
      include Mapping

      # @return [Integer] heartbeat interval
      property :heartbeat_interval

      # @return [Array<String>] Discord debug information
      property :_trace
    end

    class Identify
      include Mapping

      # @return [String] Authorization token
      property :token

      # @return [Hash] Identify metadata
      property :properties

      # @return [Integer] Large guild threshold
      property :large_threshold

      # @return [{Integer, Integer}] Shard key
      property :shard

      def initialize(token, properties, large_threshold, shard)
        @token = token
        @properties = properties
        @large_threshold = large_threshold
        @shard = shard
      end
    end

    class Ready
      include Mapping

      # @return [Integer] Accepted Discord gateway version
      property :v

      # @return [User] the identified user
      property :user, from_json: User

      # @return [Array] the private channels for this user (always an empty array)
      property :private_channels

      # @return [Array<Hash>] unavailable guilds
      property :guilds

      # @return [String]
      property :session_id
    end
  end
end
