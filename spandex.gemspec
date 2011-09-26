# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spandex/version"

Gem::Specification.new do |s|
  s.name        = "spandex"
  s.version     = Spandex::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Isaac Cambron"]
  s.email       = ["icambron@alum.mit.edu"]
  s.homepage    = ""
  s.summary     = "A simple content engine"
  s.description = "Spandex manages a store of markup files and their metadata, useful in building blogs or blog engines"

  s.add_dependency "tilt"
  s.add_dependency "ratom"

  s.add_development_dependency "rspec"
  s.add_development_dependency "redcarpet"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end