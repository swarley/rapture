# frozen_string_literal: true

require "rapture/mappings/user"
require "rapture/mappings/emoji"

module Rapture
  # Represents a guild or DM channel
  # https://discordapp.com/developers/docs/resources/channel#channel-object-channel-structure
  class Channel
    include Mapping

    # A channel specific permission overwrite
    # https://discordapp.com/developers/docs/resources/channel#overwrite-object-overwrite-structure
    class Overwrite
      include Mapping

      # @!attribute [r] id
      # @return [Integer] role or user ID
      getter :id, converter: Converters.Snowflake

      # @!attribute [r] type
      # @return [String] either "role" or "member"
      getter :type

      # @!attribute [r] allow
      # @todo permissions
      # @return [Integer] permission bit set
      getter :allow

      # @!attribute [r] deny
      # @todo permissions
      # @return [Integer] premission bit set
      getter :deny
    end

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

  # https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-structure
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

  # https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure
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

  # Represents an attachment associated with a message
  # https://discordapp.com/developers/docs/resources/channel#attachment-object-attachment-structure
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

  # Class returned when getting a list of reactions on a message
  # https://discordapp.com/developers/docs/resources/channel#reaction-object-reaction-structure
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

  # @note The sum of all characters in an embed structure cannot exceed 6000 characters.
  # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-structure
  class Embed
    include Mapping

    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-image-structure
    class Image
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

    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-video-structure
    class Video
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

    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-provider-structure
    class Provider
      include Mapping

      # @!attribute [r] name
      # @return [String, nil] name of provider
      getter :name

      # @!attribute [r] url
      # @return [String, nil] url of provider
      getter :url
    end

    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-author-structure
    class Author
      include Mapping

      # @note An author's name can contain up to 256 characters
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
      # @return [String, nil] a proxied url of author icon
      getter :proxy_icon_url
    end

    # Embed footer object
    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-footer-structure
    class Footer
      include Mapping

      # @note Footer text can contain up to 2048 characters
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

    # Embed field object
    # https://discordapp.com/developers/docs/resources/channel#embed-object-embed-field-structure
    class Field
      include Mapping

      # @note The name field may contain up to 256 characters
      # @!attribute [r] name
      # @return [String] name of the field
      getter :name

      # @note The value field may contain up to 1024 characters.
      # @!attribute [r] value
      # @return [String] value of the field
      getter :value

      # @!attribute [r] inline
      # @return [true, false]
      getter :inline
    end

    # @note A title field can contain up to 256 characters
    # @!attribute [r] title
    # @return [String, nil]
    getter :title

    # @!attribute [r] type
    # @return [String, nil]
    getter :type

    # @note A description field can contain up to 2048 characters
    # @!attribute [r] description
    # @return [String, nil]
    getter :description

    # @!attribute [r] url
    # @return [String, nil]
    getter :url

    # @!attribute [r] timestamp
    # @return [Time, nil]
    getter :timestamp, converter: Converters.Timestamp

    # @!attribute [r] color
    # @return [Integer, nil]
    getter :color

    # @!attribute [r] footer
    # @return [EmbedFooter, nil]
    getter :footer, from_json: Footer

    # @!attribute [r] image
    # @return [EmbedImage, nil]
    getter :image, from_json: Image

    # @!attribute [r] thumbnail
    # @return [EmbedImage, nil]
    getter :thumbnail, from_json: Image

    # @!attribute [r] video
    # @return [EmbedVideo, nil]
    getter :video, from_json: Video

    # @!attribute [r] provider
    # @return [EmbedProvider, nil]
    getter :provider, from_json: Provider

    # @!attribute [r] author
    # @return [EmbedAuthor, nil]
    getter :author, from_json: Author

    # @note There may be up to 25 field objects in a single embed
    # @!attribute [r] fields
    # @return [Array<EmbedField>, nil]
    getter :fields, from_json: Field
  end
end
