# frozen_string_literal: true

describe Rapture::Mapping do
  class Example
    include Rapture::Mapping
    property :foo
    property :bar
    property(:baz,
             to_json: proc { |i| i.to_s },
             from_json: :to_i)
  end

  class ClassExample
    include Rapture::Mapping
    property :inner, from_json: Example, to_json: Example
  end

  before do
    @raw_json = %({"foo":"bar","bar":true,"baz":"1"})
    @object = Example.from_json(@raw_json)
  end

  describe 'dsl' do
    it 'defines a method for each property' do
      %i[foo bar baz].each { |m| assert_respond_to(@object, m) }
    end
  end

  describe '.from_json' do
    it 'set the correct values' do
      assert_equal(
        ['bar', true, 1],
        %i[foo bar baz].map { |m| @object.send(m) }
      )
    end

    it 'converts an inner object' do
      json = %({"inner":#{@raw_json}})
      object = ClassExample.from_json(json)
      inner_object = Example.from_h(Oj.load(json, symbol_keys: true)[:inner], :from_json)
      assert_equal(
        %i[foo bar baz].map { |m| inner_object.send(m) },
        %i[foo bar baz].map { |m| object.inner.send(m) }
      )
    end
  end

  describe '#to_h' do
    it 'converts to a hash correctly' do
      assert_equal(
        @object.to_h,
        foo: 'bar', bar: true, baz: 1
      )
    end
  end

  describe '#to_json' do
    it 'serializes correctly' do
      assert_equal(@raw_json, @object.to_json)
    end
  end
end
