require 'rake'
require_relative 'lib/mallow'

task default: 'test:case'

task test: %w{ test:unit test:case }
namespace :test do
  %w{ unit case }.each do |test|
    task test do
      Dir["test/#{test}/*.rb"].each {|file| load file}
    end
  end
end

task :gem do
  sh "gem i #{`gem b mallow.gemspec`.split("\n").last.split(/ /).last}"
end

