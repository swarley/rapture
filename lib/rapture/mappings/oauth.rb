# frozen_string_literal: true

module Rapture
  class OauthApplication
    include Mapping

    getter :id, converter: Converters.Snowflake
    getter :name
    getter :icon
    getter :description
    getter :rpc_origins
    getter :bot_public
    getter :bot_require_code_grant
    getter :owner, from_json: User
    getter :summary
    getter :verify_key
    getter :team, from_json: Team
    getter :guild_id, converter: Converters.Snowflake?
    getter :primary_sku_id, converter: Converters.Snowflake?
    getter :slug
    getter :cover_image
  end

  class Team
    include Mapping

    class Member
      include Mapping

      getter :membership_state
      getter :permissions
      getter :team_id, converter: Converters.Snowflake
      getter :user, from_json: User
    end

    getter :icon
    getter :id, converter: Converters.Snowflake
    getter :members, from_json: Team::Member
    getter :owner_user_id, converter: Converters.Snowflake
  end
end