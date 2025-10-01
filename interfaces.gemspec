# -*- encoding: utf-8 -*-
require File.expand_path('../lib/interfaces/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors         = ["Thomas Sonntag"]
  gem.email           = ["git@sonntagsbox.de"]
  gem.description     = %q{Implements file transfer through various protocols}
  gem.summary         = %q{Implements file transfer through various protocols }
  gem.homepage        = ""

  gem.executables     = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files           = `git ls-files`.split("\n")
  gem.test_files      = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name            = "interfaces"
  gem.require_paths   = ["lib"]
  gem.version         = Interfaces::VERSION
  gem.add_dependency  'activesupport', '~> 6.0'
  gem.add_dependency  'activemodel', '~> 6.0'
  gem.add_dependency  'active_attr', '~> 0.15'
  gem.add_dependency  'net-sftp', '~> 2.1'
  gem.add_dependency  'rubyzip', '>= 1.2.2'
  gem.add_dependency  'zip-zip'
end
