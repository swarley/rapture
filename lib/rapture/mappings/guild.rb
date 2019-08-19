# frozen_string_literal: true

require "rapture/mappings/gateway"
require "rapture/mappings/permissions"
require "rapture/mappings/channel"
require "rapture/mappings/emoji"
require "rapture/mappings/voice"
require "rapture/mappings/member"
require "rapture/mappings/user"

module Rapture
  # https://discordapp.com/developers/docs/resources/guild#integration-object-integration-structure
  class Integration
    include Mapping

    # https://discordapp.com/developers/docs/resources/guild#integration-account-object-integration-account-structure
    class Account
      include Mapping

      # @!attribute [r] id
      # @return [Integer]
      getter :id

      # @!attribute [r] name
      # @return [String]
      getter :name
    end

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] type
    # @return [String]
    getter :type

    # @!attribute [r] enabled
    # @return [true, false]
    getter :enabled

    # @!attribute [r] syncing
    # @return [true, false]
    getter :syncing

    # @!attribute [r] role_id
    # @return [Integer]
    getter :role_id, converter: Converters.Snowflake

    # @!attribute [r] expire_behavior
    # @return [Integer]
    getter :expire_behavior

    # @!attribute [r] expire_grace_period
    # @return [Integer]
    getter :expire_grace_period

    # @!attribute [r] user
    # @return [User]
    getter :user, from_json: User

    # @!attribute [r] account
    # @return [Account]
    getter :account, from_json: Account

    # @!attribute [r] synced_at
    # @return [Time]
    getter :synced_at, converter: Converters.Timestamp
  end

  # https://discordapp.com/developers/docs/resources/guild#ban-object-ban-structure
  class Ban
    include Mapping

    # @!attribute [r] reason
    # @return [String, nil]
    getter :reason

    # @!attribute [r] user
    # @return [User]
    getter :user, from_json: User
  end

  # A guild represents a collection of users and channels, referred to as a server in the UI.
  # https://discordapp.com/developers/docs/resources/guild#guild-object-guild-structure
  class Guild
    include Mapping

    # https://discordapp.com/developers/docs/resources/guild#guild-embed-object-guild-embed-structure
    class Embed
      include Mapping

      # @!attribute [r] enabled
      # @return [true, false]
      getter :enabled

      # @!attribute [r] channel_id
      # @return [Integer, nil]
      getter :channel_id, converter: Converters.Snowflake?
    end

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] icon
    # @return [String, nil]
    getter :icon

    # @!attribute [r] splash
    # @return [String, nil]
    getter :splash

    # @!attribute [r] owner
    # @return [true, false]
    getter :owner

    # @!attribute [r] owner_id
    # @return [Integer]
    getter :owner_id, converter: Converters.Snowflake

    # @!attribute [r] permissions
    # @return [Permissions] The current user's total permissions in the guild.
    #   Does not include overwrites
    getter :permissions, converter: Converters.Permissions

    # @!attribute [r] region
    # @return [String]
    getter :region

    # @!attribute [r] afk_channel_id
    # @return [Integer, nil]
    getter :afk_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] afk_timeout
    # @return [Integer]
    getter :afk_timeout

    # @!attribute [r] embed_enabled
    # @return [true, false]
    getter :embed_enabled
    alias_method :embed_enabled?, :embed_enabled

    # @!attribute [r] embed_channel_id
    # @return [Integer, nil]
    getter :embed_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] verification_level
    # @return [Integer]
    # @see https://discordapp.com/developers/docs/resources/guild#guild-object-verification-level
    getter :verification_level

    # @!attribute [r] default_message_notifications
    # @return [Integer]
    # @see https://discordapp.com/developers/docs/resources/guild#guild-object-default-message-notification-level
    getter :default_message_notifications

    # @!attribute [r] explicit_content_filter
    # @see https://discordapp.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level
    getter :explicit_content_filter

    # @!attribute [r] roles
    # @return [Array<Role>]
    getter :roles, from_json: Rapture::Role

    # @!attribute [r] emojis
    # @return [Array<Emoji>]
    getter :emojis, from_json: Rapture::Emoji

    # @!attribute [r] features
    # @return [Array<String>]
    getter :features

    # @!attribute [r] mfa_level
    # @return [Integer]
    # @see https://discordapp.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level
    getter :mfa_level

    # @!attribute [r] application_id
    # @return [Integer, nil]
    getter :application_id, converter: Converters.Snowflake?

    # @!attribute [r] widget_enabled
    # @return [true, false]
    getter :widget_enabled
    alias_method :widget_enabled?, :widget_enabled

    # @!attribute [r] widget_channel_id
    # @return [Integer, nil]
    getter :widget_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] system_channel_id
    # @return [Integer, nil]
    getter :system_channel_id, converter: Converters.Snowflake?

    # @!attribute [r] joined_at
    # @return [Time, nil]
    getter :joined_at, converter: Converters.Timestamp?

    # @!attribute [r] large
    # @return [true, false]
    getter :large
    alias_method :large?, :large

    # @!attribute [r] unavailable
    # @return [true, false]
    getter :unavailable

    # @!attribute [r] member_count
    # @return [Integer, nil]
    getter :member_count

    # @!attribute [r] voice_states
    # @return [Array<Voice::State>]
    getter :voice_states, from_json: Voice::State

    # @!attribute [r] members
    # @return [Array<Member>, nil]
    getter :members, from_json: Member

    # @!attribute [r] channels
    # @return [Array<Channel>, nil]
    getter :channels, from_json: Channel

    # @!attribute [r] presences
    # @return [Array<Gateway::PresenceUpdate>, nil]
    getter :presences, from_json: Gateway::PresenceUpdate

    # @!attribute [r] max_presences
    # @return [Integer, nil]
    getter :max_presences

    # @!attribute [r] max_members
    # @return [Integer, nil]
    getter :max_members

    # @!attribute [r] vanity_url_code
    # @return [String, nil]
    getter :vanity_url_code

    # @!attribute [r] description
    # @return [String, nil]
    getter :description

    # @!attribute [r] banner
    # @return [String, nil]
    getter :banner

    # @!attribute [r] premium_tier
    # @return [Integer]
    # @see https://discordapp.com/developers/docs/resources/guild#guild-object-premium-tier
    getter :premium_tier

    # @!attribute [r] premium_subscription_count
    # @return [Integer, nil]
    getter :premium_subscription_count

    # Get the permissions for a member in a given channel
    # @param member [Member] The member to calculate permissions for
    # @param channel [Channel] A channel to apply overwrites from
    # @return [Permissions]
    def compute_permissions(member, channel = nil)
      base = compute_base_permissions(member)

      perms = if channel
                compute_overwrites(base, member, channel)
              else
                base
              end
      Rapture::Permissions.new(perms)
    end

    private

    # @!visibility private
    def compute_overwrites(base, member, channel)
      if base & PermissionFlags::ADMINISTRATOR == PermissionFlags::ADMINISTRATOR
        return PermissionFlags::ALL
      end

      permissions = base

      overwrites = channel.permission_overwrites.dup
      everyone_ow = overwrites.find { |ow| ow.id == @id }
      overwrites.delete(everyone_ow)

      if everyone_ow
        permissions &= ~everyone_ow.deny
        permissions |= everyone_ow.allow
      end

      allow = 0
      deny = 0
      member.roles.each do |role|
        overwrite = overwrites.find { |ow| ow.id == role.id }
        if overwrite
          allow |= overwrite.allow
          deny |= overwrite.deny
        end
      end

      permissions &= ~deny
      permissions |= allow

      member_ow = overwrites.find { |ow| ow.id == member.user.id }
      if member_ow
        permissions &= ~member_ow.deny
        permissions |= member_ow.allow
      end

      return permissions
    end

    # @!visibility private
    def compute_base_permissions(member)
      if @owner_id == member.user.id
        return PermissionFlags::ALL
      end

      everyone = @roles.find { |role| role.id == @id }
      permissions = everyone.permissions

      member_role_ids = member.roles
      role_perms = @roles.select do |role|
        member_role_ids.include? role.id
      end.collect(&:permissions)

      permissions = role_perms.reduce(permissions, &:|)

      if permissions & PermissionFlags::ADMINISTRATOR == PermissionFlags::ADMINISTRATOR
        return PermissionFlags::ALL
      else
        return permissions
      end
    end
  end
end
