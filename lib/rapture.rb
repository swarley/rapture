# frozen_string_literal: true

require "oj"
require "faraday"
require "faye/websocket"

require "rapture/version"
require "rapture/mapping"
require "rapture/mappings/gateway"
require "rapture/mappings/user"
require "rapture/mappings/message"
require "rapture/mappings/channel"
require "rapture/mappings/invite"
require "rapture/mappings/emoji"
require "rapture/mappings/gateway_events"
require "rapture/mappings/audit_log"
require "rapture/mappings/voice"
require "rapture/mappings/oauth"
require "rapture/errors"
require "rapture/http"
require "rapture/rate_limiter"
require "rapture/rest"
require "rapture/websocket"
require "rapture/cache"
require "rapture/client"
require "rapture/cached_client"
require "rapture/logger"
require "rapture/cdn"

# Main module containing Rapture data types and methods
module Rapture
  # Library wide logging instance
  LOGGER = Rapture::Logger.new(STDOUT)
  LOGGER.level = Logger::INFO

  # Method for removing nil elements and then
  # converting `:null` values to a `nil` value
  # that persists through a json dump
  def self.encode_json(hash)
    hash = hash.compact
    hash.each do |key, value|
      hash[key] = nil if value == :null
    end
    Oj.dump(hash)
  end
end
