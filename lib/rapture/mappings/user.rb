# frozen_string_literal: true

module Rapture
  # A User account on Discord
  class User
    include Mapping

    # @return [Integer] ID
    property :id, to_json: :to_s, from_json: proc { |id| Integer(id) }

    # @return [String] 4-digit discriminator
    property :discriminator

    # @return [String] this user's name
    property :username

    # @return [String, nil] avatar hash
    property :avatar

    # @return [true, false] whether this user belongs to an OAuth2 application
    property :bot

    alias_method :bot?, :bot

    # @return [true, false] whether this user's account has a registered email address
    property :verified

    alias_method :verified?, :verified

    # @return [String, nil] email address, if this user is verified
    property :email

    # @return [true, false] whether this user has mfa enabled
    property :mfa_enabled

    alias_method :mfa_enabled?, :mfa_enabled

    # This user's name and discriminator, that uniquely identifies them on Discord
    # @return [String]
    def distinct
      "#{username}##{discriminator}"
    end
  end
end
