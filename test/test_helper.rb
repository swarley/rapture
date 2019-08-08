# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rapture"

require "minitest/autorun"
require "minitest/ci"
require "minitest/spec"

def json_data(name)
  path = File.join(File.expand_path("data", __dir__), "#{name}.json")
  File.read(path)
end

def parsed_json_data(name)
  Oj.load(json_data(name), symbolize_keys: true)
end
