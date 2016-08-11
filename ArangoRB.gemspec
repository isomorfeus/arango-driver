# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rake"

Gem::Specification.new do |s|
  s.name        = 'arangorb'
  s.version	    = '1.0.0'
  s.authors     = ['Stefano Martin']
  s.email       = ['stefano@seluxit.com']
  s.homepage    = 'https://github.com/StefanoMartin/ArangoRB'
  s.license     = 'MIT'
  s.summary     = 'A simple ruby client for ArangoDB'
  s.description = "ArangoDB is a powerful mixed database based on documents and graphs. ArangoRB is an experimental Ruby gems that uses ArangoDB's HTTP API."
  s.platform	   = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.files         = FileList['lib/*', 'spec/**/*', 'ArangoRB.gemspec', 'Gemfile', 'LICENSE', 'README.md'].to_a
  s.add_dependency 'httparty', '~> 0.14', '>= 0.14.0'
end
