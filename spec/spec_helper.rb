$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record_schema_scrapper'

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

RSpec.configure do |c|
  # c.disable_monkey_patching!
  c.seed = rand(99999)
end
