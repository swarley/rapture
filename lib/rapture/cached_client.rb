# frozen_string_literal: true

module Rapture
  # A client that has caching capabilities.
  # The client automatically caches users, guilds, roles, channels, and members.
  # By default this cache is stored in the memory, however you may provide
  # a subclass of {Cache} with your own method of storage to
  class CachedClient < Client
    # @return [Cache<Integer, User>]
    attr_accessor :user_cache

    # @return [Cache<Integer, Guild>]
    attr_accessor :guild_cache

    # @return [Cache<Integer, Array<Integer>>] caches a list of role IDs in a guild
    attr_accessor :guild_role_cache

    # @return [Cache<Integer, Array<Integer>>] caches a list of channel IDs in a guild
    attr_accessor :guild_channel_cache

    # @return [Cache<Integer, Channel]
    attr_accessor :channel_cache

    # @return [Cache<Integer, Role>]
    attr_accessor :role_cache

    # @return [Cache<(Integer, Integer), Member>] caches a member with (guild_id, user_id) as the key
    attr_accessor :member_cache

    # (see Client#initialize)
    # @param default_cache [Rapture::Cache] the default cache type for all caches
    def initialize(*args, default_cache: Rapture::DefaultCache)
      @user_cache = default_cache.new
      @guild_cache = default_cache.new
      @guild_role_cache = default_cache.new
      @guild_channel_cache = default_cache.new
      @channel_cache = default_cache.new
      @role_cache = default_cache.new
      @member_cache = default_cache.new
      super(*args)
      initialize_cache_handlers
    end

    # Add handlers that cache data sent over the gateway
    def initialize_cache_handlers
      on_guild_create do |guild|
        @guild_cache.cache(guild.id, guild)
        guild.channels.each do |channel|
          channel.instance_variable_set(:@guild_id, guild.id)
          @channel_cache.cache(channel.id, channel)
          @guild_channel_cache.fetch(guild.id) { [] } << channel.id
        end

        guild.roles.each do |role|
          @role_cache.cache(role.id, CachedObjects::CachedRole.new(self, role, guild.id))
          @guild_role_cache.fetch(guild.id) { [] } << role.id
        end

        guild.members.each do |member|
          @member_cache.cache([guild.id, member.user.id], CachedObjects::CachedMember.new(self, member, guild.id))
          @user_cache.cache(member.user.id, member.user)
        end
      end

      on_channel_create do |channel|
        @channel_cache.cache(channel.id, CachedObjects::CachedChannel.new(channel))
        if (guild_id = channel.guild_id)
          @guild_channel_cache.fetch(guild_id) { [] } << channel.id
        end
      end

      on_channel_update do |channel|
        @channel_cache.cache(channel.id, CachedObjects::CachedChannel.new(self, channel))
      end

      on_channel_delete do |channel|
        channel_cache.remove(channel.id)
        if (guild_id = channel.guild_id)
          @guild_channel_cache.resolve(guild_id).delete(channel.id)
        end
      end

      on_guild_update do |guild|
        @guild_cache.cache(guild.id, CachedObjects::CachedGuild.new(self, guild))
      end

      on_guild_delete do |guild|
        @guild_cache.delete(guild.id)
      end

      on_guild_member_add do |member|
        @user_cache.cache(member.user.id, CachedObjects::CachedUser.new(self, member.user))
        @member_cache.cache([member.guild_id, member.user.id], CachedObjects::CachedMember.new(self, member, member.guild_id))
      end

      on_guild_member_update do |payload|
        @user_cache.cache(payload.user.id, payload.user)
        if (existing = @member_cache.resolve([payload.guild_id, payload.user.id]))
          existing.__send__(:update, roles: payload.roles, nick: payload.nick)
          @member_cache.cache([existing.guild_id, existing.user.id], existing)
        else
          member = get_guild_member(payload.guild_id, payload.user.id)
          @member_cache.cache([member.guild_id, member.user.id], CachedObjects::CachedUser.new(self, member))
        end
      end

      on_guild_member_remove do |payload|
        @user_cache.cache(payload.user.id, CachedObjects::CachedUser.new(self, payload.user))
        @member_cache.remove([payload.guild_id, payload.user.id])
      end

      on_guild_members_chunk do |payload|
        payload.members.each do |member|
          @member_cache.cache([member.guild_id, member.user.id], CachedObjects::CachedMember.new(self, member, member.guild_id))
        end
      end

      on_guild_role_create do |payload|
        @role_cache.cache(payload.role.id, CachedObjects::CachedRole.new(self, payload.role))
        @guild_role_cache.fetch(payload.guild_id) { [] } << payload.role.id
      end

      on_guild_role_update do |payload|
        @role_cache.cache(payload.role.id, payload.role)
      end

      on_guild_role_delete do |payload|
        @role_cache.remove(payload.role_id)
        @guild_role_cache.resolve(payload.guild_id).delete(payload.role_id)
      end

      on_presence_update do |payload|
        @user_cache.cache(payload.user.id, CachedObjects::CachedUser.new(self, payload.user)) if payload.user

        @member_cache.cache([payload.guild_id, payload.user.id], payload) if payload.roles && payload.user && payload.guild_id
      end

      on_ready do |payload|
        @user_cache.cache(:@me, CachedObjects::CachedUser.new(self, payload.user))
      end

      on_user_update do |payload|
        @user_cache.cache(:@me, CachedObjects::CachedUser.new(self, payload))
      end
    end

    # Return a guild object from its ID. If the guild is not cached, it will be fetched
    # @param id [Integer]
    # @param cached [true, false] value will be recached if set to false
    # @return [Guild]
    def get_guild(id, cached: true)
      return @guild_cache.fetch(id) { CachedObjects::CachedGuild.new(self, super(id)) } if cached

      guild = CachedObjects::CachedGuild.new(self, super(id))
      @guild_cache.cache(id, guild)
    end

    # Return a user object from its ID. If the user is not cached, it will be fetched
    # @param id [Integer]
    # @param cached [true, false] value will be recached if set to false
    # @return [User]
    def get_user(id, cached: true)
      return @user_cache.fetch(id) { CachedObjects::CachedUser.new(self, super(id)) } if cached

      user = CachedObjects::CachedUser.new(self, super(id))
      @user_cache.cache(id, user)
    end

    # @param cached [true, false] value will be recached if set to false
    # @return [User] current user
    def get_current_user(cached: true)
      return @user_cache.fetch(id) { CachedObjects::CachedUser.new(self, super()) } if cached

      user = CachedObjects::CachedUser.new(self, super())
      @user_cache.cache(:@me, user)
    end

    # Return a channel object from its ID.
    # @param id [Integer]
    # @param cached [true, false] values will be recached if false
    # @return [Channel]
    def get_channel(id, cached: true)
      return @channel_cache.fetch(id) { CachedObjects::CachedChannel.new(self, super(id)) } if cached

      channel = CachedObjects::CachedChannel.new(self, super(id))
      @channel_cache.cache(id, channel)
    end

    # There is no endpoint for fetching individual roles,
    # so the role method does not actively cache one.
    # However any guilds available to the client should
    # have their roles cached at all times.
    # @param id [Integer]
    # @return [Role, nil]
    def role(id)
      @role_cache.resolve(id)
    end

    # Return a member object from it's guild ID and user ID. If the user is not cached, it will be fetched
    # @param guild_id [Integer]
    # @param user_id [Integer]
    # @param cached [true, false] values will be recached if false
    # @return [Member]
    def get_guild_member(guild_id, user_id, cached: true)
      return @member_cache.fetch([guild_id, user_id]) { CachedObjects::CachedMember.new(self, super(guild_id, user_id), guild_id) } if cached

      member = super(guild_id, user_id)
      @member_cache.cache([guild_id, user_id], member)
    end

    # Return a list of all cached members for a given guild
    # @param guild_id [Integer]
    # @return [Array<Member>]
    def get_guild_members(guild_id)
      @member_cache.select { |key| key[0] == guild_id }.collect(&:last)
    end

    # Return a list of cached guild_roles
    # @param guild_id [Integer]
    # @param cached [true, false] values will be recached if false
    # @return [Array<Role>]
    def get_guild_roles(guild_id, cached: true)
      if cached
        ret_array = []
        guild_roles = @guild_role_cache.fetch(guild_id) do
          roles = super(guild_id)
          roles.each { |role| ret_array << @role_cache.cache(role.id, CachedObjects::CachedRole.new(self, role)) }
          roles.collect(&:id)
        end
        return ret_array
      end

      guild_roles = super(guild_id).collect { |role| CachedObjects::CachedRole.new(self, role) }
      guild_roles.each_with_object([]) { |role, ret_array| ret_array << @role_cache.cache(role.id, role) }
    end

    # Return a list of guild_channels
    # @param guild_id [Integer]
    # @param cached [true, false] values will be recached if false
    def get_guild_channels(guild_id, cached: true)
      if cached
        channels = @guild_channel_cache.fetch(guild_id) { super(guild_id).collect(&:id) }
        channels.collect { |channel_id| get_channel(channel_id) }
      else
        guild_channels = super(guild_id)
        @guild_channel_cache.cache(guild_id, guild_channels.collect(&:id))
        guild_channels.each do |channel|
          channel = CachedObjects::CachedChannel.new(self, channel)
          @channel_cache.cache(channel.id, channel)
        end
      end
    end

    # @!visibility private
    def self.__event(name, klass, coerce_klass = nil)
      return super if coerce_klass.nil?
      define_method(:"on_#{name}") do |&block|
        handler = lambda do |payload|
          block.call(coerce_klass.new(self, klass.from_h(payload, :from_json)))
        end
        @event_handlers[name.upcase].push(handler)
      end
    end

    # @!macro gateway_event
    __event(:channel_create, Gateway::ChannelCreate, CachedObjects::CachedChannel)

    # @!macro gateway_event
    __event(:channel_update, Gateway::ChannelUpdate, CachedObjects::CachedChannel)

    # @!macro gateway_event
    __event(:channel_delete, Gateway::ChannelDelete, CachedObjects::CachedChannel)

    # @!macro gateway_event
    __event(:guild_create, Gateway::GuildCreate, CachedObjects::CachedGuild)

    # @!macro gateway_event
    __event(:guild_update, Gateway::GuildUpdate, CachedObjects::CachedGuild)

    # @!macro gateway_event
    __event(:guild_delete, Gateway::GuildDelete, CachedObjects::CachedGuild)

    # @!macro gateway_event
    __event(:guild_member_add, Gateway::GuildMemberAdd, CachedObjects::CachedMember)

    # @!macro gateway_event
    __event(:message_create, Gateway::MessageCreate, CachedObjects::CachedMessage)

    # @!macro gateway_event
    __event(:message_update, Gateway::MessageUpdate, CachedObjects::CachedMessage)

    # @!macro gateway_event
    __event(:user_update, Gateway::UserUpdate, CachedObjects::CachedUser)
  end
end
