# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API

module Rapture::REST
  include Rapture::HTTP

  # Returns a {User} object for a given user ID.
  # https://discordapp.com/developers/docs/resources/user#get-user
  # @param id [String, Integer]
  # @return [User]
  def get_user(id)
    response = request(
      :users_id, id,
      :get,
      "users/#{id}"
    )
    Rapture::User.from_json(response.body)
  end

  # Returns the {User} associated with the current authorization token.
  # https://discordapp.com/developers/docs/resources/user#get-current-user
  # @return [User]
  def get_current_user
    response = request(
      :users_me, nil,
      :get,
      "users/@me"
    )
    Rapture::User.from_json(response.body)
  end

  # Returns an {Array<Guild>} of guilds the current user is a member of.
  # https://discordapp.com/developers/docs/resources/user#get-current-user-guilds
  # @return [Array<Guild>]
  def get_current_user_guilds
    response = request(
      :users_me_guilds, nil,
      :get,
      "users/@me/guilds"
    )
    Rapture::Guild.from_json_array(response.body)
  end

  # Leave a guild
  # https://discordapp.com/developers/docs/resources/user#leave-guild
  # @param guild_id [String, Integer]
  # @return [true, false] whether this action was successful
  def leave_guild(guild_id)
    request(
      :users_me_guilds_gid, nil,
      :delete,
      "users/@me/guilds/#{guild_id}"
    ).status == 204
  end

  # Returns an {Array<Channel>} of DM channels. For bots this will return
  # an empty array.
  # https://discordapp.com/developers/docs/resources/user#get-user-dms
  def get_user_dms
    response = request(
      :users_me_channels, nil,
      :get,
      "users/@me/channels"
    )
    Rapture::Channel.from_json_array(response.body)
  end

  # Create a new DM channel. Returns a {Channel} object
  # https://discordapp.com/developers/docs/resources/user#create-dm
  # @param recipient_id [String, Integer]
  # @return [Channel]
  def create_dm(recipient_id)
    response = request(
      :users_me_channels, nil,
      :post,
      "users/@me/channels",
      recipient_id: recipient_id,
    )
    Rapture::Channel.from_json(response.body)
  end

  # Create a new group DM channel with multiple users.
  # https://discordapp.com/developers/docs/resources/user#create-group-dm
  # @note Groups created with this endpoint will not be shown
  #   in the Discord client.
  # @param access_tokens [Array<String>] tokens of users that have granted
  #   your app the `gdm.join` scope.
  # @param nicks [Hash<String, String>] Hash of `user_id => nickname`
  # @return [Channel]
  def create_group_dm(access_tokens, nicks)
    response = request(
      :users_me_channels, nil,
      :post,
      "users/@me/channels",
      access_tokens: access_tokens, nicks: nicks,
    )

    Rapture::Channel.from_json(response.body)
  end

  # Returns a list of user connections. Requires `connections` scope.
  # https://discordapp.com/developers/docs/resources/user#get-user-connections
  # @return [Array<Rapture::User::Connection>]
  def get_user_connections
    response = request(
      :users_me_connections, nil,
      :get,
      "users/@me/connections"
    )
    Rapture::User::Connection.from_json_array(response.body)
  end
end
