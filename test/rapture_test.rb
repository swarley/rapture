# frozen_string_literal: true

require "test_helper"
require "rapture_test/mapping_test"
require "rapture_test/converters_test"
require "rapture_test/user_test"

Rapture::LOGGER.level = :fatal

class RaptureTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rapture::VERSION
  end
end
