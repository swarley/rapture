# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedMember < Base(Rapture::Member)
    attr_reader :guild_id

    def initialize(client, member, guild_id)
      super(client, member)
      @guild_id = guild_id
    end

    def modify(nick: nil, roles: nil, mute: nil, deaf: nil, channel_id: nil, reason: nil)
      updated = client.modify_guild_member(
        self.guild_id, self.user.id, nick: nick, roles: roles,
                                     mute: mute, deaf: deaf, channel_id: channel_id, reason: reason,
      )
      @delegate = updated
    end

    def add_role(role_id)
      client.add_guild_member_role(self.guild_id, self.user.id, role_id)
    end

    def remove_role(role_id)
      client.remove_guild_member_role(self.guild_id, self.user.id, role_id)
    end

    def kick(reason: nil)
      client.remove_guild_member(self.guild_id, self.user.id, reason: reason)
    end

    def ban(reason: nil)
      client.create_guild_ban(self.guild_id, self.user.id, reason: reason)
    end

    def disconnect(reason: nil)
      modify(channel_id: :null, reason: reason)
    end

    def move_to(channel_id, reason: nil)
      modify(channel_id: channel_id, reason: reason)
    end

    def mute(reason: nil)
      modify(mute: true, reason: reason)
    end

    def deafen(reason: nil)
      modify(deaf: true, reason: reason)
    end
  end
end
