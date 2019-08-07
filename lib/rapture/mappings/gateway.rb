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
    # Heartbeat class stub for gateway event classification.
    # A gateway heartbeat will have the sequence number as
    # it's payload.
    Heartbeat = Struct.new(:sequence)

    # Payload that is sent to identify a client to the gateway
    # https://discordapp.com/developers/docs/topics/gateway#identify
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
      # @return [(Integer, Integer)] Shard key
      getter :shard

      def initialize(token, properties, large_threshold, shard)
        @token = token
        @properties = properties
        @large_threshold = large_threshold
        @shard = shard
      end
    end

    # Payload that is sent to indicate a status update
    #https://discordapp.com/developers/docs/topics/gateway#update-status
    class StatusUpdate
      include Mapping

      # @!attribute [r] since
      # @return [Integer, nil]
      getter :since

      # @!attribute [r] game
      # @return [Activity, nil]
      getter :game, from_json: Activity

      # @!attribute [r] status
      # https://discordapp.com/developers/docs/topics/gateway#update-status-status-types
      # @return [String]
      getter :status

      # @!attribute [r] afk
      # @return [true, false]
      getter :afk
    end

    # https://discordapp.com/developers/docs/topics/gateway#update-voice-state
    class VoiceStateUpdatePayload
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] self_mute
      # @return [true, false]
      getter :self_mute

      # @!attribute [r] self_deaf
      # @return [true, false1]
      getter :self_deaf
    end

    # Resume payload sent when resuming a connection to the gateway
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
        @seq = session.sequence
      end
    end

    # Reconnect event stub for gateway event dispatching
    class Reconnect
    end

    class RequestGuildMembers
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] query
      # @return [String]
      getter :query

      # @!attribute [r] limit
      # @return [Integer]
      getter :limit
    end

    # Invalid session stub for event dispatching
    InvalidSession = Struct.new(:resumable)

    # Represents the HELLO payload recieved from the gateway
    # that declares the heartbeat interval for the client.
    class Hello
      include Mapping

      # @return [Integer] heartbeat interval
      getter :heartbeat_interval

      # @return [Array<String>] Discord debug information
      getter :_trace
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

    class Resumed
    end

    ChannelCreate = Channel.dup
    
    ChannelUpdate = Channel.dup
    
    ChannelDelete = Channel.dup

    class ChannelPinsUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?

      # @!attribute [r] channel_id
      # @return [Integer, nil]
      getter :channel_id, converter: Converters.Snowflake?

      # @!attribute [r] last_pin_timestamp
      # @return [Time, nil]
      getter :last_pin_timestamp, converter: Converters.Timestamp?
    end

    GuildCreate = Guild.dup

    GuildUpdate = Guild.dup

    GuildDelete = Guild.dup

    class GuildBanAdd
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User
    end

    GuildBanRemove = GuildBanAdd.dup

    class GuildEmojisUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] emojis
      # @return [Array<Emoji>]
      getter :emojis, from_json: Emoji
    end

    class GuildIntegrationsUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake
    end

    class GuildMemberAdd
      include Member

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake
    end

    class GuildMemberRemove
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User
    end

    class GuildMemberUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] roles
      # @return [Array<String, Integer>]
      getter :roles, converter: Converters.Snowflake

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User

      # @!attribute [r] nick
      # @return [String]
      getter :nick
    end

    class GuildMembersChunk
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] members
      # @return [Array<Member>]
      getter :members, from_json: Member
    end

    class GuildRoleCreate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] role
      # @return [Role]
      getter :role, from_json: Role
    end

    class GuildRoleUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] role
      # @return [Role]
      getter :role, from_json: Role
    end

    class GuildRoleDelete
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] role_id
      # @return [Integer]
      getter :role_id, converter: Converters.Snowflake
    end

    MessageCreate = Message.dup

    MessageUpdate = Message.dup

    class MessageDelete
      include Mapping

      # @!attribute [r] id
      # @return [Integer]
      getter :id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?
    end

    class MessageDeleteBulk
      include Mapping

      # @!attribute [r] ids
      # @return [Array<Integer>]
      getter :ids, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?
    end

    class MessageReactionAdd
      include Mapping

      # @!attribute [r] user_id
      # @return [Integer]
      getter :user_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] message_id
      # @return [Integer]
      getter :message_id, converter: Converters.Snowflake
      
      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?

      # @!attribute [r] emoji
      # @return [Reaction]
      getter :emoji, from_json: Reaction 
    end

    class MessageReactionRemove
      include Mapping

      # @!attribute [r] user_id
      # @return [Integer]
      getter :user_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?

      # @!attribute [r] emoji
      # @return [Reaction]
      getter :emoji, from_json: Reaction
    end

    class MessageReactionRemoveAll
      include Mapping

      # @!attribute [r] message_id
      # @return [Integer]
      getter :message_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?
    end

    class PresenceUpdate
      include Mapping

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User

      # @!attribute [r] roles
      # @return [Array<Integer>]
      getter :roles, from_json: Converters.Snowflake

      # @!attribute [r] game
      # @return [Activity, nil]
      getter :game, from_json: Activity

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

    class TypingStart
      include Mapping

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake

      # @!attribute [r] guild_id
      # @return [Integer, nil]
      getter :guild_id, converter: Converters.Snowflake?

      # @!attribute [r] user_id
      # @return [Integer]
      getter :user_id, converter: Converters.Snowflake

      # @!attribute [r] timestamp
      # @return [Time]
      getter :timestamp, 
        to_json: proc {|time| time.to_i },
        from_json: proc {|u_time| Time.at(u_time) }
    end

    UserUpdate = User.dup

    VoiceStateUpdate = Voice::State.dup

    class VoiceServerUpdate
      include Mapping

      # @!attribute [r] token
      # @return [String]
      getter :token

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] endpoint
      # @return [String]
      getter :endpoint
    end

    class WebhooksUpdate
      include Mapping

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] channel_id
      # @return [Integer]
      getter :channel_id, converter: Converters.Snowflake
    end
  end
end
