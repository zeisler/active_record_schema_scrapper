require "active_record_schema_scrapper/version"
require "active_record_schema_scrapper/attribute"
require "active_record_schema_scrapper/attributes"
require "active_record_schema_scrapper/association"
require "active_record_schema_scrapper/associations"

module ActiveRecordSchemaScrapper

  def self.new(model:)
    MetaSchema.new(model)
  end

  class MetaSchema

    def initialize(model)
      @model = model
    end

    def associations(**args)
      Associations.new(args.merge({model: model}))
    end

    def attributes(**args)
      Attributes.new(args.merge({model: model}))
    end

    def table_name
      model.table_name
    end

    private
    attr_reader :model
  end
end
