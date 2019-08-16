# frozen_string_literal: true

require "test_helper"
require "rapture_test/mapping_test"
require "rapture_test/converters_test"
require "rapture_test/user_test"
require "rapture_test/cache_test"
require "rapture_test/cached_client_test"
require "rapture_test/rate_limiter_test"

Rapture::LOGGER.level = :fatal

describe Rapture do
  it "has a version number" do
    refute_nil Rapture::VERSION
  end

  describe "encode_json" do
    it "removes keys with nil values" do
      hash_with_nil = {nil_key: nil, key: true}

      after_enc = Oj.load(Rapture.encode_json(hash_with_nil))
      refute_includes(after_enc.keys, "nil_key")
      assert_includes(after_enc.keys, "key")
    end

    it "changes :null values to a persisting nil" do
      hash_with_nil_and_null = {null_key: :null, nil_key: nil, key: true}

      after_enc = Oj.load(Rapture.encode_json(hash_with_nil_and_null))
      refute_includes(after_enc.keys, "nil_key")
      assert_includes(after_enc.keys, "null_key")
      assert_includes(after_enc.keys, "key")

      assert(after_enc["key"])
      assert_nil(after_enc["null_key"])
    end
  end
end
