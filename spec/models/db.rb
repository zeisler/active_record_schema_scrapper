require 'active_record'
require 'sqlite3'
require 'logger'

logger = Logger.new(STDOUT)

ActiveRecord::Base.logger = logger
ActiveRecord::Base.establish_connection(adapter:  'sqlite3',
                                        database: ":memory:",
                                        verbosity: "quiet")

ActiveRecord::Migration.verbose = false

ActiveRecord::Migration.suppress_messages do
  require_relative "schema.rb"
end

