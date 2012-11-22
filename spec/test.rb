require 'testrocket'
CASE_DIR = File.dirname(__FILE__) + '/cases'
Dir.foreach(CASE_DIR) { |test| load "#{CASE_DIR}/#{test}" }

