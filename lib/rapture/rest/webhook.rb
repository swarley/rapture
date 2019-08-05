# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  # Create a new webhook
  # https://discordapp.com/developers/docs/resources/webhook#create-webhook
  def create_webhook(channel_id, name:, avatar: nil)
    response = request(
      :post,
      "channels/#{channel_id}/webhooks",
      name: name, avatar: avatar
    )

    Webhook.from_json(response.body)
  end

  # Return a list of webhooks for a channel
  # https://discordapp.com/developers/docs/resources/webhook#get-channel-webhooks
  def get_channel_webhooks(channel_id)
    response = request(:get, "channels/#{channel_id}/webhooks")
    Webhook.from_json_array(response.body)
  end

  # Return a list of webhooks for a guild
  # https://discordapp.com/developers/docs/resources/webhook#get-guild-webhooks
  def get_guild_webhooks(guild_id)
    response = request(:get, "guilds/#{guild_id}/webhooks")
    Webhook.from_json_array(response.body)
  end

  # Return a webhook for the given ID
  # https://discordapp.com/developers/docs/resources/webhook#get-webhook
  def get_webhook(webhook_id)
    Webhook.from_json request(:get, "webhooks/#{webhook_id}").body
  end

  # Get a webhook but does not require authentication and returns
  # no {User} in the {Webhook} object
  def get_webhook_with_token(webhook_id, webhook_token)
    Webhook.from_json request(:get, "webhooks/#{webhook_id}/#{webhook_token}").body
  end

  # Modify a webhook
  # https://discordapp.com/developers/docs/resources/webhook#modify-webhook
  def modify_webhook(webhook_id, name: nil, avatar: nil, channel_id: nil)
    response = request(
      :patch,
      "webhooks/#{webhook_id}",
      name: name, avatar: avatar, channel_id: channel_id
    )
    Webhook.from_json(response.body)
  end

  # Modify a webhook using a token
  # https://discordapp.com/developers/docs/resources/webhook#modify-webhook-with-token
  def modify_webhook_with_token(webhook_id, webhook_token, name: nil, avatar: nil, channel_id: nil)
    response = request(
      :patch,
      "webhooks/#{webhook_id}/#{webhook_token}",
      name: name, avatar: avatar, channel_id: channel_id
    )
    Webhook.from_json(response.body)
  end

  # Delete a webhook
  # https://discordapp.com/developers/docs/resources/webhook#delete-webhook
  def delete_webhook(webhook_id)
    request(:delete, "webhooks/#{webhook_id}")
  end

  # Delete a webhook with a token
  # https://discordapp.com/developers/docs/resources/webhook#delete-webhook-with-token
  def delete_webhook_with_token(webhook_id, webhook_token)
    request(:delete, "webhook/#{webhook_id}/#{webhook_token}")
  end

  # @todo wait documentation and response support
  # Execute a payload
  # https://discordapp.com/developers/docs/resources/webhook#execute-webhook
  # @param webhook_id [String, Integer]
  # @param webhook_token [String]
  # @param wait [true, false]
  # @option params [String] :content
  # @option params [String] :username
  # @option params [String] :avatar_url
  # @option params [true, false] :tts
  # @option params [String, IO] :file path to a file or IO
  # @option params [Array<Embed, Hash>] :embeds
  def execute_webhook(webhook_id, webhook_token, wait: false, **params)
    if params[:file]
      file = params.delete(:file)
      payload = {
        file: file,
        payload_json: params.to_json
      }
    else
      payload = params
    end

    request(
      :post,
      "webhooks/#{webhook_id}/#{webhook_token}?wait=#{wait}",
      payload
    )
  end
end