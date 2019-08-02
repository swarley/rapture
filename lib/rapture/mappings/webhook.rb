# frozen_string_literal: true

module Rapture
  class Webhook
    include Mapping

    # @!attribute [r] id
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] guild_id
    getter :guild_id, converter: Converters.Snowflake

    # @!attribute [r] channel_id
    getter :channel_id, converter: Converters.Snowflake

    # @!attribute [r] user
    getter :user, from_json: User

    # @!attribute [r] name
    getter :name

    # @!attribute [r] avatar
    getter :avatar

    # @!attribute [r] token
    getter :token
  end
end
