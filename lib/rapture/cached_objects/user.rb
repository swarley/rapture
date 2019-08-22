# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedUser < Base(Rapture::User)
    def on(guild_id)
      client.get_guild_member(guild_id, self.id)
    end
  end
end
