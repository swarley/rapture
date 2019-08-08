# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # A list of {Voice::Region} objects that can be used when creating servers
  # https://discordapp.com/developers/docs/resources/voice#list-voice-regions
  def list_voice_regions
    Voice::Region.from_json_array request(:get, "voice/regions").body
  end
end
