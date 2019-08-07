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
require "rapture/errors"
require "rapture/http"
require "rapture/rest"
require "rapture/websocket"
require "rapture/client"

# Main module containing Rapture data types and methods
module Rapture
end
