# frozen_string_literal: true

module Rapture
  # @abstract Subclass and override `#resolve`, `#cache`,
  #   `#remove`, and `#each` to implement a custom Cache.
  # @api Cache
  # @note See {Rapture::DefaultCache} as an example of an "in memory"
  #   Cache implementation.
  # Heavy inspiration for abstract caching has been drawn from
  # z64's discordcr [cache refactor](https://github.com/z64/discordcr/tree/refactor/cache-2)
  class Cache
    include Enumerable

    # Retrieve an object by its key
    def resolve(key); end

    # Store an object in the cache, returning the stored value
    def cache(key, value); end

    # Retrieve an object from the cache, or store the result of
    # the yielded block
    def fetch(key)
      resolve(key) || cache(key, yield)
    end

    # Remove an object from the cache by its key
    def remove(key); end

    # Implement an each method to make use of Enumerable methods.
    def each(&block); end
  end

  # A cache to be used when no caching is desired
  class NullCache < Cache
    # Return the value without storing it
    def cache(_key, value)
      value
    end
  end

  # This is the default cache that stores objects in memory
  class DefaultCache < Cache
    def initialize
      @cache = {}
    end

    # (see Cache#cache)
    def cache(key, value)
      @cache[key] = value
    end

    # (see Cache#remove)
    def remove(key)
      @cache.delete(key)
    end

    # (see Cache#resolve)
    def resolve(key)
      @cache[key]
    end

    # Iterate over the underlying hash
    def each(&block)
      @cache.each(&block)
    end
  end
end
