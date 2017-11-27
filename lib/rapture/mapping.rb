# frozen_string_literal: true

require 'oj'

Oj.mimic_JSON

# DSL module for mapping objects to JSON
module Rapture::Mapping
  # @!visibility private
  def self.included(object)
    object.extend(DSL)
  end

  # DSL for mapping an object
  module DSL
    # @return [Hash{Symbol => Hash, nil}] hash of property names and their options
    attr_reader :properties

    # Adds a property to this model
    def property(name, options = {})
      attr_accessor name
      (@properties ||= {})[name] = options
    end

    # Creates a new instance of this object from a JSON string
    # @param data [String] the raw JSON string
    def from_json(data)
      hash = Oj.load(data, symbol_keys: true)

      hash.each do |k, v|
        hash[k] = convert(v, k, :from_json)
      end

      from_h(hash)
    end

    # Creates a new instance of this object from a hash
    # @param hash [Hash] hash to convert into a new object
    # @param converter [Symbol] converter to use on the hash values, i.e. :from_json
    def from_h(hash, converter = nil)
      instance = new

      hash.each do |k, v|
        v = instance.convert(v, k, converter) if converter
        instance.send(:"#{k}=", v)
      end

      instance
    end

    # @!visibility private
    def convert(value, prop, option_method)
      if (action = @properties.dig(prop, option_method))
        value = if action.is_a?(Symbol)
                  value.send(action)
                elsif action.respond_to?(:call)
                  action.call(value)
                else
                  raise ArgumentError, 'Action must be a symbol or respond to :call'
                end
      end

      value
    end
  end

  # Utility method to convert this object into a hash
  # @return [Hash]
  def to_h
    data = {}

    self.class.properties.each_key do |prop|
      data[prop] = send(prop)
    end

    data
  end

  # Converts this object into a JSON string
  # @return [String]
  def to_json
    hash = to_h

    hash.each do |k, v|
      hash[k] = self.class.convert(v, k, :to_json)
    end

    Oj.dump(hash, omit_nil: true)
  end
end
