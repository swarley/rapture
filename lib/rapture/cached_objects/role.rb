# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedRole < Base(Rapture::Role)
    extend ModifySetter

    setter :name
    setter :permissions
    setter :color
    setter :hoist
    setter :mentionable

    attr_reader :guild_id

    def initialize(client, data, guild_id)
      super(client, data)
      @guild_id = guild_id
    end

    # @param name [String]
    # @param permissions [Integer]
    # @param color [Integer]
    # @param hoist [true, false]
    # @param mentionable [true, false]
    # @param reason [String]
    def modify(name: nil, permissions: nil, color: nil, hoist: nil, mentionable: nil, reason: nil)
      @delegate = client.modify_guild_role(
        self.guild_id, self.id, name: name, permissions: permissions,
                                color: color, hoist: hoist, mentionable: mentionable, reason: reason,
      )
      self
    end

    def color=(value, reason: nil)
      modify(color: value, reason: reason)
    end

    def permissions=(value, reason: nil)
      value = value.respond_to?(:to_i) ? value.to_i : value
      modify(permissions: value, reason: reason)
    end

    def hoist=(value, reason: nil)
      modify(hoist: value, reason: reason)
    end

    def mentionable=(value, reason: nil)
      modify(mentionable: value, reason: reason)
    end

    def delete(reason: nil)
      client.delete_guild_role(self.guild_id, self.id, reason: reason)
    end
  end
end
