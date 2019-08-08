# frozen_string_literal: true

require "rapture"

describe Rapture::Mapping do
  class Example
    include Rapture::Mapping
    getter :foo
    getter :bar
    getter(:baz,
           to_json: proc { |i| i.to_s },
           from_json: :to_i)
  end

  class ClassExample
    include Rapture::Mapping
    getter :inner, from_json: Example, to_json: Example
  end

  class ArrayExample
    include Rapture::Mapping
    getter :values, from_json: Example
  end

  class AbstractObject
    def to_h(_)
      {foo: :bar}
    end
  end

  class AbstractObjectExample
    include Rapture::Mapping
    getter :values, to_json: AbstractObject
  end

  class ErrorExample
    include Rapture::Mapping
    getter :foo, from_json: "Not valid"
  end

  before do
    @raw_json = %({"foo":"bar","bar":true,"baz":"1"})
    @object = Example.from_json(@raw_json)
  end

  describe "dsl" do
    it "defines a method for each property" do
      %i[foo bar baz].each { |m| assert_respond_to(@object, m) }
    end
  end

  describe ".from_json" do
    it "set the correct values" do
      assert_equal(
        ["bar", true, 1],
        %i[foo bar baz].map { |m| @object.send(m) }
      )
    end

    it "converts an inner object" do
      json = %({"inner":#{@raw_json}})
      object = ClassExample.from_json(json)
      inner_object = Example.from_h(Oj.load(json, symbol_keys: true)[:inner], :from_json)
      assert_equal(
        %i[foo bar baz].map { |m| inner_object.send(m) },
        %i[foo bar baz].map { |m| object.inner.send(m) }
      )
    end

    it "converts an array of objects" do
      json = %({"values":[#{@raw_json}]})
      ArrayExample.from_json(json)
    end

    it "converts an array of abstract objects" do
      abstract = AbstractObjectExample.from_h(values: [AbstractObject.new])
      assert_equal(
        abstract.to_json,
        %({"values":[{"foo":"bar"}]})
      )
    end
  end

  describe ".from_json_array" do
    it "creates an array of objects from a json array" do
      object = Example.from_json(@raw_json).to_h

      json = %([#{@raw_json}])
      array = Example.from_json_array(json).collect(&:to_h)
      assert_equal(
        array,
        [object]
      )
    end
  end

  describe "#to_h" do
    it "converts to a hash correctly" do
      assert_equal(
        @object.to_h,
        foo: "bar", bar: true, baz: 1,
      )
    end
  end

  describe "#to_json" do
    it "serializes correctly" do
      assert_equal(@raw_json, @object.to_json)
    end

    it "serializes an inner object" do
      json = %({"inner":#{@raw_json}})
      object = ClassExample.from_json(json)
      assert_equal(object.to_json, json)
    end

    it "serializes an array of objects" do
      json = %({"values":[#{@raw_json}]})
      object = ArrayExample.from_json(json)
      assert_equal(object.to_json, json)
    end
  end

  describe "#convert" do
    it "raises an error if a converter has a mismatched type" do
      assert_raises(Rapture::SerdeError) do
        ErrorExample.from_json(@raw_json)
      end
    end
  end
end
