# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ydim/html/version'

Gem::Specification.new do |spec|
  spec.name        = "ydim-html"
  spec.version     = YDIM::Html::VERSION
  spec.author      = "Masaomi Hatakeyama, Zeno R.R. Davatz, Niklaus Giger"
  spec.email       = "mhatakeyama@ywesee.com, zdavatz@ywesee.com, ngiger@ywesee.com"
  spec.description = "ywesee distributed invoice manager. A Ruby gem"
  spec.summary     = "ywesee distributed invoice manager"
  spec.homepage    = "https://github.com/zdavatz/ydim"
  spec.license       = "GPL-v2"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sbsm",    '= 1.2.7'
  spec.add_dependency "htmlgrid",'>= 1.0.8'
  spec.add_dependency "ydim",    '>= 1.1.0'
  spec.add_dependency "rclconf"
  spec.add_dependency "syck"
  # spec.add_runtime_dependency 'deprecated', '= 2.0.1'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "flexmock"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "watir"
  spec.add_development_dependency "rspec"
end
