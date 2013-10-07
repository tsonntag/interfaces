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
  gem.add_dependency  'activesupport', '>= 3.2'
  gem.add_dependency  'activemodel', '>= 3'
  gem.add_dependency  'active_attr'
  gem.add_dependency  'net-sftp'
  gem.add_dependency  'zip'
end
