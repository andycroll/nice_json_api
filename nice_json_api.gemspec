# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nice_json_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'nice_json_api'
  spec.version       = NiceJsonApi::VERSION
  spec.authors       = ['Andy Croll']
  spec.email         = ['andy@goodscary.com']

  spec.summary       = %q{A wrapper around Net::HTTP for any nice JSON API}
  spec.description   = %q{Designed to need no dependancies other than Ruby's standard Net::HTTP,
                          this gem allows you play nicely with nice JSON-based APIs}
  spec.homepage      = 'https://github.com/andycroll/nice_json_api'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'webmock'
end
