# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rapture/version"

Gem::Specification.new do |spec|
  spec.name = "rapture"
  spec.version = Rapture::VERSION
  spec.authors = ["Zac Nowicki", "Matt Carey"]
  spec.email = ["zachnowicki@gmail.com", "matthew.b.carey@gmail.com"]

  spec.summary = "A Discord API library for Ruby"
  spec.homepage = "https://github.com/swarley/rapture"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|doc)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.13"
  spec.add_dependency "faraday_middleware", "~> 0.13"
  spec.add_dependency "faye-websocket"
  spec.add_dependency "mime-types", "~> 3.2"
  spec.add_dependency "oj", "~> 3.3"

  spec.add_development_dependency "bundler", "~> 2.0.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-ci", "~> 3.4"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rufo", "~> 0.4.0"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "yard", "~> 0.9"
end
