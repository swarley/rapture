# frozen_string_literal: true

require "rapture/mappings/guild"

module Rapture
  # The representation of a message that is sent to discord
  # https://discordapp.com/developers/docs/resources/channel#message-object-message-structure
  class Message
    include Mapping
    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] channel_id
    # @return [Integer]
    getter :channel_id, converter: Converters.Snowflake

    # @!attribute [r] guild_id
    # @return [Integer, nil]
    getter :guild_id, converter: Converters.Snowflake?

    # @!attribute [r] author
    # @return [User]
    getter :author, from_json: User

    # @!attribute [r] member
    # @return [Member]
    getter :member, from_json: Member

    # @!attribute [r] content
    # @return [String]
    getter :content

    # @!attribute [r] timestamp
    # @return [Time]
    getter :timestamp, converter: Converters.Timestamp

    # @!attribute [r] edited_timestamp
    # @return [Time, nil]
    getter :edited_timestamp, converter: Converters.Timestamp?

    # @!attribute [r] tts
    # @return [true, false]
    getter :tts

    # @!attribute [r] mention_everyone
    # @return [true, false]
    getter :mention_everyone

    # @!attribute [r] mentions
    # @return [Array<User>]
    getter :mentions, from_json: User

    # @!attribute [r] mentions_roles
    # @return [Array<Integer>]
    getter :mention_roles,
           from_json: proc { |data|
             Oj.load(data).map { |id| Converters.Snowflake.from_json.call(id) }
           },
           to_json: proc { |ids| ids.collect(&:to_s).to_json }

    # @!attribute [r] attachments
    # @return [Array<Attachment>]
    getter :attachments, from_json: Attachment

    # @!attribute [r] embeds
    # @return [Array<Embed>]
    getter :embeds, from_json: Embed

    # @!attribute [r] reactions
    # @return [Array<Reaction>, nil]
    getter :reactions, from_json: Reaction

    # @!attribute [r] nonce
    # @return [Integer, nil]
    getter :nonce, converter: Converters.Snowflake?

    # @!attribute [r] pinned
    # @return [true, false]
    getter :pinned

    # @!attribute [r] webhook_id
    # @return [Integer, nil]
    getter :webhook_id, converter: Converters.Snowflake?

    # @!attribute [r] type
    # @return [Integer]
    getter :type

    # @!attribute [r] activity
    # @return [Activity, nil]
    getter :activity, from_json: Activity

    # @!attribute [r] application
    # @return [Application, nil]
    getter :application, from_json: Application

    # @!attribute [r] flags 
    # @return [Integer, nil]
    getter :flags
  end
end
