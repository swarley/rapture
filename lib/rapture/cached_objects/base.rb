# frozen_string_literal: true

module Rapture::CachedObjects
  def self.Base(klass)
    delegate_klass = Class.new(klass)
    delegate_klass.instance_exec do
      klass.properties.each_key do |prop|
        define_method(prop) do
          @delegate.__send__(prop)
        end
      end

      define_method(:initialize) do |client, data|
        @client = client
        @delegate = data
      end

      define_method(:to_h) do
        @delegate.to_h
      end

      define_method(:to_json) do
        @delegate.to_json
      end

      define_method(:client) { @client }
      define_method(:cache) { @cache }

      private :client
      private :cache
    end

    delegate_klass
  end

  module ModifySetter
    private

    # @!macro [attach] modify_setter
    #   @!attribute [rw] $1
    #     @return [self]
    #   @!method set_$1(value, reason: nil)
    #     @return [self]
    #     @param reason [String] audit log reason
    def setter(name)
      define_method(:"#{name}=") do |value|
        self.modify(name => value)
      end

      define_method(:"set_#{name}") do |value, reason: nil|
        self.modify(name => value, :reason => reason)
      end
    end
  end
end