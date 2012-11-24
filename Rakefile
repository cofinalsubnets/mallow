require 'rake'
task default: :test

task test: %w{ test:unit test:case }
namespace :test do
  %w{ unit case }.each do |test|
    task test do
      require 'graham'
      require_relative 'lib/mallow'
      Dir["test/#{test}/**/*.rb"].each {|file| puts file.sub(/\.rb$/,''); load file}
    end
  end
end

task :gem do
  sh "gem i #{`gem b mallow.gemspec`.split("\n").last.split(/ /).last}"
end

