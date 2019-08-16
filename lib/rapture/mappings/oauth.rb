# frozen_string_literal: true

module Rapture
  # https://discordapp.com/developers/docs/topics/teams#data-models-team-object
  class Team
    include Mapping

    # https://discordapp.com/developers/docs/topics/teams#data-models-team-members-object
    class Member
      include Mapping

      # @!attribute [r] membership_state
      # @return [Integer]
      getter :membership_state

      # @!attribute [r] permissions
      # @return [Array<String>]
      getter :permissions

      # @!attribute [r] team_id
      # @return [Integer]
      getter :team_id, converter: Converters.Snowflake

      # @!attribute [r] user
      # @return [User]
      getter :user, from_json: User
    end

    # @!attribute [r] icon
    # @return [String]
    getter :icon

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] members
    # @return [Array<Team::Member>]
    getter :members, from_json: Team::Member

    # @!attribute [r] owner_user_id
    # @return [Integer]
    getter :owner_user_id, converter: Converters.Snowflake
  end

  # Information about the bot's Oauth application
  # https://discordapp.com/developers/docs/topics/oauth2#get-current-application-information-response-structure
  class OauthApplication
    include Mapping

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] icon
    # @return [String, nil]
    getter :icon

    # @!attribute [r] description
    # @return [String]
    getter :description

    # @!attribute [r] rpc_origins
    # @return [Array<String>, nil]
    getter :rpc_origins

    # @!attribute [r] bot_public
    # @return [true, false]
    getter :bot_public

    alias_method :bot_public?, :bot_public

    # @!attribute [r] bot_require_code_grant
    # @return [true, false]
    getter :bot_require_code_grant

    alias_method :bot_require_code_grant?, :bot_require_code_grant

    # @!attribute [r] owner
    # @return [User]
    getter :owner, from_json: User

    # @!attribute [r] summary
    # @return [String]
    getter :summary

    # @!attribute [r] verify_key
    # @return [String]
    getter :verify_key

    # @!attribute [r] team
    # @return [Team, nil]
    getter :team, from_json: Team

    # @!attribute [r] guild_id
    # @return [Integer, nil]
    getter :guild_id, converter: Converters.Snowflake?

    # @!attribute [r] primary_sku_id
    # @return [Integer, nil]
    getter :primary_sku_id, converter: Converters.Snowflake?

    # @!attribute [r] slug
    # @return [String, nil]
    getter :slug

    # @!attribute [r] cover_image
    # @return [String, nil]
    getter :cover_image
  end
end
