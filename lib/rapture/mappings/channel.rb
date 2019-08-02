# frozen_string_literal: true

require "rapture/mappings/user"
require "rapture/mappings/emoji"

module Rapture
  class Overwrite
    include Mapping

    # @return [Integer] role or user ID
    getter :id, converters: Converters.Snowflake

    # @return [String] either "role" or "member"
    getter :type

    # TODO: permissions
    # @return [Integer] permission bit set
    getter :allow

    # TODO: permissions
    # @return [Integer] premission bit set
    getter :deny
  end

  class Channel
    include Mapping

    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] type
    # @return [Integer] channel type
    getter :type

    # @!attribute [r] guild_id
    # @return [Integer, nil] Guild ID that this channel belongs to
    getter :guild_id, converter: Converters.Snowflake?

    # @!attribute [r] position
    # @return [Integer, nil] this channels position in the channel list
    getter :position

    # @!attribute [r] permission_overwrites
    # @return [Array<Overwrite>, nil] array of permission overwrites
    getter :permission_overwrites, from_json: Overwrite

    # @!attribute [r] name
    # @return [String, nil] channel name
    getter :name

    # @!attribute [r] topic
    # @return [String, nil] channel topic
    getter :topic

    # @!attribute [r] nsfw
    # @return [true, false, nil] whether this channel is marked as nsfw
    getter :nsfw

    # @!attribute [r] last_message_id
    # @return [Integer, nil] the ID of the last message sent in this channel
    getter :last_message_id, converter: Converters.Snowflake?

    # @!attribute [r] bitrate
    # @return [Integer, nil] the bitrate of this channel, if it is a voice channel
    getter :bitrate

    # @!attribute [r] user_limit
    # @return [Integer, nil] the maximum number of users that can join this channel, if it is a voice channel
    getter :user_limit

    # @!attribute [r] recipients
    # @return [Array<User>] the recipients of this channel, if it is a DM
    getter :recipients, from_json: User

    # @!attribute [r] icon
    # @return [String, nil] the icon of this channel, if it is a DM
    getter :icon

    # @!attribute [r] owner_id
    # @return [Integer, nil] the ID of the DM creator
    getter :owner_id, converter: Converters.Snowflake?

    # @!attribute [r] parent_id
    # @return [Integer, nil] the ID of the category channel this channel is in
    getter :parent_id, converter: Converters.Snowflake?

    # @!attribute [r] last_pin_timestamp
    # @return [Time, nil] when the last pinned message was pinned
    getter :last_pin_timestamp, converter: Converters.Timestamp
  end

  class Activity
    include Mapping

    # @!attribute [r] type
    # @return [Integer] Type of activity
    # @see https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-types
    getter :type

    # @!attribute [r] party_id
    # @return [String] The `party_id` from a Rich Presence event
    getter :party_id
  end

  class Application
    include Mapping

    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] cover_image
    # @return [String] The ID of the embed's image asset
    getter :cover_image

    # @!attribute [r] description
    # @return [String] The application's description
    getter :description

    # @!attribute [r] icon
    # @return [String, nil] The ID of the application's icon
    getter :icon

    # @!attribute [r] name
    # @return [String] The name of the application
    getter :name
  end

  # @see https://discordapp.com/developers/docs/resources/channel#attachment-object-attachment-structure
  class Attachment
    include Mapping

    # @!attribute [r] id
    # @return [Integer] ID
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] filename
    # @return [String] The name of the file
    getter :filename

    # @!attribute [r] size
    # @return [Integer] File size in bytes
    getter :size

    # @!attribute [r] url
    # @return [String] The source URL of the file
    getter :url

    # @!attribute [r] proxy_url
    # @return [String] The proxied URL of the file
    getter :proxy_url

    # @!attribute [r] height
    # @return [Integer, nil] Height of the file, if it is an image
    getter :height

    # @!attribute [r] width
    # @return [Integer, nil] Width of the file, if it is an image
    getter :width
  end

  class Reaction
    include Mapping

    # @!attribute [r] count
    # @return [Integer] times this emoji has been used to react
    getter :count

    # @!attribute [r] me
    # @return [true, false] whether the current user reacted using this emoji
    getter :me

    # @!attribute [r] emoji
    # @return [Emoji] emoji information
    getter :emoji, from_json: Emoji
  end

  class EmbedImage
    include Mapping

    # @!attribute [r] url
    # @return [String] source url of the image
    getter :url

    # @!attribute [r] proxy_url
    # @return [String] a proxied url of the image
    getter :proxy_url

    # @!attribute [r] height
    # @return [Integer, nil] height of the image
    getter :height

    # @!attribute [r] width
    # @return [Integer, nil] width of the image
    getter :width
  end

  class EmbedVideo
    include Mapping

    # @!attribute [r] url
    # @return [String, nil] source url of video
    getter :url

    # @!attribute [r] height
    # @return [Integer, nil] height of the video
    getter :height

    # @!attribute [r] width
    # @return [Integer, nil] width of the video
    getter :width
  end

  class EmbedProvider
    include Mapping

    # @!attribute [r] name
    # @return [String, nil] name of provider
    getter :name

    # @!attribute [r] url
    # @return [String, nil] url of provider
    getter :url
  end

  class EmbedAuthor
    include Mapping

    # @!attribute [r] name
    # @return [String, nil] name of author
    getter :name

    # @!attribute [r] url
    # @return [String, nil] url of author
    getter :url

    # @!attribute [r] icon_url
    # @return [String, nil] url of author icon
    getter :icon_url

    # @!attribute [r] proxy_icon_url
    # @return a proxied url of author icon
    getter :proxy_icon_url
  end

  class EmbedFooter
    include Mapping

    # @!attribute [r] text
    # @return [String] footer text
    getter :text

    # @!attribute [r] icon_url
    # @return [String, nil] url of footer icon
    getter :icon_url

    # @!attribute [r] proxy_icon_url
    # @return [String, nil] proxied url of footer icon
    getter :proxy_icon_url
  end

  class EmbedField
    include Mapping

    # @!attribute [r] name
    # @return [String] name of the field
    getter :name

    # @!attribute [r] value
    # @return [String] value of the field
    getter :value

    # @!attribute [r] inline
    # @return [true, false]
    getter :inline
  end

  class Embed
    include Mapping

    # @!attribute [r] title
    # @return [String, nil] title of the embed
    getter :title

    # @!attribute [r] type
    # @return [String, nil] type of the embed
    getter :type

    # @!attribute [r] description
    # @return [String, nil] description of the embed
    getter :description

    # @!attribute [r] url
    # @return [String, nil] url of the embed
    getter :url

    # @!attribute [r] timestamp
    # @return [Time, nil] the timestamp of the embed
    getter :timestamp, converter: Converters.Timestamp
    
    # @!attribute [r] color
    # @return [Integer, nil] color code of the embed
    getter :color

    # @!attribute [r] footer
    # @return [EmbedFooter, nil] footer information
    getter :footer, from_json: EmbedFooter

    # @!attribute [r] image
    # @return [EmbedImage, nil] image information
    getter :image, from_json: EmbedImage

    # @!attribute [r] thumbnail
    # @return [EmbedImage, nil] thumbnail information
    getter :thumbnail, from_json: EmbedImage

    # @!attribute [r] video
    # @return [EmbedVideo, nil] video information
    getter :video, from_json: EmbedVideo

    # @!attribute [r] provider
    # @return [EmbedProvider, nil] provider information
    getter :provider, from_json: EmbedProvider

    # @!attribute [r] author
    # @return [EmbedAuthor, nil] author information
    getter :author, from_json: EmbedAuthor

    # @!attribute [r] fields
    # @return [Array<EmbedField>, nil]
    getter :fields, from_json: EmbedField
  end
end
