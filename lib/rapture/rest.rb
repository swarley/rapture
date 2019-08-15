# frozen_string_literal: true

require "mime/types"
require "rapture/rest/channel"
require "rapture/rest/emoji"
require "rapture/rest/user"
require "rapture/rest/voice"
require "rapture/rest/audit_log"
require "rapture/rest/invite"
require "rapture/rest/oauth"
require "rapture/rest/webhook"
require "rapture/rest/guild"

# Binding to Discord's HTTPS REST API
module Rapture::REST
  include Rapture::HTTP

  # Gets the current working gateway URL
  # https://discordapp.com/developers/docs/topics/gateway#get-gateway
  # @return [GatewayInfo]
  def get_gateway
    response = request(:gateway, nil, :get, "gateway")
    Rapture::GatewayInfo.from_json(response.body)
  end

  # Gets the current working gateway URL, with additional sharding
  # recommendation
  # https://discordapp.com/developers/docs/topics/gateway#get-gateway-bot
  # @return [GatewayInfo]
  def get_gateway_bot
    response = request(:gateway_bot, nil, :get, "gateway/bot")
    Rapture::GatewayInfo.from_json(response.body)
  end
end
