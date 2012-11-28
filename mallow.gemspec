$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'rake'
require 'mallow/version'

Gem::Specification.new do |spec|
  spec.name        = 'mallow'
  spec.version     = Mallow::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['mallow.gemspec','README.md','lib/**/*.rb']
  spec.test_files  = FileList['Rakefile','test/**/*.rb']
  spec.homepage    = 'http://github.com/gwentacle/mallow'
  spec.summary     = 'Tiny universal data pattern matcher / dispatcher'
  spec.description = 'Tiny universal data pattern matcher / dispatcher'
  spec.add_development_dependency 'graham', '>=0.0.2'
end

