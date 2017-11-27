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
  end

  # TODO: Probably refactor this to use another Example class
  # that doesn't involve converters. This is fine for now.
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
