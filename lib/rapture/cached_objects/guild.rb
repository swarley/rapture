# frozen_String_literal: true

module Rapture::CachedObjects
  class CachedGuild < Base(Rapture::Guild)
    def initialize(client, data)
      super(client, data)

      cached_channels = @delegate.channels.collect { |channel| CachedChannel.new(client, channel) }
      @delegate.instance_variable_set(:@channels, cached_channels)

      cached_roles = @delegate.roles.collect { |role| CachedRole.new(client, role, data.id) }
      @delegate.instance_variable_set(:@roles, cached_roles)
    end

    # Modify this guild's settings
    # @param guild_id [String, Integer]
    # @param name [String]
    # @param region [String]
    # @param verification_level [Integer]
    # @param default_message_notifications [Integer]
    # @param explicit_content_filter [Integer]
    # @param afk_channel_id [String, Integer]
    # @param afk_timeout [Integer]
    # @param icon [String]
    # @param owner_id [String, Integer]
    # @param splash [String]
    # @param system_channel_id [String, Integer]
    # @param reason [String]
    # @return [CachedGuild] updated {CachedGuild} object
    def modify(name: nil, region: nil, verification_level: nil, default_message_notifications: nil,
               explicit_content_filter: nil, afk_channel_id: nil, afk_timeout: nil,
               icon: nil, owner_id: nil, splash: nil, system_channel_id: nil, reason: nil)
      updated = client.modify_guild(
        self.id, name: name, region: region, verification_level: verification_level,
                 default_message_notifications: default_message_notifications, explicit_content_filter: explicit_content_filter,
                 afk_channel_id: afk_channel_id, afk_timeout: afk_timeout, icon: icon, owner_id: owner_id,
                 splash: splash, system_channel_id: system_channel_id, reason: reason,
      )
      @delegate = updated
    end

    # Delete this guild. Can only be done if the bot is the guild's owner.
    # @note This action is permanent
    def delete
      client.delete_guild(self.id)
    end

    # Get an array of {CachedChannel} for this guild
    # @return [Array<CachedChannel>]
    def channels
      client.get_guild_channels(self.id)
    end

    # Create a new channel
    # @param name [String]
    # @param type [Integer]
    # @param topic [String]
    # @param bitrate [Integer]
    # @param user_limit [Integer]
    # @param rate_limit_per_user [Integer]
    # @param position [Integer]
    # @param permission_overwrites [Array<Guild::Overwrite>]
    # @param parent_id [String, Integer]
    # @param nsfw [true, false]
    # @param reason [String]
    # @return [CachedChannel]
    def create_channel(
                       name:, type: nil, topic: nil, bitrate: nil, user_limit: nil,
                       rate_limit_per_user: nil, position: nil, permission_overwrites: nil,
                       parent_id: nil, nsfw: nil, reason: nil)
      client.create_guild_channel(
        self.id, name: name, type: type, topic: topic, bitrate: bitrate,
                 user_limit: user_limit, rate_limit_per_user: rate_limit_per_user,
                 position: position, permission_overwrites: permission_overwrites,
                 parent_id: parent_id, nsfw: nsfw, reason: reason,
      )
    end

    # Get a {CachedMember} object for a user
    # @param user_id [String, Integer]
    # @return [Member]
    def member(user_id)
      client.get_guild_member(self.id, user_id)
    end

    # Get a list of {CachedMember} objects for a guild
    # @return [Array<CachedMember>]
    def members
      client.get_guild_members(self.id)
    end

    # Add a guild member using an access token
    # @param guild_id [String, Integer]
    # @param user_id [String, Integer]
    # @param access_token [String]
    # @param nick [String]
    # @param roles [Array<String, Integer>]
    # @param mute [true, false]
    # @param deaf [true, false]
    # @return [CachedMember, nil] `nil` if the user is already a member of the guild
    def add_member(user_id, access_token:, nick: nil, roles: nil, mute: nil, deaf: nil)
      client.add_member(
        self.id, user_id, access_token, nick: nick, roles: roles,
                                        mute: mute, deaf: deaf,
      )
    end

    # Modify attributes of a guild member
    # @param user_id [String, Integer]
    # @param nick [String]
    # @param roles [Array<String, Integer>]
    # @param mute [true, false]
    # @param deaf [true, false]
    # @param channel_id [String, Integer, nil]
    # @param reason [String]
    def modify_member(user_id, nick: nil, roles: nil, mute: nil, deaf: nil, channel_id: nil)
      client.modify_member(
        self.id, user_id, nick: nick, roles: roles, mute: mute, deaf: deaf,
                          channel_id: channel_id,
      )
    end

    # Remove/Kick a member from a guild
    # @param user_id [String, Integer]
    # @param reason [String]
    def remove_member(member_id, reason: nil)
      client.remove_guild_member(self.id, member_id, reason: reason)
    end

    alias_method :kick, :remove_member

    # Modify the nickname of the current member (@me)
    # @param nick [String]
    # @return [String] the nickname that was set
    def change_nickname(nick)
      client.modify_current_user_nick(self.id, nick: nick)
    end

    # Return a list of ban objects for this guild
    # @return [Array<Ban>]
    def bans
      client.get_guild_bans(self.id)
    end

    # Return a ban for a given user, if any
    # @param user_id [Integer]
    # @return [Ban, nil]
    def get_ban(user_id)
      client.get_guild_ban(self.id, user_id)
    end

    # Ban a user from their ID
    # @param user_id [Integer]
    # @param reason [String]
    def ban(user_id, reason: nil)
      client.create_guid_ban(self.id, user_id, reason: reason)
    end

    # Remove the ban for a user given their ID
    # @param user_id [Integer]
    # @param reason [String]
    def unban(user_id, reason: nil)
      client.remove_guild_ban(self.id, user_id, reason: reason)
    end

    # Get a role given its ID
    # @param role_id [Integer]
    # @return [CachedRole, nil]
    def role(role_id)
      self.roles.find { |role| role.id == role_id }
    end

    # Create a new role for the guild
    # @param name [String]
    # @param permissions [Integer]
    # @param color [Integer]
    # @param hoist [true, false]
    # @param mentionable [true, false]
    # @param reason [String]
    # @return [CachedRole]
    def create_role(name: nil, permissions: nil, color: nil, hoist: nil,
                    mentionable: nil, reason: nil)
      client.create_guild_role(
        self.id, name: name, permissions: permissions, color: color,
                 hoist: hoist, mentionable: mentionable, reason: reason,
      )
    end

    # Delete a guild role
    # @param role_id [Integer]
    # @param reason [String]
    def delete_role(role_id, reason: nil)
      client.delete_guild_role(self.id, role_id, reason: reason)
    end

    # Modify a guild role
    # @param role_id [String, Integer]
    # @param name [String]
    # @param permissions [Integer]
    # @param color [Integer]
    # @param hoist [true, false]
    # @param mentionable [true, false]
    # @param reason [String]
    # @return [CachedRole]
    def modify_role(role_id, name: nil, region: nil, verification_level: nil,
                             default_message_notifications: nil, explicit_content_filter: nil,
                             afk_channel_id: nil, afk_timeout: nil, icon: nil, owner_id: nil,
                             splash: nil, system_channel_id: nil, reason: nil)
      client.modify_guild_role(
        self.id, role.id, name: name, region: region, verification_level: verification_level,
                          default_message_notifications: default_message_notifications, explicit_content_filter: explicit_content_filter,
                          afk_channel_id: afk_channel_id, afk_timeout: afk_timeout, icon: icon, owner_id: owner_id,
                          splash: splash, system_channel_id: system_channel_id, reason: reason,
      )
    end

    # Get a number indicating the number of members that would
    # be removed in a prune operation
    # @param guild_id [String, Integer]
    # @return [Integer]
    def prune_count(days: nil)
      client.get_prune_count(self.id, days: days)
    end

    # Begin a prune operation
    # @param days [Integer]
    # @param compute_prune_count [true, false]
    # @return [Integer, nil]
    def prune(days: nil, compute_prune_count: nil)
      client.begin_guild_prune(days: days, compute_prune_count: compute_prune_count)
    end

    # A list of {Voice::Region} objects for a guild.
    # @return [Array<Voice::Region>]
    def voice_regions
      client.get_guild_voice_regions(self.id)
    end

    # A list of invites for a guild
    # @return [Array<Invite>]
    def invites
      client.get_guild_invites(self.id)
    end

    # A list of {Integration} objects for a guild
    # @return [Array<Integration>]
    def integrations
      client.get_guild_integrations(self.id)
    end

    # Attach an integration object from the current user to the guild
    # @param type [String]
    # @param id [String, Integer]
    def create_integration(type:, id:)
      client.create_guild_integration(self.id, type: type, id: id)
    end

    # Modify the behavior and settings of an integration object
    # for the guild
    # https://discordapp.com/developers/docs/resources/guild#modify-guild-integration
    # @param integration_id [String, Integer]
    # @param expire_behavior [Integer]
    # @param expire_grace_period [Integer]
    # @param enable_emoticons [true, false]
    def modify_integration(id, expire_behavior:, expire_grace_period:, enable_emoticons:)
      client.modify_guild_integration(
        self.id, id, expire_behavior: expire_behavior,
                     expire_grace_period: expire_grace_period,
                     enable_emoticons: enable_emoticons,
      )
    end

    # Delete an attached integration object for the guild
    # @param integration_id [String, Integer]
    def delete_integration(id)
      client.delete_guild_integration(self.id, id)
    end

    # Sync an integration.
    # https://discordapp.com/developers/docs/resources/guild#sync-guild-integration
    # @param guild_id [Integer]
    # @param integration_id [Integer]
    # @return [true, false] Returns true if the sync was successful
    def sync_integration(id)
      client.sync_guild_integration(self.id, id)
    end

    # The vanity url for guilds with the feature enabled
    # @return [String, nil]
    def vanity_url
      client.get_guild_vanity_url(self.id)
    end
  end
end
