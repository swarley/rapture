
require "rapture/mappings/webhook"

module Rapture
  class AuditLog
    include Mapping

    # @todo Separate into GuildChange, ChannelChange, RoleChange, InviteChange,
    class Change
      include Mapping

      # @!attribute [r] id
      # @return [Integer, nil]
      getter :id, converter: Converters.Snowflake?

      # @!attribute [r] type
      # @return [Integer, String] Integer if refering to a channel type
      getter :type
    end

    class Info
      include Mapping

      # @note Only present for `MEMBER_PRUNE` actions
      # @!attribute [r] deleted_member_days
      # @return [String, nil]
      getter :deleted_member_days

      # @note Only present for `MEMBER_PRUNE` actions
      # @!attribute [r] members_removed
      # @return [String, nil]
      getter :members_removed

      # @note Only present for `MESSAGE_DELETE` actions
      # @!attribute [r] channel_id
      # @return [Integer, nil]
      getter :channel_id, converter: Converters.Snowflake?

      # @note Only present for `MESSAGE_DELETE` actions
      # @!attribute [r] count
      # @return [String, nil]
      getter :count

      # @note Only present for `CHANNEL_OVERWRITE_CREATE`, `CHANNEL_OVERWRITE_UPDATE`
      #   and `CHANNEL_OVERWRITE_DELETE` actions.
      # @!attribute [r] id
      # @return [Integer, nil] id relevant to the overwrite
      getter :id, converter: Converters.Snowflake?

      # @note Only present for `CHANNEL_OVERWRITE_CREATE`, `CHANNEL_OVERWRITE_UPDATE`
      #   and `CHANNEL_OVERWRITE_DELETE` actions.
      # @!attribute [r] type
      # @return [String, nil] entity type relevant to the overwrite (`"member"`, or `"role"`)
      getter :type

      # @note Only present for `CHANNEL_OVERWRITE_CREATE`, `CHANNEL_OVERWRITE_UPDATE`
      #   and `CHANNEL_OVERWRITE_DELETE` actions.
      # @!attribute [r] role_name
      # @return [String, nil] name of the role, if `type` is `"role"`
      getter :role_name
    end

    class Entry
      include Mapping

      # @!attribute [r] target_id
      # @return [String, nil] the type name of the affected object
      getter :target_id

      # @!attribute [r] changes
      # @return [Array<Change>, nil]
      getter :changes, from_json: Change

      # @!attribute [r] user_id
      # @return [Integer]
      getter :user_id, converter: Converters.Snowflake

      # @!attribute [r] id
      # @return [Integer]
      getter :id, converter: Converters.Snowflake

      # @!attribute [r] action_type
      # @return [Integer]
      # @see https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events
      getter :action_type

      # @!attribute [r] options
      # @return [Info, nil] additional info for certain action types
      getter :options, from_json: Info

      # @!attribute [r] reason
      # @return [String, nil]
      getter :reason
    end

    # @!attribute [r] webhooks
    # @return [Array<Webhook>]
    getter :webhooks, from_json: Rapture::Webhook

    # @!attribute [r] users
    # @return [Array<User>]
    getter :users, from_json: User

    # @!attribute [r] audit_log_entries
    # @return [Array<Entry>]
    getter :audit_log_entries, from_json: Entry
  end
end
