require 'spec_helper'
require "models/db"
require 'active_record_schema_scrapper/attribute'
require "models/user"

describe ActiveRecordSchemaScrapper do

  it do
    User.count
  end

  it 'has a version number' do
    expect(ActiveRecordSchemaScrapper::VERSION).not_to be nil
  end

end
