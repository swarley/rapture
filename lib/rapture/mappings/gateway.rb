# frozen_string_literal: true

require "rapture/mappings/user"
require "rapture/mappings/member"
require "rapture/mappings/permissions"
require "rapture/mappings/channel"

module Rapture
  # Information about the location of Discord's gateway host
  class GatewayInfo
    include Mapping

    # @return [String] the URL of the gateway
    getter :url

    # @return [Integer, nil] the recommended amount of shards for this client
    getter :shards
  end

  # Module containing gateway specific events and data structures
  module Gateway
    # A user's status (online, idle, or dnd)
    # https://discordapp.com/developers/docs/topics/gateway#client-status-object
    class ClientStatus
      include Mapping

      # @!attribute [r] desktop
      # @return [String, nil]
      getter :desktop

      # @!attribute [r] mobile
      # @return [String, nil]
      getter :mobile

      # @!attribute [r] web
      # @return [String, nil]
      getter :web
    end

    # Sent when a user's presence or info is updated
    # https://discordapp.com/developers/docs/topics/gateway#presence-update-presence-update-event-fields
    class PresenceUpdate
      include Mapping

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User

      # @!attribute [r] roles
      # @return [Array<Integer>]
      getter :roles, from_json: Converters.Snowflake

      # @!attribute [r] game
      # @return [Activity, nil]
      getter :game, from_json: Activity

      # @!attribute [r] guild_id
      # @return [Integer]
      getter :guild_id, converter: Converters.Snowflake

      # @!attribute [r] status
      # @return [String]
      getter :status

      # @!attribute [r] activities
      # @return [Array<Activity>]
      getter :activities, from_json: Activity

      # @!attribute [r] client_status
      # @return [ClientStatus]
      getter :client_status, from_json: ClientStatus
    end
  end
end
