# frozen_string_literal: true

module Rapture
  # A User account on Discord
  # https://discordapp.com/developers/docs/resources/user#user-object-user-structure
  class User
    include Mapping

    # https://discordapp.com/developers/docs/resources/user#user-object-user-flags
    class Connection
      include Mapping

      # @!attribute [r] id
      # @return [Integer]
      getter :id

      # @!attribute [r] name
      # @return [String]
      getter :name

      # @!attribute [r] type
      # @return [String]
      getter :type

      # @!attribute [r] revoked
      # @return [true, false]
      getter :revoked

      alias_method :revoked?, :revoked

      # @todo avoid this from being a thing
      # @!attribute [r] integrations
      # @return [Array<Guild::Integration>]
      getter :integrations, from_json: proc { |data| Rapture::Guild::Integration.from_json(data) }

      # @!attribute [r] verified
      # @return [true, false]
      getter :verified

      alias_method :verified?, :verified

      # @!attribute [r] friend_sync
      # @return [true, false]
      getter :friend_sync

      alias_method :friend_sync?, :friend_sync

      # @!attribute [r] show_activity
      # @return [true, false]
      getter :show_activity

      # @!attribute [r] visibility
      # @return [Integer]
      getter :visibility
    end

    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] discriminator
    # @return [String] 4-digit discriminator
    getter :discriminator

    # @!attribute [r] username
    # @return [String] this user's name
    getter :username

    # @!attribute [r] avatar
    # @return [String, nil] avatar hash
    getter :avatar

    # @!attribute [r] bot
    # @return [true, false] whether this user belongs to an OAuth2 application
    getter :bot

    alias_method :bot?, :bot

    # @!attribute [r] verified
    # @return [true, false] whether this user's account has a registered email address
    getter :verified

    alias_method :verified?, :verified

    # @!attribute [r] email
    # @return [String, nil] email address, if this user is verified
    getter :email

    # @!attribute [r] mfa_enabled
    # @return [true, false] whether this user has mfa enabled
    getter :mfa_enabled

    alias_method :mfa_enabled?, :mfa_enabled

    # @!attribute [r] locale
    # @return [String, nil] the user's chosen language option
    getter :locale

    # @!attribute [r] flags
    # @return [Integer, nil] flags on a user's account
    # @see Rapture::UserFlags
    getter :flags

    # @!attribute [r] premium_type
    # @return [Integer, nil] the type of nitro a user has, if any.
    # @see https://discordapp.com/developers/docs/resources/user#user-object-premium-types
    getter :premium_type

    # This user's name and discriminator, that uniquely identifies them on Discord
    # @return [String]
    def distinct
      "#{username}##{discriminator}"
    end
  end
end
