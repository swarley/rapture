# frozen_string_literal: true

module Rapture::REST
  include Rapture::HTTP

  def get_guild_audit_log(guild_id, user_id: nil, action_type: nil, before: nil, limit: nil)
    query = {user_id: user_id, action_type: action_type, before: before, limit: limit }.compact
    response = request(
      :get
      "guilds/#{guild_id}/audit-logs?" + URI.encode_www_form(query)
    )
    AuditLog.from_json(response)
  end
end