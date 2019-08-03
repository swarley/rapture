# frozen_string_literal: true
require "rapture/mappings/user"
require "rapture/mappings/member"
require "rapture/mappings/permissions"
require "rapture/mappings/channel"

module Rapture
  # Information about the location of Discord's gateway host
  class GatewayInfo
    include Mapping

    # @return [String] the URL of the gateway
    getter :url

    # @return [Integer, nil] the recommended amount of shards for this client
    getter :shards
  end

  module Gateway
    class Hello
      include Mapping

      # @return [Integer] heartbeat interval
      getter :heartbeat_interval

      # @return [Array<String>] Discord debug information
      getter :_trace
    end

    class Identify
      include Mapping

      # @!attribute [r] token
      # @return [String] Authorization token
      getter :token

      # @!attribute [r] properties
      # @return [Hash] Identify metadata
      getter :properties

      # @!attribute [r] large_threshold
      # @return [Integer] Large guild threshold
      getter :large_threshold

      # @!attribute [r] shard
      # @return [{Integer, Integer}] Shard key
      getter :shard

      def initialize(token, properties, large_threshold, shard)
        @token = token
        @properties = properties
        @large_threshold = large_threshold
        @shard = shard
      end
    end

    class Resume
      include Mapping

      # @!attribute [r] token
      # @return [String]
      getter :token

      # @!attribute [r] session_id
      # @return [String]
      getter :session_id

      # @!attribute [r] seq
      # @return [Integer]
      getter :seq

      def initialize(token, session)
        @token = token
        @session_id = session.id
        @seq = session.seq
      end
    end

    class Ready
      include Mapping

      # @!attribute [r] v
      # @return [Integer] Accepted Discord gateway version
      getter :v

      # @!attribute [r] user
      # @return [User] the identified user
      getter :user, from_json: User

      # @!attribute [r] private_channels
      # @return [Array] the private channels for this user (always an empty array)
      getter :private_channels

      # @!attribute [r] guilds
      # @return [Array<Hash>] unavailable guilds
      getter :guilds

      # @!attribute [r] session_id
      # @return [String]
      getter :session_id
    end

    class ClientStatus
      include Mapping

      # @!attribute [r] desktop
      # @return [String, nil]
      getter :desktop

      # @!attribute [r] mobile
      # @return [String, nil]
      getter :mobile

      # @!attribute [r] web
      # @return [String, nil]
      getter :web
    end

    class PresenceUpdate
      include Mapping

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User

      # @!attribute [r] roles
      # @return [Array<Integer>]
      getter :roles, converter: Converters.Snowflake

      # @!attribute [r] game
      # @return [Activity, nil]
      getter :game, from_json: proc { |data| Activity.new(data) if data }

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] status
      # @return [String]
      getter :status

      # @!attribute [r] activities
      # @return [Array<Activity>]
      getter :activities, from_json: Activity

      # @!attribute [r] client_status
      # @return [ClientStatus]
      getter :client_status, from_json: ClientStatus
    end
  end
end
