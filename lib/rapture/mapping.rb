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

    # Creates a new instance of this object from a JSON string, or a hash
    def from_json(data)
      hash = if data.is_a?(Hash)
               data
             elsif data.is_a?(String)
               Oj.load(data, symbol_keys: true)
             else
               raise ArgumentError, 'Must pass a hash or a JSON string'
             end

      instance = new

      hash.each do |k, v|
        value = instance.convert(v, k, :from_json)
        instance.send(:"#{k}=", value)
      end

      instance
    end
  end

  # @!visibility private
  def convert(value, prop, option_method)
    if (action = self.class.properties.dig(prop, option_method))
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
    hash = {}

    self.class.properties.each_key do |prop|
      value = send(prop)
      hash[prop] = convert(value, prop, :to_json)
    end

    Oj.dump(hash, omit_nil: true)
  end
end
