# frozen_string_literal: true

require "rapture"

client = Rapture::CachedClient.new(ENV["RAPTURE_EXAMPLE_TOKEN"])

def get_current_member(client, guild_id)
  current_user = client.get_current_user
  guild = client.get_guild(guild_id)
  client.get_guild_member(guild_id, current_user.id)
end

client.on_message_create do |message|
  # Fail early, because we can't check permissions in DMs
  next unless message.guild_id

  case message.content
  when "!check_administrator"
    guild = client.get_guild(message.guild_id)
    current_member = get_current_member(client, guild.id)

    response = if guild.compute_permissions(current_member).administrator?
                 "I am an administrator!"
               else
                 "I am not an administrator!"
               end
    client.create_message(message.channel_id, content: response)
  when "!check_kick"
    guild = client.get_guild(message.guild_id)
    current_member = get_current_member(client, guild.id)
    response = if guild.compute_permissions(current_member).kick_members?
                 "I can kick!"
               else
                 "I can't kick!"
               end
    client.create_message(message.channel_id, content: response)
  when "!check_tts_here"
    guild = client.get_guild(message.guild_id)
    current_member = get_current_member(client, guild.id)
    channel = client.get_channel(message.channel_id)
    # Use the optional channel argument to compute permissions taking channel
    # overwrites into consideration
    response = if guild.compute_permissions(current_member, channel).send_tts_messages?
                 "I can tts here!"
               else
                 "I can't tts here!"
               end
    client.create_message(channel.id, content: response)
  end
end

client.run
