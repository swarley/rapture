# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Create a guild. This can only be used by bots in less than 10 guilds.
  # https://discordapp.com/developers/docs/resources/guild#create-guild
  # @param name [String]
  # @option params [String] :region
  # @option params [String] :icon
  # @option params [Integer] :verification_level
  # @option params [Integer] :default_message_notifications
  # @option params [Integer] :explicit_content_filter
  # @option params [Array<Role>] :roles
  # @option params [Array<Channel>] :channels
  # @return [Guild]
  def create_guild(name:, **params)
    response = request(
      :post,
      "guilds",
      name: name, **params,
    )

    Rapture::Guild.from_json(response.body)
  end

  # Get a guild object
  # https://discordapp.com/developers/docs/resources/guild#get-guild
  # @param guild_id [String, Integer]
  # @return [Guild]
  def get_guild(guild_id)
    response = request(:get, "guilds/#{guild_id}")
    Rapture::Guild.from_json(response.body)
  end

  # Modify a guild's settings
  # https://discordapp.com/developers/docs/resources/guild#modify-guild
  # @param guild_id [String, Integer]
  # @option params [String] :name
  # @option params [String] :region
  # @option params [Integer] :verification_level
  # @option params [Integer] :default_message_notification
  # @option params [Integer] :explicit_content_filter
  # @option params [String, Integer] :afk_channel_id
  # @option params [Integer] :afk_timeout
  # @option params [String] :icon
  # @option params [String, Integer] :owner_id
  # @option params [String] :splash
  # @option params [String, Integer] :system_channel_id
  # @param reason [String]
  # @return [Guild] updated {Guild} object
  def modify_guild(guild_id, reason: nil, **params)
    response = request(
      :patch,
      "guilds/#{guild_id}",
      params,
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Guild.from_json(response.body)
  end

  # Delete a guild. User must be the owner
  # https://discordapp.com/developers/docs/resources/guild#delete-guild
  # @param guild_id [String, Integer]
  def delete_guild(guild_id)
    request(:delete, "guilds/#{guild_id}")
  end

  # Returns a list of {Array<Channel>} for a given guild.
  # https://discordapp.com/developers/docs/resources/guild#get-guild-channels
  # @param guild_id [String, Integer]
  # @return [Guild]
  def get_guild_channel(guild_id)
    response = request(:get, "guilds/#{guild_id}/channels")
    Rapture::Guild.from_json(response.body)
  end

  # Create a new channel for a guild.
  # https://discordapp.com/developers/docs/resources/guild#create-guild-channel
  # @param guild_id [String, Integer]
  # @param name [String]
  # @option params [String] :name
  # @option params [Integer] :type
  # @option params [String] :topic
  # @option params [Integer] :bitrate
  # @option params [Integer] :user_limit
  # @option params [Integer] :rate_limit_per_user
  # @option params [Integer] :position
  # @option params [Array<Guild::Overwrite>] :permission_overwrites
  # @option params [String, Integer] :parent_id
  # @option params [true, false] :nsfw
  # @param reason [String]
  def create_guild_channel(guild_id, name:, reason: nil, **params)
    params[:name] = name
    response = request(
      :post,
      "guilds/#{guild_id}/channels",
      params,
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
    response = request(:get, "guilds/#{guild_id}/members/#{user_id}")
    Rapture::Member.from_json(response.body)
  end

  # {Array<Member>} of members in a guild
  # https://discordapp.com/developers/docs/resources/guild#list-guild-members
  # @param guild_id [String, Integer]
  # @param limit [Integer]
  # @param after [String, Integer]
  # @return [Array<Member>]
  def list_guild_members(guild_id, limit: 1, after: 0)
    query = URI.encode_www_form(limit: limit, after: after)
    response = request(:get, "guilds/#{guild_id}/members?" + query)
    Rapture::Member.from_json_array(response.body)
  end

  # Add a user to the guild using an access token.
  # https://discordapp.com/developers/docs/resources/guild#add-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param access_token [String]
  # @option params [String] :nick
  # @option params [Array<String, Integer>] :roles
  # @option params [true, false] :mute
  # @option params [true, false] :deaf
  # @return [Member, nil] `nil` if the user is already a member of the guild
  def add_guild_member(guild_id, user_id, access_token:, **params)
    params[:access_token] = access_token

    response = request(
      :put,
      "guilds/#{guild_id}/members/#{user_id}",
      params,
    )

    return nil if response.status == 204

    Rapture::Member.from_json(response.body)
  end

  # Modify attributes of a guild member
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-member
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @option params [String] :nick
  # @option params [Array<String, Integer>] :roles
  # @option params [true, false] :mute
  # @option params [true, false] :deaf
  # @option params [String, Integer, nil] :channel_id
  # @param reason [String]
  def modify_guild_member(guild_id, user_id, reason: nil, **params)
    request(
      :patch,
      "guilds/#{guild_id}/members/#{user_id}",
      params,
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
    response = request(:get, "guilds/#{guild_id}/bans")
    Ban.from_json_array(response.body)
  end

  # Get the {Ban} object for a given user
  # https://discordapp.com/developers/docs/resources/guild#get-guild-ban
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @return [Ban]
  def get_guild_ban(guild_id, user_id)
    response = request(:get, "guilds/#{guild_id}/bans/#{user_id}")
    Ban.from_json(response.body)
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
    response = request(:get, "guilds/#{guild_id}/roles")
    Rapture::Role.from_json_array(response.body)
  end

  # Create a new role for the guild
  # https://discordapp.com/developers/docs/resources/guild#create-guild-role
  # @param guild_id [String, Integer]
  # @option params [String] :name
  # @option params [Integer] :permissions
  # @option params [Integer] :color
  # @option params [true, false] :hoist
  # @option params [true, false] :mentionable
  # @param reason [String]
  # @return [Role]
  def create_guild_role(guild_id, reason: nil, **params)
    response = request(
      :post,
      "guilds/#{guild_id}/roles",
      params,
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
      :patch,
      "guilds/#{guild_id}/roles",
      positions,
      'X-Audit-Log-Reason': reason,
    )

    Role.from_json_array(response.body)
  end

  # Modify a guild role
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-role
  # @param guild_id [String, Integer]
  # @param role_id [String, Integer]
  # @option params [String] :name
  # @option params [Integer] :permissions
  # @option params [Integer] :color
  # @option params [true, false] :hoist
  # @option params [true, false] :mentionable
  # @param reason [String]
  # @return [Role]
  def modify_guild_role(guild_id, role_id, **params)
    response = request(
      :patch,
      "guilds/#{guild_id}/roles/#{role_id}",
      params,
      'X-Audit-Log-Reason': reason,
    )

    Rapture::Role.from_json(response.body)
  end

  # Delete a guild role
  # https://discordapp.com/developers/docs/resources/guild#delete-guild-role
  # @param guild_id [String, Integer]
  # @param role_id [String, Integer]
  # @param reason [String]
  def delete_guild_role(guild_id, role_id)
    request(
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
    response = request(:get, "guilds/#{guild_id}/prune")
    Oj.load(response.body)["pruned"]
  end

  # Begin a prune operation
  # https://discordapp.com/developers/docs/resources/guild#begin-guild-prune
  # @param guild_id [String, Integer]
  # @param days [Integer]
  # @param compute_prune_count [true, false]
  # @return [Integer, nil]
  def begin_guild_prune(guild_id, days: nil, compute_prune_count: nil)
    query = URI.encode_www_form(days: days, compute_prune_count: compute_prune_count)
    response = request(
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
    response = request(:get, "guilds/#{guild_id}/regions")
    Voice::Region.from_json_array(response.body)
  end

  # A list of {Integration} objects for a guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-integrations
  # @param guild_id [String, Integer]
  # @return [Array<Integration>]
  def get_guild_integrations(guild_id)
    response = request(:get, "guilds/#{guild_id}/integrations")
    Integration.from_json_array(response.body)
  end

  # Attach an integration object from the current user to the guild
  # https://discordapp.com/developers/docs/resources/guild#create-guild-integration
  # @param guild_id [String, Integer]
  # @param type [String]
  # @param id [String, Integer]
  def create_guild_integration(guild_id, type:, id:)
    request(
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
      :delete,
      "guilds/#{guild_id}/integrations/#{integration_id}"
    )
  end

  def sync_guild_integration(guild_id, integration_id)
    request(
      :post,
      "guilds/#{guild_id}/integrations/#{integration_id}/sync"
    )
  end

  # Get the guild embed object
  # https://discordapp.com/developers/docs/resources/guild#get-guild-embed
  # @param guild_id [String, Integer]
  # @return [Guild::Embed]
  def get_guild_embed(guild_id)
    response = request(:get, "guilds/#{guild_id}/embed")
    Guild::Embed.from_json(response.body)
  end

  # Modify a guild embed
  # https://discordapp.com/developers/docs/resources/guild#modify-guild-embed
  # @param guild_id [String, Integer]
  # @option params [true, false] :enabled
  # @option params [String, Integer] :channel_id
  def modify_guild_embed(guild_id, **params)
    response = request(
      :patch,
      "guilds/#{guild_id}/embed",
      params
    )
    Guild::Embed.from_json(response.body)
  end

  # The vanity url for guilds with the feature enabled
  # https://discordapp.com/developers/docs/resources/guild#get-guild-vanity-url
  # @param guild_id [String, Integer]
  # @return [String, nil]
  def get_guild_vanity_url(guild_id)
    response = request(:get, "guilds/#{guild_id}/vanity-url")
    Oj.load(response.body)["code"]
  end

  # Returns a PNG image widget for the guild
  # https://discordapp.com/developers/docs/resources/guild#get-guild-widget-image
  # @param guild_id [String, Integer]
  # @todo
  def get_guild_widget_image(guild_id, style: nil)
    request(:get, "guilds/#{guild_id}/widget.png?" + style)
  end
end
