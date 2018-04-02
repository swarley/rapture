# frozen_string_literal: true

module Rapture
  # The `Client` abstracts away the token from making REST API requests
  # and provides a means to connect to Discord's gateway.
  class Client
    include REST

    def initialize(token)
      @type, @token = token.split(' ')
      @heartbeat_interval = 1
      @send_heartbeats = false
      @event_handlers = Hash.new { |hash, key| hash[key] = Array.new }
      setup_heartbeats
    end

    def run
      websocket.run
    end

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

    private def on_open(event); end

    OP_DISPATCH              =  0
    OP_HEARTBEAT             =  1
    OP_IDENTIFY              =  2
    OP_STATUS_UPDATE         =  3
    OP_VOICE_STATE_UPDATE    =  4
    OP_VOICE_SERVER_PING     =  5
    OP_RESUME                =  6
    OP_RECONNECT             =  7
    OP_REQUEST_GUILD_MEMBERS =  8
    OP_INVALID_SESSION       =  9
    OP_HELLO                 = 10
    OP_HEARTBEAT_ACK         = 11

    Session = Struct.new(:sequence, :suspend, :invalid, :resume, :id)

    private def on_message(packet)
      case packet.opcode
      when OP_HELLO
        interval = packet.data[:heartbeat_interval] / 1000.0
        handle_hello(interval)
      when OP_DISPATCH
        handle_dispatch(packet.type, packet.data)
        @session.sequence = packet.sequence
      else
        # puts "Unknown opcode: #{packet.inspect}"
      end
    end

    private def on_close(event)
      @send_heartbeats = false
    end

    private def handle_hello(interval)
      @heartbeat_interval = interval
      @send_heartbeats = true
      # TODO: Heartbeat ack checking

      # TODO: resume
      identify
    end

    def handle_dispatch(event_type, data)
      payload = nil
      case event_type
      when "READY"
        payload = Gateway::Ready.from_h(data, :from_json)
        @session = Session.new(0, false, false, true, payload.session_id)
      when "MESSAGE_CREATE"
        payload = Message.from_h(data, :from_json)
      end
      Thread.new { call_handlers(payload) }
      payload
    end

    def call_handlers(payload)
      @event_handlers[payload.class].dup.each do |handler|
        handler.call(payload)
      end
    end

    def self.__event(name, klass)
      define_method(:"on_#{name}") do |&block|
        @event_handlers[klass].push ->(payload) do
          block.call(payload)
        end
      end
    end

    __event(:ready, Gateway::Ready)
    __event(:message_create, Message)

    IDENTIFY_PROPERTIES = {
      os: "Ruby",
      browser: "rapture",
      device: "rapture",
      referrer: "",
      referring_domain: ""
    }.freeze

    private def identify
      # TODO: set shard key
      # TODO: set large_threshold
      payload = Gateway::Identify.new(
        @token,
        IDENTIFY_PROPERTIES,
        150,
        [0, 1])
      @websocket.send({op: 2, d: payload}.to_json)
    end

    private def setup_heartbeats
      Thread.new do
        loop do
          if @send_heartbeats
            # TODO: Heartbeat ack checking
            sequence = @session&.sequence
            # puts "Sending heartbeat (sequence: #{sequence}, interval: #{@heartbeat_interval})"
            @websocket.send({op: 1, d: sequence}.to_json)
          end
          sleep @heartbeat_interval
        end
      end
    end
  end
end
