# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  # List of emoji for a given guild.
  # https://discordapp.com/developers/docs/resources/emoji#list-guild-emojis
  # @param guild_id [String, Integer]
  # @return [Array<Emoji>]
  def list_guild_emojis(guild_id)
    response = request(:get, "guilds/#{guild_id}/emojis")
    Emoji.from_json_array(response.data)
  end

  # Get an emoji from a guild by its ID
  # https://discordapp.com/developers/docs/resources/emoji#get-guild-emoji
  def get_guild_emoji(guild_id, emoji_id)
    response = request(:get, "guilds/#{guild_id}/emojis/#{emoji_id}")
    Emoji.from_json(response.body)
  end

  # Create a new emoji for a guild
  # https://discordapp.com/developers/docs/resources/emoji#create-guild-emoji
  def create_guild_emoji(guild_id, name:, image:, roles: [])
    response = request(
      :post,
      "guilds/#{guild_id}/emojis",
      name: name, image: image, roles: roles,
    )
    Emoji.from_json(response.body)
  end

  # Modify a given emoji
  # https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji
  def modify_guild_emoji(guild_id, emoji_id, name: nil, roles: nil)
    response = request(
      :patch,
      "guilds/#{guild_id}/emojis/#{emoji_id}",
      {name: name, roles: roles}.compact
    )
    Emoji.from_json(response.body)
  end

  # Delete a given emoji
  # https://discordapp.com/developers/docs/resources/emoji#delete-guild-emoji
  def delete_guild_emoji(guild_id, emoji_id)
    request(:delete, "guilds/#{guild_id}/emojis/#{emoji_id}")
  end
end
