# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  # Returns a {Channel} object for a given channel ID
  # https://discordapp.com/developers/docs/resources/channel#get-channel
  # @return [Channel]
  def get_channel(id)
    response = request(:get, "channels/#{id}")
    Rapture::Channel.from_json(response.body)
  end

  # Update a channel's settings
  # https://discordapp.com/developers/docs/resources/channel#modify-channel
  # @param channel_id [String, Integer]
  # @param params [Hash]
  # @option params [String] :name
  # @option params [Integer] :position
  # @option params [String] :topic
  # @option params [true, false] :nsfw
  # @option params [Integer] :rate_limit_per_user
  # @option params [Integer] :bitrate
  # @option params [Integer] :user_limit
  # @option params [Array<Overwrite>] :permission_overwrites
  # @option params [Integer, String] :parent_id
  # @return [Channel] updated channel object
  def modify_channel(channel_id, **params)
    response = request(
      :patch,
      "channels/#{channel_id}",
      **params,
    )

    Rapture::Channel.from_json(response.body)
  end

  # Delete a channel, or close a DM. Channels cannot be recovered when
  # deleted, but a DM may be reopened.
  # https://discordapp.com/developers/docs/resources/channel#deleteclose-channel
  # @param channel_id [String, Integer]
  def delete_channel(channel_id)
    response = request(:delete, "channels/#{channel_id}")
    Channel.from_json(response.body)
  end

  # Return messages for a channel. This endpoint requires `VIEW_CHANNEL`
  # permission. This endpoint will return no messages unless the user has `READ_MESSAGE_HISTORY`
  # permission.
  # @param channel_id [String, Integer]
  # @param around [String, Integer]
  # @param before [String, Integer]
  # @param after [String, Integer]
  # @param limit [Integer]
  # @return [Array<Message>]
  def get_channel_messages(channel_id, around: nil, before: nil, after: nil, limit: nil)
    params = {around: around, before: before, after: after, limit: limit}.compact
    response = request(
      :get,
      "channels/#{channel_id}/messages?#{URI.encode_www_form(params)}",
    )

    Rapture::Message.from_json_array(response.body)
  end

  # Creates a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#create-message
  # @return [Message] the created message
  def create_message(channel_id, content: nil, embed: nil, tts: false, file: nil)
    payload = {content: content, embed: embed, tts: tts}

    if file
      file = Faraday::UploadIO.new(file, MIME::Types.type_for(file).first)
      payload = {
        file: file,
        payload_json: Oj.dump(payload),
      }
    end

    response = request(
      :post,
      "channels/#{channel_id}/messages",
      payload
    )

    Rapture::Message.from_json(response.body)
  end

  # Edits a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#edit-message
  # @return [Message] the edited message
  def edit_message(channel_id, message_id, content: nil, embed: nil)
    response = request(
      :patch,
      "channels/#{channel_id}/messages/#{message_id}",
      content: content, embed: embed,
    )
    Rapture::Message.from_json(response.body)
  end

  # Deletes a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#delete-message
  def delete_message(channel_id, message_id)
    request(:delete, "channels/#{channel_id}/messages/#{message_id}")
  end

  # Delete multiple messages in a single request. Only for guild channels.
  # https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages
  # @param channel_id [String, Integer]
  # @param messages [Array<Integer, String>] message IDs to be deleted.
  def bulk_delete_messages(channel_id, messages)
    request(:post, "channels/#{channel_id}/messages/bulk-delete", messages: messages)
  end

  # Create a reaction on a message.
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  def create_reaction(channel_id, message_id, emoji)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(:put, "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me")
  end

  # Delete a reaction from the current user.
  # https://discordapp.com/developers/docs/resources/channel#delete-own-reaction
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  def delete_own_reaction(channel_id, message_id, emoji)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(:delete, "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me")
  end

  # Delete a user's reaction.
  # https://discordapp.com/developers/docs/resources/channel#delete-own-reaction
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  # @param user_id [String, Integer]
  def delete_user_reaction(channel_id, message_id, emoji, user_id)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(:delete, "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}")
  end

  # Delete all reactions on a message.
  # https://discordapp.com/developers/docs/resources/channel#delete-all-reactions
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def delete_all_reactions(channel_id, message_id)
    request(:delete, "channels/#{channel_id}/messages/#{message_id}")
  end

  # Edit permission overwrites for a user or role in a channel.
  # https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions
  # @param channel_id [String, Integer]
  # @param overwrite_id [String, Integer]
  # @param allow [Integer] bitwise value of all allowed permissions
  # @param deny [Integer] bitwise value of all denied permissions
  # @param type [String] `"member"` or `"role"`
  def edit_channel_permissions(channel_id, overwrite_id, allow:, deny:, type:)
    request(
      :put,
      "channel/#{channel_id}/permissions/#{overwrite_id}",
      allow: allow, deny: deny, type: type,
    )
  end

  # List of invites for a channel
  # https://discordapp.com/developers/docs/resources/channel#get-channel-get_channel_invites
  # @param channel_id [String, Integer]
  # @return [Array<Invite>]
  def get_channel_invites(channel_id)
    response = request(:get, "channels/#{channel_id}/invites")
    Invite.from_json_array(response.body)
  end

  # Create a new invite for a channel
  # https://discordapp.com/developers/docs/resources/channel#create-channel-invite
  # @param channel_id [String, Integer]
  # @param max_age [Integer]
  # @param max_uses [Integer]
  # @param temporary [true, false]
  # @param unique [true, false]
  def create_channel_invite(channel_id, max_age: nil, max_uses: nil, temporary: nil, unique: nil)
    response = request(
      :post,
      "channels/#{channel_id}/invites",
      max_age: max_age, max_uses: max_uses, temporary: temporary, unique: unique,
    )

    Invite.from_json(response.body)
  end

  # Delete a channel permission overwrite
  # https://discordapp.com/developers/docs/resources/channel#delete-channel-permission
  # @param channel_id [String, Integer]
  # @param overwrite_id [String, Integer]
  def delete_channel_permission(channel_id, overwrite_id)
    request(:delete, "channels/#{channel_id}/permissions/#{overwrite_id}")
  end

  # Trigger a typing indicator for a channel
  # https://discordapp.com/developers/docs/resources/channel#trigger-typing-indicator
  # @param channel_id [String, Integer]
  def trigger_typing_indicator(channel_id)
    request(:post, "channels/#{channel_id}/typing")
  end

  # Returns all pinned messages in the channel
  # https://discordapp.com/developers/docs/resources/channel#get-pinned-messages
  # @param channel_id [String, Integer]
  # @return [Array<Message>]
  def get_pinned_messages(channel_id)
    response = request(:get, "channels/#{channel_id}/pins")
    Message.from_json_array(response.body)
  end

  # Pin a message in a channel
  # https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def add_pinned_message(channel_id, message_id)
    request(:put, "channels/#{channel_id}/pins/#{message_id}")
  end

  # Delete a pinned message in a channel
  # https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def delete_pinned_message(channel_id, message_id)
    request(:delete, "channels/#{channel_id}/pins/#{message_id}")
  end

  # Adds a recipient to a group DM using their access token
  # https://discordapp.com/developers/docs/resources/channel#group-dm-add-recipient
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param access_token [String]
  # @param nick [String]
  def add_group_dm_recipient(channel_id, user_ud, access_token:, nick:)
    request(
      :put,
      "channels/#{channel_id}/recipients/#{user_id}",
      access_token: access_token, nick: nick,
    )
  end

  # Remove a recipient from a group DM
  # https://discordapp.com/developers/docs/resources/channel#group-dm-remove-recipient
  def delete_group_dm_recipient(channel_id, user_id)
    request(:delete, "channels/#{channel_id}/recipients/#{user_id}")
  end
end