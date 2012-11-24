require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec
task default: [:spec, :test]

task :test do
  ruby 'test/test.rb'
end
