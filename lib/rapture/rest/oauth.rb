# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  # The bot's OAuth2 application info
  # https://discordapp.com/developers/docs/topics/oauth2#get-current-application-information
  # @return [OauthApplication]
  def get_current_application_information
    response = request(:get, "oauth2/applications/@me")
    OauthApplication.from_json(response.body)
  end
end
