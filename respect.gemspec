$:.push File.expand_path("../lib", __FILE__)

# The gem's version:
require "respect/version"

Gem::Specification.new do |s|
  s.name        = "respect"
  s.version     = Respect::VERSION
  s.authors     = ["Nicolas Despres"]
  s.email       = ["nicolas.despres@gmail.com"]
  s.homepage    = "http://nicolasdespres.github.io/respect"
  s.summary     = "Object schema definition using a Ruby DSL."
  s.description = "Respect lets you specify object schema using a Ruby DSL. It also provides validators, sanitizers and dumpers to generate json-schema.org compliant spec. It is perfect to specify JSON document structure."

  s.files = Dir["lib/**/*"] + [
    "MIT-LICENSE",
    "Rakefile",
    "README.md",
    "STATUS_MATRIX.html",
    "RELEASE_NOTES.md",
    "RELATED_WORK.md",
  ]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", "~> 3.0"

  s.add_development_dependency 'yard', '~> 0.8.5.2'
  s.add_development_dependency 'mocha', '~> 0.13.3'
  s.add_development_dependency 'rake', '~> 10.0.4'
  s.add_development_dependency 'redcarpet', '~> 2.2.2'
  s.add_development_dependency 'debugger', '~> 1.6.1'
end
