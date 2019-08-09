# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rapture"

require "minitest/autorun"
require "minitest/ci"
require "minitest/spec"

def json_data(name)
  @json_data_cache ||= {}

  return @json_data_cache[name] if @json_data_cache[name]

  path = File.join(File.expand_path("data", __dir__), "#{name}.json")
  @json_data_cache[name] = File.read(path)
end

def parsed_json_data(name)
  Oj.load(json_data(name), symbolize_keys: true)
end
