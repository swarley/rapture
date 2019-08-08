# frozen_string_literal: true

require "rapture/mappings/user"

module Rapture
  class Member
    include Mapping

    # @!attribute [r]  user
    # @return [User]
    getter :user, from_json: User

    # @!attribute [r] nick
    # @return [String, nil]
    getter :nick

    # @!attribute [r] roles
    # @return [Array<Integer>]
    getter :roles, converter: Converters.Snowflake

    # @!attribute [r] joined_at
    # @return [Time]
    getter :joined_at, converter: Converters.Timestamp

    # @!attribute [r] premium_since
    # @return [Time, nil]
    getter :premium_since, converter: Converters.Timestamp?

    # @!attribute [r] deaf
    # @return [true, false]
    getter :deaf

    # @!attribute [r] mute
    # @return [true, false]
    getter :mute
  end
end
