# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Create a new webhook
  # https://discordapp.com/developers/docs/resources/webhook#create-webhook
  # @param channel_id [String, Integer]
  # @param name [String]
  # @param avatar [String] data URI String
  # @param reason [String]
  # @return [Webhook]
  def create_webhook(channel_id, name:, avatar: nil, reason: nil)
    response = request(
      :channels_cid_webhooks, channel_id,
      :post,
      "channels/#{channel_id}/webhooks",
      {name: name, avatar: avatar},
      'X-Audit-Log-Reason': reason,
    )

    Rapture::Webhook.from_json(response.body)
  end

  # Return a list of webhooks for a channel
  # https://discordapp.com/developers/docs/resources/webhook#get-channel-webhooks
  # @param channel_id [String, Integer]
  # @return [Array<Webhook>]
  def get_channel_webhooks(channel_id)
    response = request(
      :channels_cid_webhooks, channel_id,
      :get,
      "channels/#{channel_id}/webhooks"
    )
    Rapture::Webhook.from_json_array(response.body)
  end

  # Return a list of webhooks for a guild
  # https://discordapp.com/developers/docs/resources/webhook#get-guild-webhooks
  # @param guild_id [String, Integer]
  # @return [Array<Webhook>]
  def get_guild_webhooks(guild_id)
    response = request(
      :guilds_gid_webhooks, guild_id,
      :get,
      "guilds/#{guild_id}/webhooks"
    )
    Rapture::Webhook.from_json_array(response.body)
  end

  # Return a webhook for the given ID
  # https://discordapp.com/developers/docs/resources/webhook#get-webhook
  # @param webhook_id [String, Integer]
  # @return [Webhook]
  def get_webhook(webhook_id)
    response = request(
      :webhooks_wid, webhook_id,
      :get,
      "webhooks/#{webhook_id}"
    )
    Rapture::Webhook.from_json(response.body)
  end

  # Get a webhook but does not require authentication and returns
  # no {User} in the {Webhook} object
  # @param webhook_id [String, Integer]
  # @param webhook_token [String]
  # @return [Webhook]
  def get_webhook_with_token(webhook_id, webhook_token)
    response = request(
      :webhooks_wid_wt, webhook_id,
      :get,
      "webhooks/#{webhook_id}/#{webhook_token}"
    )
    Rapture::Webhook.from_json(response.body)
  end

  # Modify a webhook
  # https://discordapp.com/developers/docs/resources/webhook#modify-webhook
  # @param webhook_id [String, Integer]
  # @option params [String] :name
  # @option params [String] :avatar
  # @option channel_id [String, Integer] channel_id
  # @param reason [String]
  # @return [Webhook]
  def modify_webhook(webhook_id, reason: nil, **params)
    response = request(
      :webhooks_wid, webhook_id,
      :patch,
      "webhooks/#{webhook_id}",
      params,
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Webhook.from_json(response.body)
  end

  # Modify a webhook using a token
  # https://discordapp.com/developers/docs/resources/webhook#modify-webhook-with-token
  # @param webhook_id [String, Integer]
  # @param webhook_token [String]
  # @option params [String] :name
  # @option params [String] :avatar
  # @option channel_id [String, Integer] channel_id
  # @param reason [String]
  # @return [Webhook]
  def modify_webhook_with_token(webhook_id, webhook_token, reason: nil, **params)
    response = request(
      :webhooks_wid_wt, webhook_id,
      :patch,
      "webhooks/#{webhook_id}/#{webhook_token}",
      params,
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Webhook.from_json(response.body)
  end

  # Delete a webhook
  # https://discordapp.com/developers/docs/resources/webhook#delete-webhook
  # @param webhook_id [String, Integer]
  # @param reason [String]
  def delete_webhook(webhook_id, reason: nil)
    request(
      :webhooks_wid, webhook_id,
      :delete,
      "webhooks/#{webhook_id}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
  end

  # Delete a webhook with a token
  # https://discordapp.com/developers/docs/resources/webhook#delete-webhook-with-token
  # @param webhook_id [String, Integer]
  # @param webhook_token [String]
  # @param reason [String]
  def delete_webhook_with_token(webhook_id, webhook_token, reason: nil)
    request(
      :webhooks_wid_wt, webhook_id,
      :delete,
      "webhook/#{webhook_id}/#{webhook_token}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
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
        payload_json: params.to_json,
      }
    else
      payload = params
    end

    request(
      :webhooks_wid_wt, webhook_id,
      :post,
      "webhooks/#{webhook_id}/#{webhook_token}?wait=#{wait}",
      payload
    )
  end
end
