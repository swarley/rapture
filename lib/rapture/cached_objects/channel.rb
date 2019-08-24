
# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedChannel < Base(Rapture::Channel)
    extend ModifySetter

    setter :name
    setter :position
    setter :topic
    setter :nsfw
    setter :rate_limit_per_user
    setter :bitrate
    setter :user_limit
    setter :permission_overwrites
    setter :parent_id

    def modify(name: nil, position: nil, topic: nil, nsfw: nil, rate_limit_per_user: nil,
               bitrate: nil, user_limit: nil, permission_overwrites: nil, parent_id: nil, reason: nil)
      updated = client.modify_channel(
        self.id, name: name, position: position, topic: topic, nsfw: nsfw,
                 rate_limit_per_user: rate_limit_per_user, bitrate: bitrate, user_limit: user_limit,
                 permission_overwrites: permission_overwrites, parent_id: parent_id, reason: reason,
      )
      @delegate = updated
    end

    def messages(around: nil, before: nil, after: nil, limit: nil)
      client.get_channel_messages(self.id, around: around, before: before, after: after, limit: limit)
    end

    def message(id)
      client.get_channel_message(self.id, id)
    end
  end
end
