# frozen_string_literal: true

require "rapture"

# Create a custom cache class that inherits the
# hash based default cache.
class CacheHotPaths < Rapture::DefaultCache
  # Initialize our instance variable and call `super()` to ensure
  # that the internal hash is set up.
  def initialize(hot_count)
    @hot_count = hot_count
    @count_map = {}
    super()
  end

  # `resolve` is called when a key is being looked up. In this example we use it to
  # see how often the resource is being requested.
  def resolve(key)
    if @count_map[key] < @hot_count
      @count_map[key] += 1
      Rapture::LOGGER.info("HotCache") { "Increased the count for #{key} to #{@count_map[key]}" }
    end

    super
  end

  # `cache` is called when we store the data. In this case, we only want to store the data that
  # has been requested more than `@hot_count` times. If our number is less than that return the
  # data, otherwise we call `super` and allow the caching to proceed
  def cache(key, data)
    if (@count_map[key] ||= 1) < @hot_count
      Rapture::LOGGER.info("HotCache") { "Not caching #{key} yet. #{@count_map[key]}/#{@hot_count}" }
      return data
    else
      Rapture::LOGGER.info("HotCache") { "Cached #{key}!" }
    end

    super
  end
end

client = Rapture::CachedClient.new(ENV["RAPTURE_EXAMPLE_TOKEN"])
# We will use the channel cache for this example
client.channel_cache = CacheHotPaths.new(3)

client.on_message_create do |message|
  # We request the channel with this command. Do it twice and your channel will get
  # cached on the third. (We get one request done automatically from GUILD_CREATE)
  if message.content == "!cacheme"
    client.get_channel(message.channel_id)
  end
end

client.run
