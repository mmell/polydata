$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "polydata/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "polydata"
  s.version     = Polydata::VERSION
  s.authors     = ["Mike Mell"]
  s.email       = ["mike.mell@nthwave.net"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Polydata."
  s.description = "TODO: Description of Polydata."

  s.require_paths = ["lib"]

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.1.1"

end
