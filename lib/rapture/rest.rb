# frozen_string_literal: true

require 'rapture/mappings/user'
require 'rapture/mappings/gateway'

# Binding to Discord's HTTPS REST API
module Rapture::REST
  include Rapture::HTTP

  # Gets the current working gateway URL
  #
  # @return [GatewayInfo]
  def get_gateway
    response = request(:get, 'gateway')
    Rapture::GatewayInfo.from_json(response.body)
  end

  # Gets the current working gateway URL, with additional sharding
  # recommendation
  #
  # @return [GatewayInfo]
  def get_gateway_bot
    response = request(:get, 'gateway/bot')
    Rapture::GatewayInfo.from_json(response.body)
  end

  # Returns a {User} object for a given user ID.
  # https://discordapp.com/developers/docs/resources/user#get-user
  # @return [User]
  def get_user(id)
    response = request(:get, "users/#{id}")
    Rapture::User.from_json(response.body)
  end

  # Returns the {User} associated with the current authorization token.
  # https://discordapp.com/developers/docs/resources/user#get-current-user
  # @return [User]
  def get_current_user
    get_user('@me')
  end
end
