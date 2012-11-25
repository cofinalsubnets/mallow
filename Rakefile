require 'rake'
require 'graham/rake_task'

Graham::RakeTask.new
task default: :test

namespace :gem do
  task :build do
    sh "gem b mallow.gemspec"
  end
  task :install do
    sh "gem i #{Dir.glob('mallow-*.gem').sort.last}"
  end
end
task gem: %w{ gem:build gem:install }

