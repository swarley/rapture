
require "rapture/mappings/permissions"
require "rapture/mappings/channel"
require "rapture/mappings/emoji"
require "rapture/mappings/voice"
require "rapture/mappings/member"
require "rapture/mappings/gateway"

module Rapture
  class IntegrationAccount
    include Mapping

    getter :id
    getter :name
  end

  class Integration
    include Mapping

    # @!attribute [r] id
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    getter :name

    # @!attribute [r] type
    getter :type

    # @!attribute [r] enabled
    getter :enabled

    # @!attribute [r] syncing
    getter :syncing

    # @!attribute [r] role_id
    getter :role_id, converter: Converters.Snowflake

    # @!attribute [r] expire_behavior
    getter :expire_behavior

    # @!attribute [r] expire_grace_period
    getter :expire_grace_period

    # @!attribute [r] user
    getter :user, from_json: User

    # @!attribute [r] account
    getter :account, from_json: IntegrationAccount

    # @!attribute [r] synced_at
    getter :synced_at, converter: Converters.Timestamp
  end

  class Ban
    include Mapping

    # @!attribute [r] reason
    getter :reason

    # @!attribute [r] user
    getter :user, from_json: User
  end

  class Guild
    include Mapping

    # @!attribute [r] id
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    getter :name

    # @!attribute [r] icon
    getter :icon

    # @!attribute [r] splash
    getter :splash

    # @!attribute [r] owner
    getter :owner

    # @!attribute [r] owner_id
    getter :owner_id, converter: Converters.Snowflake

    # @!attribute [r] permissions
    getter :permissions

    # @!attribute [r] region
    getter :region

    # @!attribute [r] afk_channel_id
    getter :afk_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] afk_timeout
    getter :afk_timeout

    # @!attribute [r] embed_enabled
    getter :embed_enabled

    # @!attribute [r] embed_channel_id
    getter :embed_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] verification_level
    getter :verification_level

    # @!attribute [r] default_message_notifications
    getter :default_message_notifications

    # @!attribute [r] explicit_content_filter
    getter :explicit_content_filter

    # @!attribute [r] roles
    getter :roles, from_json: Role

    # @!attribute [r] emojis
    getter :emojis, from_json: Emoji

    # @!attribute [r] features
    getter :features

    # @!attribute [r] mfa_level
    getter :mfa_level

    # @!attribute [r] application_id
    getter :application_id, converter: Converters.Snowflake?

    # @!attribute [r] widget_enabled
    getter :widget_enabled

    # @!attribute [r] widget_channel_id
    getter :widget_channel_id, converter: Converters.Snowflake

    # @!attribute [r] system_channel_id
    getter :system_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] joined_at
    getter :joined_at, converter: Converters.Timestamp

    # @!attribute [r] large
    getter :large

    # @!attribute [r] unavailable
    getter :unavailable

    # @!attribute [r] member_count
    getter :member_count

    # @!attribute [r] voice_states
    getter :voice_states, from_json: VoiceState

    # @!attribute [r] members
    getter :members, from_json: Member

    # @!attribute [r] channels
    getter :channels, from_json: Channel

    # @!attribute [r] presences
    getter :presences, from_json: Gateway::PresenceUpdate

    # @!attribute [r] max_presences
    getter :max_presences

    # @!attribute [r] max_members
    getter :max_members

    # @!attribute [r] vanity_url_code
    getter :vanity_url_code

    # @!attribute [r] description
    getter :description

    # @!attribute [r] banner
    getter :banner

    # @!attribute [r] premium_tier
    getter :premium_tier

    # @!attribute [r] premium_subscription_count
    getter :premium_subscription_count
  end
end
