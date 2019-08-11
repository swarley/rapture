# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # List of emoji for a given guild.
  # https://discordapp.com/developers/docs/resources/emoji#list-guild-emojis
  # @param guild_id [String, Integer]
  # @return [Array<Emoji>]
  def list_guild_emojis(guild_id)
    response = request(
      :guilds_gid_emojis, guild_id,
      :get,
      "guilds/#{guild_id}/emojis"
    )
    Rapture::Emoji.from_json_array(response.body)
  end

  # Get an emoji from a guild by its ID
  # https://discordapp.com/developers/docs/resources/emoji#get-guild-emoji
  # @param guild_id [String, Integer]
  # @param emoji_id [String, Integer]
  # @return [Emoji]
  def get_guild_emoji(guild_id, emoji_id)
    response = request(
      :guilds_gid_emojis_eid, guild_id,
      :get,
      "guilds/#{guild_id}/emojis/#{emoji_id}"
    )
    Rapture::Emoji.from_json(response.body)
  end

  # Create a new emoji for a guild
  # https://discordapp.com/developers/docs/resources/emoji#create-guild-emoji
  # @param guild_id [String, Integer]
  # @param name [String]
  # @param image [Faraday::UploadIO]
  # @param roles [Array<String, Integer>] array of role IDs that can use this emoji
  # @param reason [String] for audit log entry
  # @return [Emoji]
  def create_guild_emoji(guild_id, name:, image:, roles: [], reason: nil)
    response = request(
      :guilds_sid_emojis, guild_id,
      :post,
      "guilds/#{guild_id}/emojis",
      {name: name, image: image, roles: roles},
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Emoji.from_json(response.body)
  end

  # Modify a given emoji
  # https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji
  # @param guild_id [String, Integer]
  # @param emoji_id [String, Integer]
  # @option params [String] :name
  # @option params [Array<String, Integer>] :roles array of role IDs that can use this emoji
  # @param reason [String]
  # @return [Emoji]
  def modify_guild_emoji(guild_id, emoji_id, reason: nil, **params)
    response = request(
      :guild_gid_emojis_eid, guild_id,
      :patch,
      "guilds/#{guild_id}/emojis/#{emoji_id}",
      params,
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Emoji.from_json(response.body)
  end

  # Delete a given emoji
  # https://discordapp.com/developers/docs/resources/emoji#delete-guild-emoji
  # @param guild_id [String, Integer]
  # @param emoji_id [String, Integer]
  # @param reason [String]
  def delete_guild_emoji(guild_id, emoji_id, reason: nil)
    request(
      :guilds_gid_emojis_eid, guild_id,
      :delete,
      "guilds/#{guild_id}/emojis/#{emoji_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end
end
