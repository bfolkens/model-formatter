# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "model_formatter"
  s.version     = '0.0.3'
  s.authors     = ["Brad Folkens", "Tyler Rick"]
  s.email       = ["bfolkens@gmail.com", "tyler@tylerrick.com"]
  s.homepage    = "https://github.com/bfolkens/model-formatter"
  s.summary     = %q{Easily handle fields in ActiveRecord that need to be formatted or stripped of formatting as they are set or retrieved.}
  s.description = %q{Allows you to easily handle fields in Rails / ActiveRecord that need to be formatted or stripped of formatting as they are set or retrieved from the database.}
	s.license			= 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
