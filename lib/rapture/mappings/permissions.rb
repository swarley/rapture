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

  # A class that adds methods for checking if a permission
  # is present in a bitmask
  class Permissions
    Rapture::PermissionFlags.constants.each do |perm_name|
      perm_value = PermissionFlags.const_get(perm_name)
      perm_name = perm_name.downcase
      define_method(perm_name) do
        @mask & perm_value == perm_value
      end

      alias_method :"#{perm_name}?", perm_name
    end

    def initialize(mask)
      @mask = mask
    end
  end
end
