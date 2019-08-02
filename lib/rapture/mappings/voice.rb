# frozen_string_literal: true

require "rapture/mappings/member"

module Rapture
  class VoiceState
    include Mapping

    # @!attribute [r] guild_id
    getter :guild_id, converter: Converters.Timestamp

    # @!attribute [r] channel_id
    getter :channel_id, converter: Converters.Timestamp?

    # @!attribute [r] user_id
    getter :user_id, converter: Converters.Snowflake

    # @!attribute [r] member
    getter :member, from_json: Member

    # @!attribute [r] session_id
    getter :session_id

    # @!attribute [r] deaf
    getter :deaf

    # @!attribute [r] mute
    getter :mute

    # @!attribute [r] self_deaf
    getter :self_deaf

    # @!attribute [r] self_mute
    getter :self_mute

    # @!attribute [r] suppress
    getter :suppress
  end

  class VoiceRegion
    include Mapping

    # @!attribute [r] id
    getter :id

    # @!attribute [r] name
    getter :name

    # @!attribute [r] vip
    getter :vip

    # @!attribute [r] optimal
    getter :optimal

    # @!attribute [r] deprecated
    getter :deprecated

    # @!attribute [r] custom
    getter :custom
  end
end
