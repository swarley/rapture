# frozen_string_literal: true

require "rapture"

client = Rapture::Client.new(ENV["RAPTURE_EXAMPLE_TOKEN"])

# Handler for when a new message is created
client.on_message_create do |message|
  if message.content == "!ping"
    client.create_message(message.channel_id, content: "Pong!")
  end
end

client.run
