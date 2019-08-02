# frozen_string_literal: true

require "rapture/mappings/guild"

module Rapture
  class Message
    include Mapping
    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, to_json: :to_s, converter: Converters.Snowflake

    # @!attribute [r] channel_id
    # @return [Integer] Channel ID of where this message was sent
    getter :channel_id, converter: Converters.Snowflake

    # @!attribute [r] author
    # @return [User] the message author
    getter :author, from_json: User

    # @!attribute [r] member
    getter :member, from_json: Member

    # @!attribute [r] content
    # @return [String] message content
    getter :content

    # @!attribute [r] timestamp
    getter :timestamp, converter: Converters.Timestamp

    # @!attribute [r] edited_timestamp
    getter :edited_timestamp, converter: Converters.Timestamp?

    # @!attribute [r] tts
    # @return [true, false] whether this message was sent as a TTS message
    getter :tts

    # @!attribute [r] mention_everyone
    getter :mention_everyone

    # @!attribute [r] mentions
    getter :mentions, from_json: User

    # @!attribute [r] mentions_roles
    getter :mention_roles, converter: Converters.Snowflake

    # @!attribute [r] attachments
    getter :attachments, from_json: Attachment

    # @!attribute [r] embeds
    getter :embeds, from_json: Embed

    # @!attribute [r] reactions
    getter :reactions, from_json: Reaction

    # @!attribute [r] nonce
    getter :nonce, converter: Converters.Snowflake?

    # @!attribute [r] pinned
    getter :pinned

    # @!attribute [r] webhook_id
    getter :webhook_id, converter: Converters.Snowflake

    # @!attribute [r] type
    getter :type

    # @!attribute [r] activity
    getter :activity, from_json: Activity

    # @!attribute [r] application
    getter :application, from_json: Application
  end
end
