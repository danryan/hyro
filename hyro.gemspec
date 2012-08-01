# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hyro/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mars Hall"]
  gem.email         = ["mars@crowdflower.com"]
  gem.description   = %q{Hy-speed Remote Objects!}
  gem.summary       = %q{A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hyro"
  gem.require_paths = ["lib"]
  gem.version       = Hyro::VERSION
  
  # specify any dependencies here; for example:
  gem.add_development_dependency "rspec"
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'debugger'
  gem.add_dependency "faraday", '~> 0.8', '>= 0.8.1'
  gem.add_dependency "faraday_middleware", '~> 0.8', '>= 0.8.8'
  gem.add_dependency "activemodel", '~> 3.2', '>= 3.2.7'
end
