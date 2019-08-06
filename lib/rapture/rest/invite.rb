# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  # Get an invite for the given code
  # https://discordapp.com/developers/docs/resources/invite#get-invite
  # @param invite_code [String]
  # @return [Invite]
  def get_invite(invite_code,  with_counts: nil)
    query = URI.encode_www_form(with_counts: with_counts)
    response = request(:get, "invites/#{invite_code}" + query)
    Invite.from_json(response.body)
  end

  # Delete an invite
  # https://discordapp.com/developers/docs/resources/invite#delete-invite
  # @param invite_code [String]
  # @return [Invite]
  def delete_invite(invite_code)
    response = request(:delete, "invites/#{invite_code}")
    Invite.from_json(response.body)
  end
end
