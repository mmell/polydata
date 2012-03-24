$:.push File.expand_path("../lib", __FILE__)

require "polydata/version"

Gem::Specification.new do |s|
  s.name        = "polydata"
  s.version     = Polydata::VERSION
  s.authors     = ["Mike Mell"]
  s.email       = ["mike.mell@nthwave.net"]
  s.homepage    = "https://github.com/mmell/polydata-client"
  s.summary     = "Polydata is an unconventional, poly-archical, addressable database loosely based on XRI identifiers."
  s.description = "The Polydata library provides authentication and translation of Ruby objects to arbitrary data formats for servers and clients."

  s.require_paths = ["lib"]

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

# at_linksafe is not on gemcutter...  s.add_dependency "at_linksafe"

end
