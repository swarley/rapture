# frozen_string_literal: true

require "rapture/mappings/gateway_events"

module Rapture
  # The `Client` abstracts away the token from making REST API requests
  # and provides a means to connect to Discord's gateway.
  class Client
    include REST

    # @param token [String] token used for authorization, must be prefixed with token type, e.g.
    #   `Bot`, `Bearer`
    # @param shard_key [{Integer, Integer}] the shard key for this connection. See [Sharding](https://discordapp.com/developers/docs/resources/guild#guild-object-premium-tier)
    #   for more information.
    # @param large_threshold [Integer] limit for when the gateway will no longer send offline member data.
    #   Must be between 50 and 250
    def initialize(token, shard_key: [0, 1], large_threshold: 150)
      @type, @token = token.split(" ")
      @shard_key = shard_key
      @large_threshold = large_threshold
      @heartbeat_interval = 1
      @send_heartbeats = false
      @event_handlers = Hash.new { |hash, key| hash[key] = [] }
      setup_heartbeats
    end

    # Initiate a connection to the gateway
    def run
      websocket.run
    end

    # @attribute [r] websocket
    # @return [WebSocket]
    def websocket
      return @websocket if @websocket

      @websocket = WebSocket.new(get_gateway.url)

      @websocket.on_open do |event|
        on_open(event)
      end

      @websocket.on_message do |packet|
        on_message(packet)
      end

      @websocket.on_close do |event|
        on_close(event)
      end

      @websocket
    end

    # @!group Opcodes
    # https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes

    # (Recieve) dispatches an event
    OP_DISPATCH = 0

    # (Send/Recieve) used for ping checking
    OP_HEARTBEAT = 1

    # (Send) used for client handshake
    OP_IDENTIFY = 2

    # (Send) used to update the client status
    OP_STATUS_UPDATE = 3

    # (Send) used to join/move/leave voice channels
    OP_VOICE_STATE_UPDATE = 4

    # (Send)
    OP_VOICE_SERVER_PING = 5

    # (Send) used to resume a closed connection
    OP_RESUME = 6

    # (Recieve) used to tell clients to reconnect to the gateway
    OP_RECONNECT = 7

    # (Send) used to request guild members
    OP_REQUEST_GUILD_MEMBERS = 8

    # (Recieve) used to notify the client they have an invalid session ID
    OP_INVALID_SESSION = 9

    # (Recieve) sent immediately after connecting, contains heartbeat and server debug info
    OP_HELLO = 10

    # (Recieve) sned immediately following a client heartbeat
    OP_HEARTBEAT_ACK = 11

    # @!endgroup

    # Struct used for keeping session data that allows us to `RESUME` on
    # reconnect
    Session = Struct.new(:sequence, :suspend, :invalid, :resume, :id)

    # @!visibility private
    # Dispatch an event to handlers relevant to the payload.
    # `payload` may be any gateway event payload
    def call_handlers(event_type, payload)
      @event_handlers[event_type].dup.each do |handler|
        handler.call(payload)
      end
    end

    # @!visibility private
    def self.__event(name, klass)
      define_method(:"on_#{name}") do |&block|
        handler = lambda do |payload|
          block.call(klass.from_h(payload, :from_json))
        end
        @event_handlers[name.upcase].push(handler)
      end
    end

    # @!group Handler registers

    # @!macro [new] gateway_event
    #   @!method on_$1(&block)
    #     Register a handler to be called when a `$1` event is recieved
    #     @yieldparam [$2] data
    __event(:ready, Gateway::Ready)

    # @!macro gateway_event
    __event(:channel_create, Gateway::ChannelCreate)

    # @!macro gateway_event
    __event(:channel_update, Gateway::ChannelUpdate)

    # @!macro gateway_event
    __event(:channel_delete, Gateway::ChannelDelete)

    # @!macro gateway_event
    __event(:channel_pins_update, Gateway::ChannelPinsUpdate)

    # @!macro gateway_event
    __event(:guild_create, Gateway::GuildCreate)

    # @!macro gateway_event
    __event(:guild_update, Gateway::GuildUpdate)

    # @!macro gateway_event
    __event(:guild_delete, Gateway::GuildDelete)

    # @!macro gateway_event
    __event(:guild_ban_add, Gateway::GuildBanAdd)

    # @!macro gateway_event
    __event(:guild_ban_remove, Gateway::GuildBanRemove)

    # @!macro gateway_event
    __event(:guild_emojis_update, Gateway::GuildEmojisUpdate)

    # @!macro gateway_event
    __event(:guild_integrations_update, Gateway::GuildIntegrationsUpdate)

    # @!macro gateway_event
    __event(:guild_member_add, Gateway::GuildMemberAdd)

    # @!macro gateway_event
    __event(:guild_member_remove, Gateway::GuildMemberRemove)

    # @!macro gateway_event
    __event(:guild_member_update, Gateway::GuildMemberUpdate)

    # @!macro gateway_event
    __event(:guild_members_chunk, Gateway::GuildMembersChunk)

    # @!macro gateway_event
    __event(:guild_role_create, Gateway::GuildRoleCreate)

    # @!macro gateway_event
    __event(:guild_role_update, Gateway::GuildRoleUpdate)

    # @!macro gateway_event
    __event(:guild_role_delete, Gateway::GuildRoleDelete)

    # @!macro gateway_event
    __event(:message_create, Gateway::MessageCreate)

    # @!macro gateway_event
    __event(:message_update, Gateway::MessageUpdate)

    # @!macro gateway_event
    __event(:message_delete, Gateway::MessageDelete)

    # @!macro gateway_event
    __event(:message_delete_bulk, Gateway::MessageDeleteBulk)

    # @!macro gateway_event
    __event(:message_reaction_add, Gateway::MessageReactionAdd)

    # @!macro gateway_event
    __event(:message_reaction_remove, Gateway::MessageReactionRemove)

    # @!macro gateway_event
    __event(:message_reaction_remove_all, Gateway::MessageReactionRemoveAll)

    # @!macro gateway_event
    __event(:presence_update, Gateway::PresenceUpdate)

    # @!macro gateway_event
    __event(:typing_start, Gateway::TypingStart)

    # @!macro gateway_event
    __event(:user_update, Gateway::UserUpdate)

    # @!macro gateway_event
    __event(:voice_state_update, Gateway::VoiceStateUpdate)

    # @!macro gateway_event
    __event(:voice_server_update, Gateway::VoiceServerUpdate)

    # @!macro gateway_event
    __event(:webhooks_update, Gateway::WebhooksUpdate)

    # @endgroup

    # The properties for the identify payload that is sent via the gateway
    IDENTIFY_PROPERTIES = {
      os: "Ruby",
      browser: "rapture",
      device: "rapture",
      referrer: "",
      referring_domain: "",
    }.freeze

    # Request that a `GUILD_MEMBER_CHUNK` be sent
    def request_guild_members(guild_id, query: nil, limit: 0)
      payload = {guild_id: guild_id, query: query, limit: limt}.compact
      @websocket.send({op: OP_REQUEST_GUILD_MEMBERS, d: payload})
    end

    private

    # @!visibility private
    # Send an `IDENTIFY` packet through the gateway
    def identify
      payload = Gateway::Identify.new(
        @token,
        IDENTIFY_PROPERTIES,
        @large_threshold,
        @shard_key
      )
      @websocket.send({op: OP_IDENTIFY, d: payload}.to_json)
    end

    # @!visibility private
    # Attempt to resume a gateway connection
    def resume
      payload = Gateway::Resume.new(
        @token,
        @session
      )
      @websocket.send({op: OP_RESUME, d: payload}.to_json)
    end

    # @!visibility private
    # Begin a loop that sends a heartbeat on a fixed interval
    def setup_heartbeats
      Thread.new do
        loop do
          if @send_heartbeats
            # TODO: Heartbeat ack checking
            sequence = @session&.sequence
            # puts "Sending heartbeat (sequence: #{sequence}, interval: #{@heartbeat_interval})"
            @websocket.send({op: OP_HEARTBEAT, d: sequence}.to_json)
          end
          sleep @heartbeat_interval
        end
      end
    end

    def on_open(event); end

    def on_message(packet)
      case packet.opcode
      when OP_HELLO
        interval = packet.data[:heartbeat_interval] / 1000.0
        handle_hello(interval)
      when OP_DISPATCH
        handle_dispatch(packet.type, packet.data)
        @session.sequence = packet.sequence
      when OP_INVALID_SESSION
        handle_invalidate_session
      when OP_RECONNECT
        @websocket.reconnect
      when OP_HEARTBEAT_ACK
        Rapture::LOGGER.info("Gateway") { "Recieved heartbeat ack: #{packet.d}" }
      else
        puts "Unknown opcode: #{packet.inspect}"
      end
    end

    def on_close(_event)
      @send_heartbeats = false
    end

    def handle_hello(interval)
      @heartbeat_interval = interval
      @send_heartbeats = true
      # TODO: Heartbeat ack checking

      if @session.nil? || @session.invalid
        identify
      else
        resume
      end
    end

    # @!visibility private
    # Handle an OP_INVALID_SESSION (9) packet
    def handle_invalidate_session
      @session.invalid = true if @session

      identify
    end

    # @!visibility private
    # Handle an OPCODE_DISPATCH (0) packet.
    def handle_dispatch(event_type, data)
      event_type = event_type.to_sym

      @session = Session.new(0, false, false, true, data[:session_id]) if event_type == :READY

      Thread.new { call_handlers(event_type, data) }
    end
  end
end
