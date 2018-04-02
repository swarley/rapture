# frozen_string_literal: true

module Rapture
  class Message
    include Mapping

    # @return [Integer] ID
    property :id, to_json: :to_s, from_json: proc { |id| Integer(id) }

    # @return [User] the message author
    property :author, from_json: User

    # @return [String] message content
    property :content

    # @return [true, false] whether this message was sent as a TTS message
    property :tts
  end
end
