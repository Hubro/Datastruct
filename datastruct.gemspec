
require_relative "lib/datastruct.rb"

Gem::Specification.new do |s|
  s.name        = "datastruct"
  s.version     = DataStruct::VERSION
  s.licenses    = ["GPL"]
  s.summary     = "A great base class for data structures"
  s.description = File.read("README.rdoc")
  s.authors     = ["Tomas Sandven"]
  s.email       = "tomas191191@gmail.com"
  s.homepage    = "https://github.com/Hubro/Datastruct"

  s.files       = Dir["lib/datastruct.rb"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5"
  s.add_development_dependency "mocha", "~> 1"
  s.add_development_dependency "pry"
  s.add_development_dependency "byebug"
  s.add_development_dependency "yard", "~> 0"
end
