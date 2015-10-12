
Gem::Specification.new do |s|
  s.name        = "datastruct"
  s.version     = "0.0.3"
  s.date        = "2015-07-02"
  s.licenses    = ["GPL"]
  s.summary     = "A great base class for data structures"
  s.description = <<TEXT
    Datastruct is made to be a more feature rich alternative to Ruby's Struct
    class. It defines several methods common for data structures, like hash
    lookup and serialization to JSON and YAML. See the README file for examples.
TEXT
  s.authors     = ["Tomas Sandven"]
  s.email       = "tomas191191@gmail.com"
  s.homepage    = "https://github.com/Hubro/Datastruct"

  s.files       = Dir["lib/datastruct.rb"]

  s.required_ruby_version = ">= 2.0.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5"
  s.add_development_dependency "mocha", "~> 1"
  s.add_development_dependency "pry"
  s.add_development_dependency "byebug"
  s.add_development_dependency "yard", "~> 0"
  s.add_development_dependency "redcarpet", "~> 3"   # Git flavored markdown
end
