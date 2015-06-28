require 'active_record'
require 'sqlite3'
require 'logger'


File.delete('debug.log')
ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection(adapter:  'sqlite3',
                                        database: ":memory:",
                                        verbosity: "quiet")

ActiveRecord::Migration.verbose = false

ActiveRecord::Migration.suppress_messages do
  require_relative "schema.rb"
end

