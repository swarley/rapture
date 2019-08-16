# frozen_string_literal: true

describe Rapture::CachedClient do
  before do
    @client = Rapture::CachedClient.new("Bot INVALID-TOKEN")
  end

  describe "#initialize" do
    before do
      @client = Rapture::CachedClient.new("Bot INVALID-TOKEN")
    end

    it "creates a default cache for all caches" do
      %I[user_cache guild_cache guild_role_cache guild_channel_cache channel_cache role_cache member_cache].each do |cache_name|
        assert(@client.respond_to? cache_name)
        assert_kind_of(Rapture::Cache, @client.__send__(cache_name))
      end
    end
  end

  describe "#initialize_cache_handlers" do
    it "creates handlers for relevant events" do
      handler_names = %I[guild_create channel_create channel_update channel_delete guild_update
                         guild_delete guild_member_add guild_member_update guild_member_remove
                         guild_members_chunk guild_role_create guild_role_update guild_role_delete
                         presence_update]
      handler_names.each do |handler_name|
        assert(@client.instance_variable_get(:@event_handlers)[handler_name.upcase].count > 0)
      end
    end
  end
end
