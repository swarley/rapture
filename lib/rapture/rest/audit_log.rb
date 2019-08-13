# frozen_string_literal: true

# Module that holds methods for interacting with the REST portion of the API
module Rapture::REST
  include Rapture::HTTP

  # Fetch a guild's audit log
  # @param guild_id [String, Integer]
  # @param user_id [String, Integer]
  # @param action_type [Integer]
  # @param before [String, Integer]
  # @param limit [Integer]
  # @return [AuditLog]
  def get_guild_audit_log(guild_id, user_id: nil, action_type: nil, before: nil, limit: nil)
    query = URI.encode_www_form({user_id: user_id, action_type: action_type, before: before, limit: limit}.compact)
    response = request(
      :guilds_gid_audit_logs, guild_id,
      :get,
      "guilds/#{guild_id}/audit-logs?" + query
    )
    Rapture::AuditLog.from_json(response.body)
  end
end
