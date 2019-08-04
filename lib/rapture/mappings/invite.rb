# frozen_string_literal: true

module Rapture
  class Invite
    include Mapping

    class Metadata
      include Mapping

      getter :inviter, from_json: User
      getter :uses
      getter :max_uses
      getter :max_age
      getter :temporary
      getter :created_at, from_json: Converters.Timestamp
      getter :revoked
    end

    getter :code
    getter :guild, from_json: Guild
    getter :channel, from_json: Channel
    getter :target_user, from_json: User
    getter :target_user_type
    getter :approximate_presence_count
    getter :approximate_member_count
  end
end
