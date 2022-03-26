require_relative "lib/base/version"

Gem::Specification.new do |s|
  s.name        = 'base-lang'
  s.version     = Base::VERSION
  s.summary     = "A simple assembly language, compiler and VM"
  s.description = "A simple stack-based assembly programming language and VM, made for learning."
  s.authors     = ["Mog Nesbitt"]
  s.email       = 'mog@seriousorange.com'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "sample/*.base", "*.md"]
  s.executables = ['base']
  s.homepage    = 'https://github.com/mogest/base-lang'
  s.license     = 'MIT'
end
