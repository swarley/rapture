# frozen_string_literal: true

module Rapture
  # Unicode or custom emoji objects that are used in messages
  # or reactions.
  # https://discordapp.com/developers/docs/resources/emoji#emoji-object-emoji-structure
  class Emoji
    include Mapping

    # @!attribute [r] available
    # @return [true, false]
    getter :available

    # @!attribute [r] id
    # @return [Integer, nil] emoji id
    getter :id, converter: Converters.Snowflake?

    # @!attribute [r] name
    # @return [String] emoji name
    getter :name

    # @!attribute [r] roles
    # @return [Array<Integer>, nil] roles this emoji is whitelisted to
    getter :roles, converter: Converters.Snowflake?

    # @!attribute [r] user
    # @return [User, nil] the user that created this emoji
    getter :user, from_json: User

    # @!attribute [r] require_colons
    # @return [true, false] whether this emoji must be wrapped in colons
    getter :require_colons

    # @!attribute [r] managed
    # @return [true, false] whether this emoji is managed
    getter :managed

    # @!attribute [r] animated
    # @return [true, false] whether this emoji is animated
    getter :animated
  end

  # Represents an emoji partial for reactions
  class Reaction
    include Mapping

    # @!attribute [r] id
    # @return [Integer, nil]
    getter :id, converter: Converters.Snowflake?

    # @!attribute [r] name
    # @return [String]
    getter :name
  end
end
