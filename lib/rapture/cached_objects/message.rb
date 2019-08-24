# frozen_string_literal: true

module Rapture::CachedObjects
  class CachedMessage < Base(Rapture::Message)
    def intialize(*)
      super
      @guild = client.get_guild(@delegate.guild_id) if @delegate.guild_id
      @channel = client.get_channel(@delegate.channel_id)
    end

    def guild
      client.get_guild(@delegate.guild_id) if @delegate.guild_id
    end

    def channel
      client.get_channel(@delegate.channel_id)
    end

    def mentions
      @delegate.mentions.collect { |user| CachedUser.new(client, user) }
    end

    def mention_roles
      @delegate.mention_roles.collect { |role| CachedRole.new(client, role) }
    end

    def author
      CachedUser.new(client, @delegate.author)
    end

    def respond(content: nil, embed: nil)
      client.create_message(@delegate.channel_id, content: content, embed: embed)
    end

    def <<(content)
      client.create_message(@delegate.channel_id, content: content)
    end

    def edit(content: nil, embed: nil)
      Rapture::LOGGER.warn("CachedMessage") { "Attempting to edit a message that doesn't belong to the client" } if @delegate.author.id != client.get_current_user.id
      client.edit_message(@delegate.channel_id, @delegate.id, content: content, embed: embed)
    end

    def delete
      client.delete_message(@delegate.channel_id, @delegate.id)
    end

    def react(emoji)
      client.create_reaction(@delegate.channel_id, @delegate.id, emoji)
    end

    def delete_reactions
      client.delete_all_reactions(@delegate.channel_id, @delegate.id)
    end

    def pin
      client.add_pinned_message(@delegate.channel_id, @delegate.id)
    end

    def unpin
      client.delete_pinned_message(@delegate.channel_id, @delegate.id)
    end
  end
end