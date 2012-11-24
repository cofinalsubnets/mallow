require 'rake'

task default: :test

task :test do
  ruby 'test/test.rb'
end

task :gem do
  sh "gem i #{`gem b mallow.gemspec`.split("\n").last.split(/ /).last}"
end

