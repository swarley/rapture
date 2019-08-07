require "rapture/mappings/user"
require "rapture/mappings/member"

module Rapture::Gateway
  # Heartbeat class stub for gateway event classification.
  # A gateway heartbeat will have the sequence number as
  # it's payload.
  Heartbeat = Struct.new(:sequence) do
    def self.from_h(data, _)
      new(data)
    end
  end

  # Payload that is sent to identify a client to the gateway
  # https://discordapp.com/developers/docs/topics/gateway#identify
  class Identify
    include Rapture::Mapping

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
    include Rapture::Mapping

    # @!attribute [r] since
    # @return [Integer, nil]
    getter :since

    # @!attribute [r] game
    # @return [Activity, nil]
    getter :game, from_json: Rapture::Activity

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
    include Rapture::Mapping

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
    include Rapture::Mapping

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
    include Rapture::Mapping

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
    include Rapture::Mapping

    # @return [Integer] heartbeat interval
    getter :heartbeat_interval

    # @return [Array<String>] Discord debug information
    getter :_trace
  end

  class Ready
    include Rapture::Mapping

    # @!attribute [r] v
    # @return [Integer] Accepted Discord gateway version
    getter :v

    # @!attribute [r] user
    # @return [User] the identified user
    getter :user, from_json: Rapture::User

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

  class Resumed
  end

  ChannelCreate = Rapture::Channel.dup

  ChannelUpdate = Rapture::Channel.dup

  ChannelDelete = Rapture::Channel.dup

  class ChannelPinsUpdate
    include Rapture::Mapping

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

  GuildCreate = Rapture::Guild.dup

  GuildUpdate = Rapture::Guild.dup

  GuildDelete = Rapture::Guild.dup

  class GuildBanAdd
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] user
    # @return [User]
    getter :user, from_json: Rapture::User
  end

  GuildBanRemove = GuildBanAdd.dup

  class GuildEmojisUpdate
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] emojis
    # @return [Array<Emoji>]
    getter :emojis, from_json: Rapture::Emoji
  end

  class GuildIntegrationsUpdate
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake
  end

  class GuildMemberAdd < Rapture::Member
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake
  end

  class GuildMemberRemove
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] user
    # @return [User]
    getter :user, from_json: Rapture::User
  end

  class GuildMemberUpdate
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] roles
    # @return [Array<String, Integer>]
    getter :roles, converter: Converters.Snowflake

    # @!attribute [r] user
    # @return [User]
    getter :user, from_json: Rapture::User

    # @!attribute [r] nick
    # @return [String]
    getter :nick
  end

  class GuildMembersChunk
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] members
    # @return [Array<Member>]
    getter :members, from_json: Rapture::Member
  end

  class GuildRoleCreate
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] role
    # @return [Role]
    getter :role, from_json: Rapture::Role
  end

  class GuildRoleUpdate
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] role
    # @return [Role]
    getter :role, from_json: Rapture::Role
  end

  class GuildRoleDelete
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] role_id
    # @return [Integer]
    getter :role_id, converter: Converters.Snowflake
  end

  MessageCreate = Rapture::Message.dup

  MessageUpdate = Rapture::Message.dup

  class MessageDelete
    include Rapture::Mapping

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
    include Rapture::Mapping

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
    include Rapture::Mapping

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
    getter :emoji, from_json: Rapture::Reaction
  end

  class MessageReactionRemove
    include Rapture::Mapping

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
    getter :emoji, from_json: Rapture::Reaction
  end

  class MessageReactionRemoveAll
    include Rapture::Mapping

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

  class TypingStart
    include Rapture::Mapping

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
      to_json: proc { |time| time.to_i },
      from_json: proc { |u_time| Time.at(u_time) }
  end

  UserUpdate = Rapture::User.dup

  VoiceStateUpdate = Rapture::Voice::State.dup

  class VoiceServerUpdate
    include Rapture::Mapping

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
    include Rapture::Mapping

    # @!attribute [r] guild_id
    # @return [Integer]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] channel_id
    # @return [Integer]
    getter :channel_id, converter: Converters.Snowflake
  end
end
