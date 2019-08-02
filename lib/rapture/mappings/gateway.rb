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

      # @return [String] Authorization token
      getter :token

      # @return [Hash] Identify metadata
      getter :properties

      # @return [Integer] Large guild threshold
      getter :large_threshold

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
      getter :token

      # @!attribute [r] session_id
      getter :session_id

      # @!attribute [r] seq
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

    class VoiceState
      include Mapping

      # @!attribute [r] guild_id
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      getter :channel_id, converter: Converters.Snowflake?

      # @!attribute [r] user_id
      getter :user_id, converter: Converters.Snowflake

      # @!attribute [r] member
      getter :member, from_json: Member

      # @!attribute [r] session_id
      getter :session_id

      # @!attribute [r] deaf
      getter :deaf

      # @!attribute [r] mute
      getter :mute

      # @!attribute [r] self_deaf
      getter :self_deaf

      # @!attribute [r] self_mute
      getter :self_mute

      # @!attribute [r] suppress
      getter :suppress
    end

    class ClientStatus
      include Mapping

      # @!attribute [r] desktop
      getter :desktop

      # @!attribute [r] mobile
      getter :mobile

      # @!attribute [r] web
      getter :web
    end

    class PresenceUpdate
      include Mapping

      # @!attribute [r] user
      getter :user, from_json: User

      # @!attribute [r] roles
      getter :roles, from_json: Role

      # @!attribute [r] game
      getter :game, from_json: proc { |data| Activity.new(data) if data }

      # @!attribute [r] guild_id
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] status
      getter :status

      # @!attribute [r] activities
      getter :activities, from_json: Activity

      # @!attribute [r] client_status
      getter :client_status, from_json: ClientStatus
    end
  end
end
