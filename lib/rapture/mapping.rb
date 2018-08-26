# frozen_string_literal: true

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
      from_h(hash, :from_json)
    end

    # Creates a new instance of this object from a hash
    # @param hash [Hash] hash to convert into a new object
    # @param converter [Symbol] converter to use on the hash values, i.e. :from_json
    def from_h(hash, converter = nil)
      instance = new

      hash.each do |k, v|
        v = convert(v, k, converter) if converter
        begin
          instance.send(:"#{k}=", v)
        rescue NoMethodError
          # puts "WARN: #{self} missing property: #{k} (raw value: #{v.inspect})"
        end
      end

      instance
    end

    # @!visibility private
    def convert(value, prop, option_method)
      if (action = @properties.dig(prop, option_method))
        value = if action.is_a?(Symbol)
                  value.send(action)
                elsif action.is_a?(Class)
                  if value.is_a?(Hash)
                    action.from_h(value, option_method)
                  elsif value.is_a?(Array)
                    value.map do |element|
                      if element.is_a?(action)
                        element.to_h(option_method)
                      else
                        action.from_h(element, option_method)
                      end
                    end
                  elsif value.is_a?(action)
                    value.to_h(option_method)
                  end
                elsif action.respond_to?(:call)
                  action.call(value)
                else
                  raise ArgumentError, "Action must be a symbol or respond to :call"
                end
      end

      value
    end
  end

  # Utility method to convert this object into a hash
  # @return [Hash]
  def to_h(converter = nil)
    data = {}

    self.class.properties.each_key do |prop|
      v = send(prop)
      data[prop] = if converter
                     self.class.convert(v, prop, converter)
                   else
                     v
                   end
    end

    data
  end

  # Converts this object into a JSON string
  # @return [String]
  def to_json
    hash = to_h(:to_json)
    Oj.dump(hash, omit_nil: true)
  end
end
