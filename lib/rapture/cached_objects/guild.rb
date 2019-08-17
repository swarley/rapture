# frozen_String_literal: true

require "rapture/cached_objects/delegate"

module Rapture::CachedObjects
  class CachedGuild < Base(Rapture::Guild)
    def channels
      @client.get_guild_channels(self.id)
    end
  end
end
