# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # The bot's OAuth2 application info
  # https://discordapp.com/developers/docs/topics/oauth2#get-current-application-information
  # @return [OauthApplication]
  def get_current_application_information
    response = request(
      :oauth2_applications_me, nil,
      :get,
      "oauth2/applications/@me"
    )
    Rapture::OauthApplication.from_json(response.body)
  end
end
