# frozen_string_literal: true

Oj.mimic_JSON

# DSL module for mapping objects to JSON
module Rapture::Mapping
  module Converters
    Converter = Struct.new(:to_json_proc, :from_json_proc) do
      def to_json()
        to_json_proc
      end

      def from_json()
        proc do |data|
          if data.is_a? Array
            data.collect { |elem| from_json_proc.call(elem) }
          else
            from_json_proc.call(data)
          end
        end
      end
    end

    NilableConverter = Struct.new(:to_json_proc, :from_json_proc) do
      def to_json()
        proc do |data|
          next unless data

          to_json_proc.call(data)
        end
      end

      def from_json()
        proc do |data|
          next unless data
          from_json_proc.call(data) if data

          if data.is_a? Array
            data.collect { |elem| from_json_proc.call(elem) }
          else
            from_json_proc.call(data)
          end
        end
      end
    end

    def self.converter(name, nilable: false, to_json: nil, from_json: nil)
      conv = Converter.new(to_json, from_json)

      define_singleton_method(name) { conv }
      return unless nilable

      nilable_conv = NilableConverter.new(to_json, from_json)

      define_singleton_method(:"#{name}?") { nilable_conv }
    end

    # @!group Converters

    # Snowflake serde
    converter(
      :Snowflake,
      nilable: true,
      from_json: proc { |id| Integer(id) },
      to_json: proc { |int| int.to_s },
    )

    # Timestamp serde
    converter(
      :Timestamp,
      nilable: true,
      from_json: proc { |data| Time.parse(data) },
      to_json: proc { |time| time.iso8601(3) },
    )

    # @!endgroup
  end

  # @!visibility private
  def self.included(object)
    object.extend(DSL)
  end

  # DSL for mapping an object
  module DSL
    # @return [Hash{Symbol => Hash, nil}] hash of property names and their options
    attr_reader :properties

    # Adds a property to this model
    def getter(name, converter: nil, **options)
      attr_reader name

      # @todo Fix this to actually be included in options
      if converter
        options = {from_json: converter.from_json, to_json: converter.to_json}.merge(options)
      end

      (@properties ||= {})[name] = options
    end

    # Creates a new instance of this object from a JSON string
    # @param data [String] the raw JSON string
    def from_json(data)
      hash = Oj.load(data, symbol_keys: true)
      from_h(hash, :from_json)
    end

    def from_json_array(data)
      array = Oj.load(data, symbol_keys: true)
      array.collect { |hash| from_h(hash, :from_json) }
    end

    # Creates a new instance of this object from a hash
    # @param hash [Hash] hash to convert into a new object
    # @param converter [Symbol] converter to use on the hash values, i.e. :from_json
    def from_h(hash, converter = nil)
      instance = new

      hash.each do |k, v|
        v = convert(v, k, converter) if converter
        begin
          instance.instance_variable_set(:"@#{k}", v)
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
    rescue Exception => ex
      puts "EXCEPTION ON PROP"
      puts prop
      p @properties
      raise ex
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
  def to_json(_json_state = nil)
    hash = to_h(:to_json)
    Oj.dump(hash, omit_nil: true)
  end
end
