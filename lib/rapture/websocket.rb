# frozen-string-literal: true

require 'faye/websocket'

module Rapture
  # Websocket abstraction
  class WebSocket
    # Discord payload
    class Packet
      include Mapping

      property :op
      alias_method :opcode, :op

      property :s
      alias_method :sequence, :s

      property :d
      alias_method :data, :d

      property :t
      alias_method :type, :t

      property :code

      def inspect
        "<Rapture::WebSocket::Packet @op=#{op} @s=#{s} @d=#{d} @t=#{t} @code=#{code}>"
      end
    end

    def initialize(url)
      @url = url
    end

    def send(data)
      @ws.send(data)
    end

    def on_open(&handler)
      @on_open_handler = handler
    end

    def on_message(&handler)
      @on_message_handler = handler
    end

    def on_close(&handler)
      @on_close_handler = handler
    end

    # Connect!
    def run
      EM.run do
        @ws = Faye::WebSocket::Client.new(@url)

        @ws.on :open do |event|
          puts "[OPEN] #{@url}"
          @on_open_handler.call(event)
        end

        @ws.on :message do |event|
          # puts "[MESSAGE] #{event.data}"
          packet = Packet.from_json(event.data)
          @on_message_handler.call(packet)
        end

        @ws.on :close do |event|
          puts "[CLOSE] #{event.inspect}"
          @on_close_handler.call(event)
        end
      end
    end
  end
end
