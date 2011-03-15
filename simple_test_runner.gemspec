# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_test_runner/version"

Gem::Specification.new do |s|
  s.name        = "simple_test_runner"
  s.version     = SimpleTestRunner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Roush"]
  s.email       = ["jeff@jeffroush.com"]
  s.homepage    = ""
  s.summary     = %q{Monitors directories; runs a command when it sees a chane.}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "simple_test_runner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
