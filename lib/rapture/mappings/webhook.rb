# frozen_string_literal: true

module Rapture
  class Webhook
    include Mapping

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] guild_id
    # @return [Integer, nil]
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] channel_id
    # @return [Integer]
    getter :channel_id, converter: Converters.Snowflake

    # @!attribute [r] user
    # @return [User, nil]
    getter :user, from_json: User

    # @!attribute [r] name
    # @return [String, nil]
    getter :name

    # @!attribute [r] avatar
    # @return [String, nil]
    getter :avatar

    # @!attribute [r] token
    # @return [String]
    getter :token
  end
end
