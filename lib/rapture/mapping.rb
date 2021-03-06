# frozen_string_literal: true

Oj.mimic_JSON

# DSL module for mapping objects to JSON
module Rapture::Mapping
  # Create converters that handle special serde operations
  module Converters
    # Struct used for constructing a converter that passes procs for
    # conversions
    Converter = Struct.new(:to_json_proc, :from_json_proc) do
      # Pass the to_json proc
      def to_json(*_args)
        to_json_proc
      end

      # Pass a from_json proc that creates an array of
      # objects if neccesary
      def from_json
        proc do |data|
          if data.is_a? Array
            data.collect { |elem| from_json_proc.call(elem) }
          else
            from_json_proc.call(data)
          end
        end
      end
    end

    # A Converter struct that allows for nilable/optional values
    NilableConverter = Struct.new(:to_json_proc, :from_json_proc) do
      # Pass a to_json proc that is called if the data is not nil
      def to_json(*_args)
        proc do |data|
          to_json_proc.call(data) if data
        end
      end

      # Pass a from_json proc that allows for null values
      def from_json
        proc do |data|
          if data.is_a? Array
            data.collect { |elem| from_json_proc.call(elem) }
          elsif data
            from_json_proc.call(data)
          end
        end
      end
    end

    # Create a special method that returns a struct containing procs for serde
    def self.converter(name, nilable: false, to_json: nil, from_json: nil)
      conv = Converter.new(to_json, from_json)

      define_singleton_method(name) { conv }
      return unless nilable

      nilable_conv = NilableConverter.new(to_json, from_json)

      define_singleton_method(:"#{name}?") { nilable_conv }
    end

    # @!group Converters

    # Snowflake serde
    # @!method Snowflake
    #   @return [Converter]
    # @!method Snowflake?
    #   @return [NilableConverter]
    converter(
      :Snowflake,
      nilable: true,
      from_json: proc { |id| Integer(id) },
      to_json: :to_s,
    )

    # Timestamp serde
    # @!method Timestamp
    #   @return [Converter]
    # @!method Timestamp?
    #   @return [NilableConverter]
    converter(
      :Timestamp,
      nilable: true,
      from_json: proc { |data| Time.parse(data) },
      to_json: proc { |time| time.iso8601(6) },
    )

    converter(:Permissions,
              to_json: :to_i,
              from_json: proc { |mask| Rapture::Permissions.new(mask) })

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
      options = {from_json: converter.from_json, to_json: converter.to_json}.merge(options) if converter

      (@properties ||= {})[name] = options
    end

    # Creates a new instance of this object from a JSON string
    # @param data [String] the raw JSON string
    def from_json(data)
      hash = Oj.load(data, symbol_keys: true)
      from_h(hash, :from_json)
    end

    # Create an Array of this object type from a json array
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
        instance.instance_variable_set(:"@#{k}", v)
      end

      instance
    end

    # @!visibility private
    def convert(value, prop, option_method)
      case action = @properties.dig(prop, option_method)
      when Symbol
        value.send(action)
      when Class
        convert_class(value, action, option_method)
      when Proc
        action.call(value)
      when nil
        value
      else
        raise ArgumentError, "Action must be a symbol or respond to :call"
      end
    rescue Exception => _e
      raise Rapture::SerdeError, "Failed to convert property: `#{prop}' in #{self}"
    end

    # @!visibility private
    def convert_class(value, action, option_method)
      case value
      when Hash
        action.from_h(value, option_method)
      when Array
        convert_array(value, action, option_method)
      when action
        value.to_h(option_method)
      end
    end

    # @!visibility private
    def convert_array(value, action, option_method)
      value.map do |element|
        if element.is_a? action
          element.to_h(option_method)
        else
          action.from_h(element, option_method)
        end
      end
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
