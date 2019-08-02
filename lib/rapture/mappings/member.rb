require "rapture/mappings/user"

module Rapture
  class Member
    include Mapping

    # @!attribute [r]  user
    getter :user, from_json: User

    # @!attribute [r] nick
    getter :nick

    # @!attribute [r] roles
    getter :roles, converter: Converters.Snowflake

    # @!attribute [r] joined_at
    getter :joined_at, converter: Converters.Timestamp

    # @!attribute [r] premium_since
    getter :premium_since, converter: Converters.Timestamp

    # @!attribute [r] deaf
    getter :deaf

    # @!attribute [r] mute
    getter :mute
  end
end
