# frozen_string_literal: true

module Rapture
  # Representation of a code that can be used to add a member to a guild or DM channel
  # https://discordapp.com/developers/docs/resources/invite#invite-object-invite-structure
  class Invite
    include Mapping

    # Additional information about an invite
    # https://discordapp.com/developers/docs/resources/invite#invite-metadata-object-invite-metadata-structure
    class Metadata
      include Mapping

      # @!attribute [r] inviter
      # @return [User]
      getter :inviter, from_json: User

      # @!attribute [r] uses
      # @return [Integer]
      getter :uses

      # @!attribute [r] max_uses
      # @return [Integer]
      getter :max_uses

      # @!attribute [r] max_age
      # @return [Integer]
      getter :max_age

      # @!attribute [r] temporary
      # @return [true, false]
      getter :temporary

      alias_method :temporary?, :temporary

      # @!attribute [r] created_at
      # @return [Time]
      getter :created_at, from_json: Converters.Timestamp

      # @!attribute [r] revoked
      # @return [true, false]
      getter :revoked

      alias_method :revoked?, :revoked
    end

    # @!attribute [r] code
    # @return [String]
    getter :code

    # @!attribute [r] guild
    # @return [Guild, nil]
    getter :guild, from_json: Guild

    # @!attribute [r] channel
    # @return [Channel]
    getter :channel, from_json: Channel

    # @!attribute [r] target_user
    # @return [User]
    getter :target_user, from_json: User

    # @!attribute [r] target_user_type
    # @return [Integer, nil]
    getter :target_user_type

    # @!attribute [r] approximate_presence_count
    # @return [Integer, nil]
    getter :approximate_presence_count

    # @!attribute [r] approximate_member_count
    # @return [Integer, nil]
    getter :approximate_member_count
  end
end
