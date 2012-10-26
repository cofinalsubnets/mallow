require 'rake'

mallow = Gem::Specification.new do |spec|
  spec.name = 'mallow'
  spec.version = '0.0.1'
  spec.author = 'feivel jellyfish'
  spec.email = 'feivel@sdf.org'
  spec.files = FileList['lib/**/*.rb']
  spec.summary = 'Data deserializer with a friendly interface.'
end
