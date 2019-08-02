# frozen_string_literal: true

module Rapture
  class Role
    include Mapping

    # @!attribute [r] id
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    getter :name

    # @!attribute [r] color
    getter :color

    # @!attribute [r] hoist
    getter :hoist

    # @!attribute [r] position
    getter :position

    # @!attribute [r] permissions
    getter :permissions

    # @!attribute [r] managed
    getter :managed

    # @!attribute [r] mentionable
    getter :mentionable
  end
end
