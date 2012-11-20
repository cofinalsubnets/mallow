$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'rake'
require 'mallow'

mallow = Gem::Specification.new do |spec|
  spec.name = 'mallow'
  spec.version = Mallow::VERSION
  spec.add_development_dependency 'rspec'
  spec.author = 'feivel jellyfish'
  spec.email = 'feivel@sdf.org'
  spec.files = FileList['lib/**/*.rb']
  spec.summary = 'Data deserializer'
  spec.homepage = 'http://github.com/gwentacle/mallow'
  spec.description = 'Itty-bitty data deserializer with a friendly interface.'
end

