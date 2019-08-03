# frozen_string_literal: true

require "rapture/mappings/member"

module Rapture
  class VoiceState
    include Mapping

    # @!attribute [r] guild_id
    # @return [Integer, nil]
    getter :guild_id, converter: Converters.Timestamp

    # @!attribute [r] channel_id
    # @return [Integer, nil]
    getter :channel_id, converter: Converters.Timestamp?

    # @!attribute [r] user_id
    # @return [Integer]
    getter :user_id, converter: Converters.Snowflake

    # @!attribute [r] member
    # @return [Member, nil]
    getter :member, from_json: Member

    # @!attribute [r] session_id
    # @return [String]
    getter :session_id

    # @!attribute [r] deaf
    # @return [true, false]
    getter :deaf

    # @!attribute [r] mute
    # @return [true, false]
    getter :mute

    # @!attribute [r] self_deaf
    # @return [true, false]
    getter :self_deaf

    # @!attribute [r] self_mute
    # @return [true, false]
    getter :self_mute

    # @!attribute [r] suppress
    # @return [true, false]
    getter :suppress
  end

  class VoiceRegion
    include Mapping

    # @!attribute [r] id
    # @return [Integer]
    getter :id

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] vip
    # @return [true, false]
    getter :vip

    # @!attribute [r] optimal
    # @return [true, false]
    getter :optimal

    # @!attribute [r] deprecated
    # @return [true, false]
    getter :deprecated

    # @!attribute [r] custom
    # @return [true, false]
    getter :custom
  end
end
