# frozen_string_literal: true

describe Rapture::DefaultCache do
  before do
    @cache = Rapture::DefaultCache.new
  end

  describe "#remove" do
    it "removes values from the cache" do
      @cache.cache(:key, :value)
      @cache.remove(:key)
      assert_nil(@cache.resolve(:key))
    end
  end

  describe "#resolve" do
    it "returns nil when there is no object stored" do
      assert_nil(@cache.resolve(:key))
    end

    it "returns a stored value when the key has been cached" do
      assert_nil(@cache.resolve(:key))
      @cache.cache(:key, :value)
      assert_equal(@cache.resolve(:key), :value)
    end
  end

  describe "#fetch" do
    it "returns the cached value if it exists" do
      @cache.cache(:key, :value)
      refute_nil(@cache.fetch(:key) { nil })
    end

    it "returns the result of the block if the key does not exist" do
      refute_nil(@cache.fetch(:key) { :value })
    end
  end
end
