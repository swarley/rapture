# frozen_string_literal: true

module Rapture
  class Overwrite
    include Mapping

    # @return [Integer] role or user ID
    property :id, from_json: proc { |id| Integer(id) }

    # @reutrn [String] either "role" or "member"
    property :type

    # TODO: permissions
    # @return [Integer] permission bit set
    property :allow

    # TODO: permissions
    # @return [Integer] premission bit set
    property :deny
  end

  class Channel
    include Mapping

    # @return [Integer] ID
    property :id, from_json: proc { |id| Integer(id) }

    # @return [Integer] channel type
    property :type

    # @return [Integer, nil] Guild ID that this channel belongs to
    property :guild_id, from_json: proc { |id| id.nil? ? nil : Integer(id) }

    # @return [Integer, nil] this channels position in the channel list
    property :position

    # @return [Array<Overwrite>, nil] array of permission overwrites
    property :permission_overwrites, from_json: Overwrite

    # @return [String, nil] channel name
    property :name

    # @return [String, nil] channel topic
    property :topic

    # @return [true, false, nil] whether this channel is marked as nsfw
    property :nsfw

    # @return [Integer, nil] the ID of the last message sent in this channel
    property :last_message_id, from_json: proc { |id| id.nil? ? nil : Integer(id) }

    # @return [Integer, nil] the bitrate of this channel, if it is a voice channel
    property :bitrate

    # @return [Integer, nil] the maximum number of users that can join this channel, if it is a voice channel
    property :user_limit

    # @return [Array<User>] the recipients of this channel, if it is a DM
    property :recipients, from_json: User

    # @return [String, nil] the icon of this channel, if it is a DM
    property :icon

    # @return [Integer, nil] the ID of the DM creator
    property :owner_id, from_json: proc { |id| id.nil? ? nil : Integer(id) }

    # @return [Integer, nil] the ID of the category channel this channel is in
    property :parent_id, from_json: proc { |id| id.nil? ? nil : Integer(id) }

    # TODO: Time converter
    # @return [String, nil] when the last pinned message was pinned
    property :last_pin_timestamp
  end
end
