# frozen_string_literal: true

require "rapture"

# We use a cached client to avoid fetching
# the guild object on each join
client = Rapture::CachedClient.new(ENV["RAPTURE_EXAMPLE_TOKEN"])

channel_id = ENV["RAPTURE_WELCOME_CHANNEL"]

# Handler for when a new member is added to the guild
client.on_guild_member_add do |member|
  # use the client to fetch the guild object
  guild = client.get_guild(member.guild_id)

  # If the system channel is set, output the welcome message.
  # Otherwise do nothing
  if guild.system_channel_id
    client.create_message(guild.system_channel_id,
                          content: "Welcome to #{guild.name}, #{member.user.username}!")
  end
end

# Start our bot
client.run
