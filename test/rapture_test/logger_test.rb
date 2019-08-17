# frozen_string_literal: true

describe Rapture::Logger do
  before do
    @buffer = StringIO.new
    @logger = Rapture::Logger.new(@buffer)
    @logger.level = :debug
  end

  it "functions as a logger" do
    @logger.debug("test")
    assert(@buffer.string =~ /DEBUG .+ test/)
  end

  describe "#ignore" do
    before do
      @buffer = StringIO.new
      @logger = Rapture::Logger.new(@buffer)
    end

    it "ignores info and debug by default" do
      @logger.ignore("test")
      @logger.debug("test") { "should be ignored" }
      @logger.info("test") { "should be ignored" }
      assert(@buffer.length.zero?)

      @logger.warn("test") { "should not be ignored" }
      refute(@buffer.length.zero?)
    end

    it "ignores everything when set to :all" do
      @logger.ignore("test", :all)

      @logger.debug("test") { "should be ignored" }
      @logger.info("test") { "should be ignored" }
      @logger.warn("test") { "should be ignored" }
      @logger.error("test") { "should be ignored" }
      @logger.unknown("test") { "should be ignored" }

      assert(@buffer.length.zero?)
    end
  end
end
