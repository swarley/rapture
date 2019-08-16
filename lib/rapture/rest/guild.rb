# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Create a guild. This can only be used by bots in less than 10 guilds.
  # https://discordapp.com/developers/docs/resources/guild#create-guild
  # @param name [String]
  # @param region [String]
  # @param icon [String]
  # @param verification_level [Integer]
  # @param default_message_notifications [Integer]
  # @param explicit_content_filter [Integer]
  # @param roles [Array<Role>]
  # @param channels [Array<Channel>]
  # @return [Guild]
  def create_guild(name:, region: nil, icon: nil, verification_level: nil, default_message_notifications: nil,
                   explicit_content_filter: nil, roles: nil, channels: nil)
    response = request(
      :guilds, nil,
      :post,
      "guilds",
      name: name, region: region, icon: icon, verification_level: verification_level,
      default_message_notifications: default_message_notifications, explicit_content_filter: explicit_content_filter,
      roles: roles, channels: channels,
    )

    Rapture::Guild.from_json(response.body)
  end

  # Get a guild object
  # https://discordapp.com/developers/docs/resources/guild#get-guild
  # @param guild_id [String, Integer]
  # @return [Guild]
  def get_guild(guild_id)
    response = request(
      :guilds_gid, guild_id,
      :get,
      "guilds/#{guild_id}"
    )
    Rapture::Guild.from_json(response.body)
  end

  # Modify a guild's settings
  # https://discordapp.com/developers/docs/resources/guild#modify-guild
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
  # @return [Guild] updated {Guild} object
  def modify_guild(guild_id, name: nil, region: nil, verification_level: nil,
                             default_message_notifications: nil, explicit_content_filter: nil,
                             afk_channel_id: nil, afk_timeout: nil, icon: nil, owner_id: nil, splash: nil,
                             system_channel_id: nil, reason: nil)
    response = request(
      :guilds_gid, guild_id,
      :patch,
      "guilds/#{guild_id}",
      {name: name, region: region, verification_level: verification_level, default_message_notifications: default_message_notifications,
       explicit_content_filter: explicit_content_filter, afk_channel_id: afk_channel_id, afk_timeout: afk_timeout,
       icon: icon, owner_id: owner_id, splash: splash, system_channel_id: system_channel_id},
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Guild.from_json(response.body)
  end

  # Delete a guild. User must be the owner
  # https://discordapp.com/developers/docs/resources/guild#delete-guild
  # @param guild_id [String, Integer]
  def delete_guild(guild_id)
    request(
      :guilds_gid, guild_id,
      :delete,
      "guilds/#{guild_id}"
    )
  end

  # Returns a list of {Array<Channel>} for a given guild.
  # https://discordapp.com/developers/docs/resources/guild#get-guild-channels
  # @param guild_id [String, Integer]
  # @return [Guild]
  def get_guild_channels(guild_id)
    response = request(
      :guilds_gid_channels, guild_id,
      :get,
      "guilds/#{guild_id}/channels"
    )
    Rapture::Channel.from_json_array(response.body)
  end

  # Create a new channel for a guild.
  # https://discordapp.com/developers/docs/resources/guild#create-guild-channel
  # @param guild_id [String, Integer]
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
  def create_guild_channel(guild_id, name:, reason: nil, type: nil, topic: nil, bitrate: nil, user_limit: nil,
                                     rate_limit_per_user: nil, position: nil, permission_overwrites: nil, parent_id: nil,
                                     nsfw: nil)
    response = request(
      :guilds_gid_channels, guild_id,
      :post,
      "guilds/#{guild_id}/channels",
      {name: name, type: type, topic: topic, bitrate: bitrate, user_limit: user_limit,
       rate_limit_per_user: rate_limit_per_user, position: position,
       permission_overwrites: permission_overwrites, parent_id: parent_id, nsfw: nsfw},
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Channel.from_json(response.body)
  end

  # Modify positions of a set of channels for the guild
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-channel-positions
  # @param guild_id [String, Integer]
  # @param positions [Array<(String, Integer), (Integer, Integer)>]
  def modify_guild_channel_positions(guild_id, positions, reason: nil)
    request(
      :guilds_gid_channels, guild_id,
      :patch,
      "guilds/#{guild_id}/channels",
      positions,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Get a {Member} object for a user.
  # https://discordapp.com/developers/docs/resources/guild#get-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @return [Member]
  def get_guild_member(guild_id, user_id)
    response = request(
      :guilds_gid_members_uid, guild_id,
      :get,
      "guilds/#{guild_id}/members/#{user_id}"
    )
    Rapture::Member.from_json(response.body)
  end

  # {Array<Member>} of members in a guild
  # https://discordapp.com/developers/docs/resources/guild#list-guild-members
  # @param guild_id [String, Integer]
  # @param limit [Integer]
  # @param after [String, Integer]
  # @return [Array<Member>]
  def list_guild_members(guild_id, limit: nil, after: nil)
    query = URI.encode_www_form({limit: limit, after: after}.compact)
    response = request(
      :guilds_gid_members, guild_id,
      :get,
      "guilds/#{guild_id}/members?" + query
    )
    Rapture::Member.from_json_array(response.body)
  end

  # Add a user to the guild using an access token.
  # https://discordapp.com/developers/docs/resources/guild#add-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param access_token [String]
  # @param nick [String]
  # @param roles [Array<String, Integer>]
  # @param mute [true, false]
  # @param deaf [true, false]
  # @return [Member, nil] `nil` if the user is already a member of the guild
  def add_guild_member(guild_id, user_id, access_token:, nick: nil, roles: nil, mute: nil, deaf: nil)
    response = request(
      :guilds_gid_members_uid, guild_id,
      :put,
      "guilds/#{guild_id}/members/#{user_id}",
      access_token: access_token, nick: nick, roles: roles, mute: mute, deaf: deaf,
    )

    return nil if response.status == 204

    Rapture::Member.from_json(response.body)
  end

  # Modify attributes of a guild member
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param nick [String]
  # @param roles [Array<String, Integer>]
  # @param mute [true, false]
  # @param deaf [true, false]
  # @param channel_id [String, Integer, nil]
  # @param reason [String]
  def modify_guild_member(guild_id, user_id, reason: nil, nick: nil, roles: nil, mute: nil, deaf: nil, channel_id: nil)
    request(
      :guilds_gid_members_uid, guild_id,
      :patch,
      "guilds/#{guild_id}/members/#{user_id}",
      {nick: nick, roles: roles, mute: mute, deaf: deaf, channel_id: channel_id},
      'X-Audit-Log-Reason': reason,
    )
  end

  # Modifies the nickname of the current user in a guild
  # https://discordapp.com/developers/docs/resources/guild#modify-current-user-nick
  # @param guild_id [String, Integer]
  # @param nick [String]
  # @return [String] the nickname that was set
  def modify_current_user_nick(guild_id, nick:)
    response = request(
      :guilds_gid_members_me_nick, guild_id,
      :patch,
      "guilds/#{guild_id}/members/@me/nick",
      nick: nick,
    )
    response.body
  end

  # Add a role to a guild member
  # https://discordapp.com/developers/docs/resources/guild#add-guild-member-role
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param role_id [String, Integer]
  # @param reason [String]
  def add_guild_member_role(guild_id, user_id, role_id, reason: nil)
    request(
      :guilds_gid_members_uid_roles_rid, guild_id,
      :put,
      "guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Remove a role from a guild member
  # https://discordapp.com/developers/docs/resources/guild#remove-guild-member-role
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param role_id [String, Integer]
  # @param reason [String]
  def remove_guild_member_role(guild_id, user_id, role_id, reason: nil)
    request(
      :guilds_gid_members_uid_roles_rid, guild_id,
      :delete,
      "guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Remove/Kick a member from a guild
  # https://discordapp.com/developers/docs/resources/guild#remove-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param reason [String]
  def remove_guild_member(guild_id, user_id, reason: nil)
    request(
      :guilds_gid_members_uid, guild_id,
      :delete,
      "guilds/#{guild_id}/members/#{user_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # List of bans in a guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-bans
  # @param guild_id [String, Integer]
  # @return [Array<Ban>]
  def get_guild_bans(guild_id)
    response = request(
      :guilds_gid_bans, guild_id,
      :get,
      "guilds/#{guild_id}/bans"
    )
    Rapture::Ban.from_json_array(response.body)
  end

  # Get the {Ban} object for a given user
  # https://discordapp.com/developers/docs/resources/guild#get-guild-ban
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @return [Ban]
  def get_guild_ban(guild_id, user_id)
    response = request(
      :guilds_gid_bans_uid, guild_id,
      :get,
      "guilds/#{guild_id}/bans/#{user_id}"
    )
    Rapture::Ban.from_json(response.body)
  end

  # Create a guild ban and optionally delete messages sent by the user
  # https://discordapp.com/developers/docs/resources/guild#create-guild-ban
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param delete_message_days [Integer]
  # @param reason [String]
  def create_guild_ban(guild_id, user_id, delete_message_days: nil, reason: nil)
    query = URI.encode_www_form('delete-message-days': delete_message_days, reason: reason)
    request(
      :guilds_gid_bans_uid, guild_id,
      :put,
      "guilds/#{guild_id}/bans/#{user_id}?" + query,
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Remove the ban for a user
  # https://discordapp.com/developers/docs/resources/guild#remove-guild-ban
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param reason [String]
  def remove_guild_ban(guild_id, user_id, reason: nil)
    request(
      :guilds_gid_bans_uid, guild_id,
      :delete,
      "guilds/#{guild_id}/bans/#{user_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Get a list of roles for a guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-roles
  # @param guild_id [String, Integer]
  # @return [Array<Role>]
  def get_guild_roles(guild_id)
    response = request(
      :guilds_gid_roles, guild_id,
      :get,
      "guilds/#{guild_id}/roles"
    )
    Rapture::Role.from_json_array(response.body)
  end

  # Create a new role for the guild
  # https://discordapp.com/developers/docs/resources/guild#create-guild-role
  # @param guild_id [String, Integer]
  # @param name [String]
  # @param permissions [Integer]
  # @param color [Integer]
  # @param hoist [true, false]
  # @param mentionable [true, false]
  # @param reason [String]
  # @return [Role]
  def create_guild_role(guild_id, reason: nil, name: nil, permissions: nil, color: nil, hoist: nil, mentionable: nil)
    response = request(
      :guilds_gid_roles, guild_id,
      :post,
      "guilds/#{guild_id}/roles",
      {name: name, permissions: permissions, color: color, hoist: hoist, mentionable: mentionable},
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Role.from_json(response.body)
  end

  # Modify the positions of a set of roles for a guild
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-role-positions
  # @param guild_id [String, Integer]
  # @param positions [Array<(String, Integer), (Integer, Integer)>]
  # @param reason [String]
  # @return [Array<Role>]
  def modify_guild_role_positions(guild_id, positions, reason: nil)
    response = request(
      :guilds_gid_roles, guild_id,
      :patch,
      "guilds/#{guild_id}/roles",
      positions,
      'X-Audit-Log-Reason': reason,
    )

    Rapture::Role.from_json_array(response.body)
  end

  # Modify a guild role
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-role
  # @param guild_id [String, Integer]
  # @param role_id [String, Integer]
  # @param name [String]
  # @param permissions [Integer]
  # @param color [Integer]
  # @param hoist [true, false]
  # @param mentionable [true, false]
  # @param reason [String]
  # @return [Role]
  def modify_guild_role(guild_id, role_id, reason: nil, name: nil, permissions: nil, color: nil, hoist: nil, mentionable: nil)
    response = request(
      :guild_gid_roles_rid, guild_id,
      :patch,
      "guilds/#{guild_id}/roles/#{role_id}",
      {name: name, permissions: permissions, color: color, hoist: hoist, mentionable: mentionable},
      'X-Audit-Log-Reason': reason,
    )

    Rapture::Role.from_json(response.body)
  end

  # Delete a guild role
  # https://discordapp.com/developers/docs/resources/guild#delete-guild-role
  # @param guild_id [String, Integer]
  # @param role_id [String, Integer]
  # @param reason [String]
  def delete_guild_role(guild_id, role_id, reason: nil)
    request(
      :guilds_gid_roles_rid, guild_id,
      :delete,
      "guilds/#{guild_id}/roles/#{role_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Get a number indicating the number of members that would
  # be removed in a prune operation
  # https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count
  # @param guild_id [String, Integer]
  # @return [Integer]
  def get_guild_prune_count(guild_id)
    response = request(
      :guilds_gid_prune, guild_id,
      :get,
      "guilds/#{guild_id}/prune"
    )
    Oj.load(response.body)["pruned"]
  end

  # Begin a prune operation
  # https://discordapp.com/developers/docs/resources/guild#begin-guild-prune
  # @param guild_id [String, Integer]
  # @param days [Integer]
  # @param compute_prune_count [true, false]
  # @return [Integer, nil]
  def begin_guild_prune(guild_id, days: nil, compute_prune_count: nil)
    query = URI.encode_www_form({days: days, compute_prune_count: compute_prune_count}.compact)
    response = request(
      :guilds_gid_prune, guild_id,
      :post,
      "guilds/#{guild_id}/prune" + query,
      nil,
      'X-Audit-Log-Reason': reason,
    )
    Oj.load(response.body)["pruned"]
  end

  # A list of {Voice::Region} objects for a guild.
  # https://discordapp.com/developers/docs/resources/guild#get-guild-voice-get_guild_voice_regions
  # @param guild_id [String, Integer]
  # @return [Array<Voice::Region>]
  def get_guild_voice_regions(guild_id)
    response = request(
      :guilds_gid_regions, guild_id,
      :get,
      "guilds/#{guild_id}/regions"
    )
    Rapture::Voice::Region.from_json_array(response.body)
  end

  # A list of {Integration} objects for a guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-integrations
  # @param guild_id [String, Integer]
  # @return [Array<Integration>]
  def get_guild_integrations(guild_id)
    response = request(
      :guilds_gid_integrations, guild_id,
      :get,
      "guilds/#{guild_id}/integrations"
    )
    Integration.from_json_array(response.body)
  end

  # Attach an integration object from the current user to the guild
  # https://discordapp.com/developers/docs/resources/guild#create-guild-integration
  # @param guild_id [String, Integer]
  # @param type [String]
  # @param id [String, Integer]
  def create_guild_integration(guild_id, type:, id:)
    request(
      :guilds_gid_integrations, guild_id,
      :post,
      "guilds/#{guild_id}/integrations",
      type: type, id: id,
    )
  end

  # Modify the behavior and settings of an integration object
  # for the guild
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-integration
  # @param guild_id [String, Integer]
  # @param integration_id [String, Integer]
  # @param expire_behavior [Integer]
  # @param expire_grace_period [Integer]
  # @param enable_emoticons [true, false]
  def modify_guild_integration(guild_id, integration_id, expire_behavior:, expire_grace_period:, enable_emoticons:)
    request(
      :guilds_gid_integrations_iid, guild_id,
      :patch,
      "guilds/#{guild_id}/integrations/#{integration_id}",
      expire_behavior: expire_behavior, expire_grace_period: expire_grace_period, enable_emoticons: enable_emoticons,
    )
  end

  # Delete an attached integration object for the guild
  # https://discordapp.com/developers/docs/resources/guild#delete-guild-integration
  # @param guild_id [String, Integer]
  # @param integration_id [String, Integer]
  def delete_guild_integration(guild_id, integration_id)
    request(
      :guilds_gid_integrations_iid, guild_id,
      :delete,
      "guilds/#{guild_id}/integrations/#{integration_id}"
    )
  end

  # Sync an integration.
  # https://discordapp.com/developers/docs/resources/guild#sync-guild-integration
  # @param guild_id [Integer]
  # @param integration_id [Integer]
  # @return [true, false] Returns true if the sync was successful
  def sync_guild_integration(guild_id, integration_id)
    request(
      :guilds_gid_integrations_iid_sync, guild_id,
      :post,
      "guilds/#{guild_id}/integrations/#{integration_id}/sync"
    ).status == 204
  end

  # Get the guild embed object
  # https://discordapp.com/developers/docs/resources/guild#get-guild-embed
  # @param guild_id [String, Integer]
  # @return [Guild::Embed]
  def get_guild_embed(guild_id)
    response = request(
      :guilds_gid_embed, guild_id,
      :get,
      "guilds/#{guild_id}/embed"
    )
    Guild::Embed.from_json(response.body)
  end

  # Modify a guild embed
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-embed
  # @param guild_id [String, Integer]
  # @param enabled [true, false]
  # @param channel_id [String, Integer]
  def modify_guild_embed(guild_id, enabled: nil, channel_id: nil)
    response = request(
      :guilds_gid_embed, guild_id,
      :patch,
      "guilds/#{guild_id}/embed",
      enabled: enabled, channel_id: channel_id,
    )
    Guild::Embed.from_json(response.body)
  end

  # The vanity url for guilds with the feature enabled
  # https://discordapp.com/developers/docs/resources/guild#get-guild-vanity-url
  # @param guild_id [String, Integer]
  # @return [String, nil]
  def get_guild_vanity_url(guild_id)
    response = request(
      :guilds_gid_vanity_url, guild_id,
      :get,
      "guilds/#{guild_id}/vanity-url"
    )
    Oj.load(response.body)["code"]
  end

  # Returns a PNG image widget for the guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-widget-image
  # @param guild_id [String, Integer]
  # @todo
  def get_guild_widget_image(guild_id, style: nil)
    request(
      :guilds_gid_widget, guild_id,
      :get,
      "guilds/#{guild_id}/widget.png?" + style
    )
  end
end
