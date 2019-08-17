# frozen_string_literal: true

module Rapture::CachedObjects
  def self.Base(klass)
    delegate_klass = Class.new
    delegate_klass.instance_exec do
      klass.properties.each_key do |prop|
        define_method(prop) do
          @delegate.__send__(prop)
        end
      end

      define_method(:initialize) do |client, cache, data|
        @client = client
        @cache = cache
        @delegate = data
      end

      define_method(:to_h) do
        @delegate.to_h
      end

      define_method(:to_json) do
        @delegate.to_json
      end

      define_private_method(:client) { @client }
      define_private_method(:cache) { @cache }
    end
    
    delegate_klass
  end
end