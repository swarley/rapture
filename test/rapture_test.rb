# frozen_string_literal: true

require "test_helper"
require "rapture_test/mapping_test"

class RaptureTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rapture::VERSION
  end
end
