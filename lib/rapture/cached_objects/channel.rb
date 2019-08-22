
# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedChannel < Base(Rapture::Channel)
    def modify(name: nil, position: nil, topic: nil, nsfw: nil, rate_limit_per_user: nil,
               bitrate: nil, user_limit: nil, permission_overwrites: nil, parent_id: nil)
      updated = client.modify_channel(
        self.id, name: name, position: position, topic: topic, nsfw: nsfw,
                 rate_limit_per_user: rate_limit_per_user, bitrate: bitrate, user_limit: user_limit,
                 permission_overwrites: permission_overwrites, parent_id: parent_id,
      )
      @delegate = updated
    end
  end
end
