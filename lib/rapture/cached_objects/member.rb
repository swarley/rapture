# frozen_string_literal: true

module Rapture::CachedObjects
  class Member < Base(Rapture::Member)
    def initialize(client, cache, data)
      super(data)
      @client = client
      @cache = cache
  end