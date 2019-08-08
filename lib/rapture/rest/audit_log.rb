# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Fetch a guild's audit log
  # @param guild_id [String, Integer]
  # @option params [String, Integer] :user_id
  # @option params [Integer] :action_type
  # @option params [String, Integer] :before
  # @option params [Integer] :limit
  # @return [AuditLog]
  def get_guild_audit_log(guild_id, **params)
    query = URI.encode_www_form(params)
    response = request(
      :get,
      "guilds/#{guild_id}/audit-logs?" + query
    )
    Rapture::AuditLog.from_json(response.body)
  end
end
