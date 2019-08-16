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
      # @return [Integer, 0] sequence number used for resuming and heartbeats.
      # Only in dispatch packets
      getter :s
      alias_method :sequence, :s

      # @!attribute [r] d
      # @return [Hash] event data
      getter :d
      alias_method :data, :d

      # @!attribute [r] t
      # @return [String, nil] event name for this payload. Only in dispatch packets
      getter :t
      alias_method :type, :t

      # @!attribute [r] code
      # @return [Integer]
      getter :code
    end

    # Create a websocket connecting to a given url
    def initialize(url, compress)
      @url = url
      @compress = compress
    end

    # Transmit data over the socket
    def send(data)
      Rapture::LOGGER.debug("Websocket") { "[SEND] #{data}" }
      @ws.send(data)
    end

    # Register a handler that is executed when the websocket connects
    def on_open(&handler)
      @on_open_handler = handler
    end

    # Register a handler that is executed when a message is recieved
    def on_message(&handler)
      @on_message_handler = handler
    end

    # Register a handler that is executed when the websocket closes
    def on_close(&handler)
      @on_close_handler = handler
    end

    # Handle zlib_stream decompression
    def decompress(data)
      @inflater ||= Zlib::Inflate.new
      @inflater << data.pack("c*")

      return if data.size < 4 || data[-4..-1] != [0x00, 0x00, 0xFF, 0xFF]

      return @inflater.inflate("")
    end

    # Detect and handle large compression
    def decompress_large(data)
      if data[0] == "x"
        Zlib::Inflate.inflate(packed)
      else
        data
      end
    end

    # Connect!
    def run
      EM.run do
        @ws = Faye::WebSocket::Client.new(@url)

        @ws.on :open do |event|
          Rapture::LOGGER.info("Websocket") { "[OPEN] #{@url}" }
          @on_open_handler.call(event)
        end

        @ws.on :message do |event|
          data = if @compress == :zlib_stream
                   decompress(event.data)
                 elsif @compress == :large
                   decompress_large(event.data)
                 else
                   event.data
                 end

          return if data.nil?

          Rapture::LOGGER.debug("Websocket") { "[MESSAGE IN] #{data}" }
          packet = Packet.from_json(data)
          @on_message_handler.call(packet)
        end

        @ws.on :close do |event|
          Rapture::LOGGER.info("Websocket") { "[CLOSE] #{event.code}" }
          @on_close_handler.call(event)
        end
      end
    end

    # Close the websocket and reconnect
    def reconnect
      @ws.close
      run
    end
  end
end
