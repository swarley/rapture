# frozen_string_literal: true

module Rapture
  # Module containing functions that return URLs
  # to CDN data.
  module CDN
    # CDN base URL
    BASE = "https://cdn.discordapp.com"
    # All the powers of two between 16 and 2048, which are
    # valid image sizes
    SIZES = Set[16, 32, 64, 128, 256, 512, 1024, 2048]

    module_function

    # The url to a custom guild emoji
    # @param emoji_id [Integer]
    # @param ext ["png", "gif"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def custom_emoji_url(emoji_id, ext: "png", size: nil)
      check_extension!(%w[png gif], ext)
      check_size!(size) if size

      "#{BASE}/emojis/#{emoji_id}.#{ext}" + get_query(size)
    end

    # The url to a custom guild icon
    # @param guild_id [Integer]
    # @param icon [String] icon hash from a {Guild} object
    # @param ext ["png", "jpeg, "webp", "gif"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def guild_icon_url(guild_id, icon, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp gif], ext)
      check_size!(size) if size

      "#{BASE}/icons/#{guild_id}/#{icon}.#{ext}" + get_query(size)
    end

    # The url to a custom guild splash
    # @param guild_id [Integer]
    # @param splash [String] splash hash from a {Guild} object
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def guild_splash_url(guild_id, splash, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp], ext)
      check_size!(size) if size

      "#{BASE}/splashes/#{guild_id}/#{splash}.#{ext}" + get_query(size)
    end

    # The url to a custom guild banner
    # @param guild_id [Integer]
    # @param banner [String] the banner hash from a {Guild} object
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def guild_banner_url(guild_id, banner, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp], ext)
      check_size!(size) if size

      "#{BASE}/banners/#{guild_id}/#{banner}.#{ext}" + get_query(size)
    end

    # The url to a default user avatar
    # @param discrim [Integer] A {User} discriminator
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if size is invalid
    # @return [String]
    def default_user_avatar_url(discrim, size: nil)
      check_size!(size) if size

      "#{BASE}/embed/avatars/#{discrim % 5}.png" + get_query(size)
    end

    # The url to a custom user avatar
    # @param user_id [Integer]
    # @param avatar [String] the avatar hash from a {User} object
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def user_avatar_url(user_id, avatar, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp gif], ext)
      check_size!(size) if size

      "#{BASE}/avatars/#{user_id}/#{avatar}.#{ext}" + get_query(size)
    end

    # The url to a custom application icon
    # @param id [Integer]
    # @param icon [String] the icon hash from an {Application} object
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def application_icon_url(id, icon, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp], ext)
      check_size!(size) if size

      "#{BASE}/app-icons/#{id}/#{icon}.#{ext}" + get_query(size)
    end

    # The url to an application asset
    # @param id [Integer]
    # @param asset_id [String]
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def application_asset_url(id, asset_id, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp], ext)
      check_size!(size) if size

      "#{BASE}/app-assets/#{id}/#{asset_id}.#{ext}" + get_query(size)
    end

    # The url to a custom team icon
    # @param id [Integer]
    # @param icon [String] the icon hash from a {Team} object
    # @param ext ["png", "jpeg", "webp"]
    # @param size [Integer] One of {SIZES}
    # @raise [ArgumentError] Raises if ext or size are invalid
    # @return [String]
    def team_icon_url(id, icon, ext: "png", size: nil)
      check_extension!(%w[png jpeg webp], ext)
      check_size!(size)

      "#{BASE}/team-icons/#{id}/#{icon}.#{ext}" + get_query(size)
    end

    private

    # Raise an ArgumentError if this extension is not valid for the endpoint
    def self.check_extension!(ext_list, ext)
      unless ext_list.include? ext.downcase
        raise ArgumentError, "Invalid extension type: #{ext}"
      end
    end

    # Determines if a number is valid as a size argument.
    # Must be a power of 2 between 16 and 2048. Otherwise raises
    # an ArgumentError
    def self.check_size!(size)
      unless SIZES.include? size
        raise ArgumentError, "Invalid image size: #{size}. Must be a power of 2 between 16 and 2048"
      end
    end

    # Return a size query if size is defined
    def self.get_query(size = nil)
      size ? "?size=#{size}" : ""
    end

    private_class_method :check_extension!
    private_class_method :check_size!
    private_class_method :get_query
  end
end
