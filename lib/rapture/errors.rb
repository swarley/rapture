module Rapture
  class JSONError
    include Rapture::Mapping

    # @!attribute [r] code
    # @return [Integer] JSON Error code
    # @see https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#json-json-error-codes
    getter :code

    # @!attribute [r] message
    # @return [String]
    getter :message
  end

  class HTTPException < Exception
    include Rapture::Mapping

    # @!attribute [r] code
    # @return [Integer] The JSON error code associated with this exception.
    getter :code

    # @todo embed error support
    # @!attribute [r] errors
    # @return [Array<JSONError>]
    getter :errors, from_json: proc { |data|
               data[:content][:_errors].collect { |err| JSONError.from_h(err) } if data
             }

    # @!attribute [r] message
    # @return [String]
    getter :message

    def to_s
      <<~ERROR
        ERROR [#{@code}]: #{@message}
        #{@errors.collect { |err| "> #{err.code}: #{err.message}" }.join "\n"}   
      ERROR
    end

    def inspect
      "#<Rapture::HTTP::HTTPException @code=#{@code} @message=#{message.inspect}>"
    end
  end
end
