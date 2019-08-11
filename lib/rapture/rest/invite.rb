# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Get an invite for the given code
  # https://discordapp.com/developers/docs/resources/invite#get-invite
  # @param invite_code [String]
  # @return [Invite]
  def get_invite(invite_code, with_counts: nil)
    query = URI.encode_www_form(with_counts: with_counts)
    response = request(
      :invites_code, nil,
      :get,
      "invites/#{invite_code}" + query
    )
    Rapture::Invite.from_json(response.body)
  end

  # Delete an invite
  # https://discordapp.com/developers/docs/resources/invite#delete-invite
  # @param invite_code [String]
  # @param reason [String]
  # @return [Invite]
  def delete_invite(invite_code, reason: nil)
    response = request(
      :invites_code, nil,
      :delete,
      "invites/#{invite_code}",
      nil,
      'X-Audit-Log-Reason': reason,
    )
    Rapture::Invite.from_json(response.body)
  end
end
