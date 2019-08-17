# frozen_string_literal: true

module Rapture
  # Represets a set of permissions attached to a group of users
  # https://discordapp.com/developers/docs/topics/permissions#role-object
  class Role
    include Mapping

    # @!attribute [r] id
    # @return [Integer]
    getter :id, converter: Converters.Snowflake

    # @!attribute [r] name
    # @return [String]
    getter :name

    # @!attribute [r] color
    # @return [Integer]
    getter :color

    # @!attribute [r] hoist
    # @return [true, false]
    getter :hoist

    alias_method :hoist?, :hoist

    # @!attribute [r] position
    # @return [Integer]
    getter :position

    # @!attribute [r] permissions
    # @return [Integer]
    getter :permissions

    # @!attribute [r] managed
    # @return [true, false]
    getter :managed

    alias_method :managed?, :managed

    # @!attribute [r] mentionable
    # @return [true, false]
    getter :mentionable

    alias_method :mentionable?, :mentionable
  end

  # A class that adds methods for checking if a permission
  # is present in a bitmask
  class Permissions
    # @!attribute [r] create_instant_invite
    #   @!parse alias_method :create_instant_invite?, :create_instant_invite
    #   Allows creation of instant invites
    #   @return [true, false]

    # @!attribute [r] kick_members
    #   @!parse alias_method :kick_members?, :kick_members
    #   Allows kicking members
    #   @return [true, false]

    # @!attributes [r] ban_members
    #   @!parse alias_method :ban_members?, :ban_members
    #   Allows banning members
    #   @return [true, false]

    # @!attribute [r] administrator
    #   @!parse alias_method :administrator?, :administrator
    #   Allows all permissions and bypasses channel permission overwrites
    #   @return [true, false]

    # @!attribute [r] manage_channels
    #   @!parse alias_method :manage_channels?, :manage_channels
    #   Allows management and editing of channels
    #   @return [true, false]

    # @!attribute [r] manage_guild
    #   @!parse alias_method :manage_guild?, :manage_guild
    #   Allows management and editing of the guild
    #   @return [true, false]

    # @!attribute [r] add_reactions
    #   @!parse alias_method :add_reactions?, :add_reactions
    #   Allows for the addition of reactions to messages
    #   @return [true, false]

    # @!attribute [r] view_audit_log
    #   @!parse alias_method :view_audit_log?, :view_audit_log
    #   Allows for viewing of audit logs
    #   @return [true, false]

    # @!attribute [r] view_channel
    #   @!parse alias_method :view_channel?, :view_channel
    #   Allows guild members to view a channel, which includes reading messages in text channels
    #   @return [true, false]

    # @!attribute [r] send_messages
    #   @!parse alias_method :send_messages?, :send_messages
    #   Allows for sending messages in a channel
    #   @return [true, false]

    # @!attribute [r] send_tts_messages
    #   @!parse alias_method :send_tts_messages?, :send_tts_messages
    #   Allows for sending of /tts messages
    #   @return [true, false]

    # @!attribute [r] manage_messages
    #   @!parse alias_method :manage_messages?, :manage_messages
    #   Allows for deletion of other users messages
    #   @return [true, false]

    # @!attribute [r] embed_links
    #   @!parse alias_method :embed_links?, :embed_links
    #   Links sent by users with this permission will be auto-embedded
    #   @return [true, false]

    # @!attribute [r] attach_files
    #   @!parse alias_method :attach_files?, :attach_files
    #   Allows for uploading images and files
    #   @return [true, false]

    # @!attribute [r] read_message_history
    #   @!parse alias_method :read_message_history?, :read_message_history
    #   Allows for reading of message history
    #   @return [true, false]

    # @!attribute [r] mention_everyone
    #   @!parse alias_method :mention_everyone?, :mention_everyone
    #   Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel
    #   @return [true, false]

    # @!attribute [r] use_external_emojis
    #   @!parse alias_method :use_external_emojis?, :use_external_emojis
    #   Allows the usage of custom emojis from other servers
    #   @return [true, false]

    # @!attribute [r] connect
    #   @!parse alias_method :connect?, :connect
    #   Allows for joining of a voice channel
    #   @return [true, false]

    # @!attribute [r] speak
    #   @!parse alias_method :speak?, :speak
    #   Allows for speaking in a voice channel
    #   @return [true, false]

    # @!attribute [r] mute_members
    #   @!parse alias_method :mute_members?, :mute_members
    #   Allows for muting members in a voice channel
    #   @return [true, false]

    # @!attribute [r] deafen_members
    #   @!parse alias_method :deafen_members?, :deafen_members
    #   Allows for deafening of members in a voice channel
    #   @return [true, false]

    # @!attribute [r] move_members
    #   @!parse alias_method :move_members?, :move_members
    #   Allows for moving of members between voice channels
    #   @return [true, false]

    # @!attribute [r] use_vad
    #   @!parse alias_method :use_vad?, :use_vad
    #   Allows for using voice-activity-detection in a voice channel
    #   @return [true, false]

    # @!attribute [r] priority_speaker
    #   @!parse alias_method :priority_speaker?, :priority_speaker
    #   Allows for using priority speaker in a voice channel
    #   @return [true, false]

    # @!attribute [r] stream
    #   @!parse alias_method :stream?, :stream
    #   Allows the user to go live
    #   @return [true, false]

    # @!attribute [r] change_nickname
    #   @!parse alias_method :change_nickname?, :change_nickname
    #   Allows for modification of own nickname
    #   @return [true, false]

    # @!attribute [r] manage_nicknames
    #   @!parse alias_method :manage_nicknames?, :manage_nicknames
    #   Allows for modification of other users nicknames
    #   @return [true, false]

    # @!attribute [r] manage_roles
    #   @!parse alias_method :manage_roles?, :manage_roles
    #   Allows management and editing of roles
    #   @return [true, false]

    # @!attribute [r] manage_webhooks
    #   @!parse alias_method :manage_webhooks?, :manage_webhooks
    #   Allows management and editing of webhooks
    #   @return [true, false]

    # @!attribute [r] manage_emojis
    #   @!parse alias_method :manage_emojis?, :manage_emojis
    #   Allows management and editing of emojis
    #   @return [true, false]

    Rapture::PermissionFlags.constants.each do |perm_name|
      perm_value = PermissionFlags.const_get(perm_name)
      perm_name = perm_name.downcase
      define_method(perm_name) do
        @mask & perm_value == perm_value
      end

      alias_method :"#{perm_name}?", perm_name
    end

    def initialize(mask)
      @mask = mask
    end

    # Return the integer representation of the internal mask
    # @return [Integer]
    def to_i
      @mask
    end
  end
end
