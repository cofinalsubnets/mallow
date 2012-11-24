$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'rake'
require 'mallow/version'

mallow = Gem::Specification.new do |spec|
  spec.name        = 'mallow'
  spec.version     = Mallow::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['mallow.gemspec','README.md','Rakefile','lib/**/*.rb']
  spec.test_files  = FileList['test/**/*.rb']
  spec.homepage    = 'http://github.com/gwentacle/mallow'
  spec.summary     = 'Tiny universal data deserializer / self-implementing test engine'
  spec.description = 'Tiny universal data deserializer / self-implementing test engine'
end

