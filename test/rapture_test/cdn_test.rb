# frozen_string_literal: true

describe Rapture::CDN do
  method_names = (Rapture::CDN.methods - Module.new.methods)
  cdn_methods = method_names.collect { |mthd| Rapture::CDN.method(mthd) }
  cdn_methods.each do |mthd|
    describe ".#{mthd.name}" do
      before do
        @args = [nil] * mthd.parameters.count { |x| x[0] == :req }
      end

      it "raises when an invalid extension is passed" do
        assert_raises ArgumentError do
          mthd.call(*@args, ext: "invalid")
        end
      end

      it "raises when an invalid size is passed" do
        assert_raises ArgumentError do
          mthd.call(*@args, size: 0)
        end
      end
    end
  end
end
