require "time"

# Contains methods for handling HTTP requests
module Rapture::HTTP

  # @!visibility private
  # A bucket used for HTTP rate limiting
  class Bucket
    # @!attribute [r] limit
    # @return [Integer]
    attr_reader :limit

    # @!attribute [r] remaining
    # @return [Integer]
    attr_reader :remaining

    # @!attribute [r] reset_time
    # @return [Time]
    attr_reader :reset_time

    def initialize(limit, remaining, reset_time)
      update(limit, remaining, reset_time)

      @locked = false
      @mutex = Mutex.new
    end

    # @param limit [Integer]
    # @param remaining [Integer]
    # @param reset_time [Time]
    def update(limit, remaining, reset_time)
      @limit = limit
      @remaining = remaining
      @reset_time = reset_time
    end

    # @return [true, false]
    def will_limit?
      @remaining - 1 < 0 && Time.now <= @reset_time
    end

    # Lock and unlock this mutex (prevents access during reset)
    def wait_until_available
      return unless @locked
      @mutex.lock
      @mutex.unlock
    end

    # Lock the mutex for a given duration. Used for cooldown periods
    def lock_for(duration)
      @locked = true
      @mutex.synchronize { sleep duration }
      @locked = false
    end

    # Lock the mutex until the bucket resets
    def lock_until_reset
      time_remaining = @reset_time - Time.now

      raise "Cannot sleep for negative duration. Clock may be out of sync." if time_remaining.negative?

      lock_for(time_remaining)
    end

    # @return [true, false]
    def locked?
      @locked
    end
  end

  # @!visibility private
  # A rate limiting class used for our {Client}
  class RateLimiter
    def initialize
      @bucket_key_map = {}
      @bucket_id_map = {}
    end

    # Index a bucket based on the route key
    def get_from_key(key)
      @bucket_key_map[key]
    end

    # Index a bucket based on server side bucket id
    def get_from_id(id)
      @bucket_id_map[id]
    end

    # Update a rate limit bucket from response headers
    def update_from_headers(key, headers)
      limit = headers["x-ratelimit-limit"]&.to_i
      remaining = headers["x-ratelimit-remaining"]&.to_i
      bucket_id = headers["x-ratelimit-bucket"]
      reset_time = headers["x-ratelimit-reset"]&.to_f
      retry_after = headers["retry-after"]&.to_f
      server_time = Time.httpdate(headers["date"])

      if limit && remaining && reset_time && bucket_id
        reset = if retry_after
                  server_time + (retry_after / 1000)
                else
                  Time.at(reset_time)
                end
        update(key, bucket_id, limit, remaining, reset)
      elsif retry_after
        reset = server_time + retry_after
        update(key, bucket_id, 0, 0, reset_time)
      else
        raise "Bad headers when setting RL for #{key}"
      end
    end

    # Update a rate limit bucket
    def update(key, bucket_id, limit, remaining, reset_time)
      bucket = @bucket_id_map[bucket_id]
      if bucket
        bucket.update(limit, remaining, reset_time)
        @bucket_key_map[key] = bucket
      else
        bucket = Bucket.new(limit, remaining, reset_time)
        @bucket_key_map[key] = bucket
        @bucket_id_map[bucket_id] = bucket if bucket_id
      end
    end
  end
end
