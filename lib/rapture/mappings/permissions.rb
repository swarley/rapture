# frozen_string_literal: true

module Rapture
  # Represets a set of permissions attached to a group of users
  # https://discordapp.com/developers/docs/topics/permissions#role-object
  class Role
    include Mapping

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] color
    # @return [Integer]
    getter :color

    # @!attribute [r] hoist
    # @return [true, false]
    getter :hoist

    alias_method :hoist?, :hoist

    # @!attribute [r] position
    # @return [Integer]
    getter :position

    # @!attribute [r] permissions
    # @return [Integer]
    getter :permissions

    # @!attribute [r] managed
    # @return [true, false]
    getter :managed

    alias_method :managed?, :managed

    # @!attribute [r] mentionable
    # @return [true, false]
    getter :mentionable

    alias_method :mentionable?, :mentionable
  end
end
