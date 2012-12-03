# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "model_formatter/version"

Gem::Specification.new do |s|
  s.name        = "model_formatter"
  s.version     = ModelFormatter.version
  s.authors     = ["Brad Folkens", "Tyler Rick"]
  s.email       = ["tyler@tylerrick.com"]
  s.homepage    = "https://github.com/TylerRick/model_formatter"
  s.summary     = %q{Allows you to easily handle fields in Rails / ActiveRecord that need to be formatted or stripped of formatting as they are set or retrieved from the database.}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
