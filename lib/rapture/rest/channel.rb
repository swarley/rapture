# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Returns a {Channel} object for a given channel ID
  # https://discordapp.com/developers/docs/resources/channel#get-channel
  # @param channel_id [String, Integer]
  # @return [Channel]
  def get_channel(channel_id)
    response = request(
      :channels_cid, channel_id,
      :get,
      "channels/#{channel_id}"
    )
    Rapture::Channel.from_json(response.body)
  end

  # Update a channel's settings
  # https://discordapp.com/developers/docs/resources/channel#modify-channel
  # @param channel_id [String, Integer]
  # @param name [String]
  # @param position [Integer]
  # @param topic [String]
  # @param nsfw [true, false]
  # @param rate_limit_per_user [Integer] :rate_limit_per_user
  # @param bitrate [Integer]
  # @param user_limit [Integer]
  # @param permission_overwrites [Array<Guild::Overwrite>]
  # @param parent_id [Integer, String]
  # @param reason [String]
  # @return [Channel] updated channel object
  def modify_channel(channel_id,
                     reason: nil, name: nil, position: nil, topic: nil, nsfw: nil, rate_limit_per_user: nil,
                     bitrate: nil, user_limit: nil, permission_overwrites: nil, parent_id: nil)
    response = request(
      :channels_cid, channel_id,
      :patch,
      "channels/#{channel_id}",
      {name: name, position: position, topic: topic, nsfw: nsfw, rate_limit_per_user: rate_limit_per_user,
       bitrate: bitrate, user_limit: user_limit, permission_overwrites: permission_overwrites, parent_id: parent_id},
      "X-Audit-Log-Reason": reason,
    )

    Rapture::Channel.from_json(response.body)
  end

  # Delete a channel, or close a DM. Channels cannot be recovered when
  # deleted, but a DM may be reopened.
  # https://discordapp.com/developers/docs/resources/channel#deleteclose-channel
  # @param channel_id [String, Integer]
  # @param reason [String]
  # @return [Channel] the deleted channel object
  def delete_channel(channel_id, reason: nil)
    response = request(
      :channels_cid, channel_id,
      :delete,
      "channels/#{channel_id}",
      nil,
      "X-Audit-Log-Reason": reason,
    )

    Rapture::Channel.from_json(response.body)
  end

  # Return messages for a channel. This endpoint requires `VIEW_CHANNEL`
  # permission. This endpoint will return no messages unless the user has `READ_MESSAGE_HISTORY`
  # permission.
  # @param channel_id [String, Integer]
  # @param around [String, Integer]
  # @param before [String, Integer]
  # @param after [String, Integer]
  # @param limit [Integer] The maximum amount of messages to retrieve.
  # @return [Array<Message>]
  def get_channel_messages(channel_id, limit: nil, around: nil, before: nil, after: nil)
    query = URI.encode_www_form({limit: limit, around: around, before: before, after: after}.compact)
    response = request(
      :channels_cid_messages, channel_id,
      :get,
      "channels/#{channel_id}/messages?#{query}",
    )

    Rapture::Message.from_json_array(response.body)
  end

  # Creates a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#create-message
  # @note One of `file`, `content`, or `embed` must be passed.
  # @param channel_id [String, Integer]
  # @param content [String]
  # @param embed [Embed]
  # @param tts [true, false]
  # @param file [Faraday::UploadIO]
  # @return [Message] the created message
  def create_message(channel_id, content: nil, embed: nil, tts: nil, file: nil)
    payload = {content: content, embed: embed, tts: tts}

    if file
      payload = {
        file: file,
        payload_json: Rapture.encode_json(payload),
      }
    end

    response = request(
      :channels_cid_messages, channel_id,
      :post,
      "channels/#{channel_id}/messages",
      payload
    )

    Rapture::Message.from_json(response.body)
  end

  # Set the embed suppression value for this post. Embed suppression can be disabled
  # with a suppress value of `false`
  # @todo docs link
  # @param channel_id [Integer]
  # @param message_id [Integer]
  # @param suppress [true, false]
  # @return [true, false] if the action was successful
  def suppress_message_embeds(channel_id, message_id, suppress: true)
    request(
      :channels_cid_messages_mid_suppress_embeds, channel_id,
      :post,
      "channels#{channel_id}/messages/#{message_id}/suppress-embeds",
      suppress: suppress
    ).status == 204
  end

  # Edits a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#edit-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param content [String, nil]
  # @param embed [Embed, nil]
  # @return [Message] the edited message
  def edit_message(channel_id, message_id, content: nil, embed: nil)
    response = request(
      :channels_cid_messages_mid, channel_id,
      :patch,
      "channels/#{channel_id}/messages/#{message_id}",
      content: content, embed: embed,
    )
    Rapture::Message.from_json(response.body)
  end

  # Deletes a message in a channel.
  # https://discordapp.com/developers/docs/resources/channel#delete-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def delete_message(channel_id, message_id, reason: nil)
    request(
      :channels_cid_messages_mid, channel_id,
      :delete,
      "channels/#{channel_id}/messages/#{message_id}",
      nil,
      "X-Audit-Log-Reason": reason,
    )
  end

  # Delete multiple messages in a single request. Only for guild channels.
  # https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages
  # @param channel_id [String, Integer]
  # @param messages [Array<Integer, String>] message IDs to be deleted.
  def bulk_delete_messages(channel_id, messages, reason: nil)
    request(
      :channels_cid_messages_bulk_delete, channel_id,
      :post,
      "channels/#{channel_id}/messages/bulk-delete",
      {messages: messages},
      "X-Audit-Log-Reason": reason,
    )
  end

  # Create a reaction on a message.
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  def create_reaction(channel_id, message_id, emoji)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(
      :channels_cid_messages_mid_reactions_emoji_me, channel_id,
      :put,
      "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"
    )
  end

  # Delete a reaction from the current user.
  # https://discordapp.com/developers/docs/resources/channel#delete-own-reaction
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  def delete_own_reaction(channel_id, message_id, emoji)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(
      :channels_cid_messages_mid_reactions_emoji_me, channel_id,
      :delete,
      "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"
    )
  end

  # Delete a user's reaction.
  # https://discordapp.com/developers/docs/resources/channel#delete-own-reaction
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  # @param emoji [String] `name:id` for custom emoji, or a unicode representation.
  # @param user_id [String, Integer]
  # @param reason [String]
  def delete_user_reaction(channel_id, message_id, emoji, user_id, reason: nil)
    emoji = URI.encode_www_form_component(emoji) unless emoji.ascii_only?

    request(
      :channels_cid_messages_mid_reactions_emoji_uid, channel_id,
      :delete,
      "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}",
      nil,
      "X-Audit-Log-Reason": reason,
    )
  end

  # Delete all reactions on a message.
  # https://discordapp.com/developers/docs/resources/channel#delete-all-reactions
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def delete_all_reactions(channel_id, message_id)
    request(
      :channels_cid_messages_mid_reactions, channel_id,
      :delete,
      "channels/#{channel_id}/messages/#{message_id}/reactions"
    )
  end

  # Edit permission overwrites for a user or role in a channel.
  # https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions
  # @param channel_id [String, Integer]
  # @param overwrite_id [String, Integer]
  # @param allow [Integer] bitwise value of all allowed permissions
  # @param deny [Integer] bitwise value of all denied permissions
  # @param type [String] `"member"` or `"role"`
  def edit_channel_permissions(channel_id, overwrite_id, allow:, deny:, type:, reason: nil)
    request(
      :channels_cid_permissions_oid, channel_id,
      :put,
      "channel/#{channel_id}/permissions/#{overwrite_id}",
      {allow: allow, deny: deny, type: type},
      "X-Audit-Log-Reason": reason,
    )
  end

  # List of invites for a channel
  # https://discordapp.com/developers/docs/resources/channel#get-channel-get_channel_invites
  # @param channel_id [String, Integer]
  # @return [Array<Invite>]
  def get_channel_invites(channel_id)
    response = request(
      :channels_cid_invites, channel_id,
      :get, "channels/#{channel_id}/invites"
    )
    Rapture::Invite.from_json_array(response.body)
  end

  # Create a new invite for a channel
  # https://discordapp.com/developers/docs/resources/channel#create-channel-invite
  # @param channel_id [String, Integer]
  # @param max_age [Integer]
  # @param max_uses [Integer]
  # @param temporary [true, false]
  # @param unique [true, false]
  # @param reason [String]
  def create_channel_invite(channel_id, reason: nil, max_age: nil, max_uses: nil, temporary: nil, unique: nil)
    response = request(
      :channels_cid_invites, channel_id,
      :post,
      "channels/#{channel_id}/invites",
      {max_age: max_age, max_uses: max_uses, temporary: temporary, unique: unique},
      "X-Audit-Log-Reason": reason,
    )

    Rapture::Invite.from_json(response.body)
  end

  # Delete a channel permission overwrite
  # https://discordapp.com/developers/docs/resources/channel#delete-channel-permission
  # @param channel_id [String, Integer]
  # @param overwrite_id [String, Integer]
  def delete_channel_permission(channel_id, overwrite_id, reason: nil)
    request(
      :channels_cid_permissions_oid, channel_id,
      :delete,
      "channels/#{channel_id}/permissions/#{overwrite_id}",
      nil,
      "X-Audit-Log-Reason": reason,
    )
  end

  # Trigger a typing indicator for a channel
  # https://discordapp.com/developers/docs/resources/channel#trigger-typing-indicator
  # @param channel_id [String, Integer]
  def trigger_typing_indicator(channel_id)
    request(
      :channels_cid_typing, channel_id,
      :post,
      "channels/#{channel_id}/typing"
    )
  end

  # Returns all pinned messages in the channel
  # https://discordapp.com/developers/docs/resources/channel#get-pinned-messages
  # @param channel_id [String, Integer]
  # @return [Array<Message>]
  def get_pinned_messages(channel_id)
    response = request(
      :channels_cid_pins, channel_id,
      :get,
      "channels/#{channel_id}/pins"
    )
    Rapture::Message.from_json_array(response.body)
  end

  # Pin a message in a channel
  # https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def add_pinned_message(channel_id, message_id)
    request(
      :channels_cid_pins_mid, channel_id,
      :put,
      "channels/#{channel_id}/pins/#{message_id}"
    )
  end

  # Delete a pinned message in a channel
  # https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message
  # @param channel_id [String, Integer]
  # @param message_id [String, Integer]
  def delete_pinned_message(channel_id, message_id)
    request(
      :channels_cid_pins_mid, channel_id,
      :delete,
      "channels/#{channel_id}/pins/#{message_id}"
    )
  end

  # Adds a recipient to a group DM using their access token
  # https://discordapp.com/developers/docs/resources/channel#group-dm-add-recipient
  # @param channel_id [String, Integer]
  # @param user_id [String, Integer]
  # @param access_token [String]
  # @param nick [String]
  def add_group_dm_recipient(channel_id, user_id, access_token:, nick: nil)
    request(
      :channels_cid_recipients_uid, channel_id,
      :put,
      "channels/#{channel_id}/recipients/#{user_id}",
      access_token: access_token, nick: nick,
    )
  end

  # Remove a recipient from a group DM
  # https://discordapp.com/developers/docs/resources/channel#group-dm-remove-recipient
  # @param channel_id [String, Integer]
  # @param user_id [String, Integer]
  def delete_group_dm_recipient(channel_id, user_id)
    request(
      :channels_cid_recipients_uid, channel_id,
      :delete, "channels/#{channel_id}/recipients/#{user_id}"
    )
  end
end
