# frozen_string_literal: true

require "rapture/mapping"

describe Rapture::Mapping::Converters do
  module Rapture::Mapping::Converters
    converter(
      :Example,
      nilable: false,
      to_json: proc { :to_json },
      from_json: proc { :from_json },
    )
    converter(
      :NilableExample,
      nilable: true,
      to_json: proc { :to_json },
      from_json: proc { :from_json },
    )
  end

  class ConverterData
    include Rapture::Mapping

    getter :data, converter: Converters.Example
  end

  class NilableConverterData
    include Rapture::Mapping

    getter :data, converter: Converters.NilableExample?
  end

  describe ".converter" do
    Rapture::Mapping::Converters.module_exec do
      converter(
        :ConverterTest,
        nilable: false,
        to_json: proc { :to_json },
        from_json: proc { :from_json },
      )

      converter(
        :NilableConverterTest,
        nilable: true,
        to_json: proc { :to_json },
        from_json: proc { :from_json },
      )
    end

    it "creates a converter method with to_json and from_json methods" do
      converter = Rapture::Mapping::Converters.ConverterTest

      assert_equal(
        %i[to_json from_json],
        [converter.to_json.call, converter.from_json.call]
      )
    end

    describe "nilable" do
      before do
        @converter = Rapture::Mapping::Converters.NilableConverterTest?
      end

      it "returns nil if data provided is nil" do
        assert_nil(@converter.to_json.call(nil))
        assert_nil(@converter.from_json.call(nil))
      end

      it "returns normally if not nil" do
        refute_nil(@converter.to_json.call(true))
        refute_nil(@converter.from_json.call(true))
      end
    end
  end

  describe Rapture::Mapping::Converters::Converter do
    describe ".to_json" do
      it "deserializes data" do
        object = ConverterData.new
        object.instance_variable_set(:@data, :unconverted)

        assert_equal(
          %({"data":"to_json"}),
          object.to_json
        )
      end

      it "returns an array of the object if the json data is an array" do
        object = ConverterData.from_json(%({"data": [1, 2]}))
        assert_equal(
          %i[from_json from_json],
          object.data
        )
      end
    end

    describe ".from_json" do
      it "serializes data" do
        object = ConverterData.from_json(%({"data": null}))
        assert_equal(
          :from_json,
          object.data
        )
      end
    end
  end

  describe Rapture::Mapping::Converters::NilableConverter do
    before do
      @nil_json = %({"data": null})
      @non_nil_json = %({"data": "foo"})
      @non_nil_array_json = %({"data": [1, 2]})
    end

    describe ".from_json" do
      it "returns nil if the data is nil" do
        object = NilableConverterData.from_json(@nil_json)
        assert_nil(object.data)
      end

      it "returns data if the data is not nil" do
        object = NilableConverterData.from_json(@non_nil_json)
        refute_nil(object.data)
      end

      it "returns an array of the object if the json data is an array" do
        object = NilableConverterData.from_json(@non_nil_array_json)
        assert_equal(
          %i[from_json from_json],
          object.data
        )
      end
    end

    describe ".to_json" do
      before do
        @object = NilableConverterData.new
      end

      it "is excluded if the value is unset or nil" do
        assert_equal(
          @object.to_json,
          "{}"
        )
      end

      it "is included if the value is non-nil" do
        @object = NilableConverterData.from_h(data: true)

        refute_equal(
          @object.to_json,
          "{}"
        )
      end
    end
  end

  describe "Converters.Snowflake" do
    class SnowflakeTest
      include Rapture::Mapping

      getter :data, converter: Converters.Snowflake
    end

    before do
      @raw_json = %({"data":"608068378644578327"})
      @object = SnowflakeTest.from_json(@raw_json)
    end

    describe ".from_json" do
      it "converts to an Integer" do
        assert_kind_of(
          Integer,
          @object.data
        )
      end
    end

    describe ".to_json" do
      it "converts to a numeric String" do
        assert_equal(
          @raw_json,
          @object.to_json
        )
      end
    end
  end

  describe "Converters.Timestamp" do
    class TimestampTest
      include Rapture::Mapping
      getter :data, converter: Converters.Timestamp
    end

    before do
      @raw_json = %({"data":"2019-08-08T15:42:01.659000+00:00"})
      @object = TimestampTest.from_json(@raw_json)
    end

    describe ".from_json" do
      it "converts to a Time object" do
        assert_kind_of(
          Time,
          @object.data
        )
      end
    end

    describe ".to_json" do
      it "converts from time to an ISO8601 formatted string" do
        assert_equal(
          @raw_json,
          @object.to_json
        )
      end
    end
  end

  describe "Converters.Permissions" do
    class PermissionsTest
      include Rapture::Mapping
      getter :data, converter: Converters.Permissions
    end

    before do
      @raw_json = %({"data":2112})
      @object = PermissionsTest.from_json(@raw_json)
    end

    describe ".from_json" do
      it "converts to a Permissions object from an Integer" do
        assert_kind_of(
          Rapture::Permissions,
          @object.data
        )
      end
    end

    describe ".to_json" do
      it "converts to an Integer from a Permissions object" do
        assert_equal(
          @raw_json,
          @object.to_json
        )
      end
    end
  end
end
