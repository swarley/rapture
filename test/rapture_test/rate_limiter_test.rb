# frozen_string_literal: true

describe Rapture::HTTP::RateLimiter do
  describe Rapture::HTTP::Bucket do
    it "locks when there are no requests remaining" do
      open_bucket = Rapture::HTTP::Bucket.new(4, 4, Time.now + 1)
      refute(open_bucket.will_limit?)
      refute(open_bucket.locked?)

      empty_bucket = Rapture::HTTP::Bucket.new(3, 0, Time.now + 0.2)
      assert(empty_bucket.will_limit?)
      refute(empty_bucket.locked?)

      before = Time.now
      empty_bucket.lock_until_reset

      assert_in_delta(Time.now.to_f, before.to_f + 0.2, 0.01)
    end
  end

  describe Rapture::HTTP::RateLimiter do
    it "groups bucket access" do
      limiter = Rapture::HTTP::RateLimiter.new

      key_a_1 = [:a, 1]
      key_a_2 = [:a, 2]
      key_b_3 = [:b, 3]

      reset_time = Time.now + 10

      limiter.update(key_a_1, :bucket_a, 3, 3, reset_time)
      limiter.update(key_a_2, :bucket_a, 3, 1, reset_time)
      limiter.update(key_b_3, :bucket_b, 1, 1, reset_time)

      assert_equal(
        limiter.get_from_key(key_a_1),
        limiter.get_from_id(:bucket_a)
      )

      assert_equal(
        limiter.get_from_key(key_a_2),
        limiter.get_from_id(:bucket_a)
      )

      assert_equal(
        limiter.get_from_key(key_b_3),
        limiter.get_from_id(:bucket_b)
      )

      [limiter.get_from_key(key_a_1), limiter.get_from_key(key_a_2)].each do |bucket|
        assert_equal(bucket.limit, 3)
        assert_equal(bucket.remaining, 1)
        assert_equal(bucket.reset_time, reset_time)
      end

      bucket = limiter.get_from_key(key_b_3)
      assert_equal(bucket.limit, 1)
      assert_equal(bucket.remaining, 1)
      assert_equal(bucket.reset_time, reset_time)

      refute(limiter.get_from_key([:c, 4]))
      refute(limiter.get_from_id(:bucket_c))
    end
  end
end
