# frozen-string-literal: true

module Rapture
  # Websocket abstraction
  class WebSocket
    # Discord payload
    class Packet
      include Mapping

      # @!attribute [r] op
      # @return [Integer] this packet's opcode
      # @see https://discordapp.com/developers/docs/topics/opcodes-and-status-codes
      getter :op
      alias_method :opcode, :op

      # @!attribute [r] s
      getter :s
      alias_method :sequence, :s

      # @!attribute [r] d
      getter :d
      alias_method :data, :d

      # @!attribute [r] t
      getter :t
      alias_method :type, :t

      # @!attribute [r] code
      getter :code

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
          puts "[MESSAGE] #{event.data}"
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
