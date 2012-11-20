require 'mallow'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = 'documentation'
  config.order = :rand
end

def verify_success(rule, examples)
  examples.each do |e,s|
    rule[e].first.should == s
  end
end

def verify_values(rule, examples)
  examples.each do |e,v|
    rule[e].last.should == v
  end
end

