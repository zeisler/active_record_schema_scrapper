require "active_record_schema_scrapper/version"
require "active_record_schema_scrapper/attribute"
require "active_record_schema_scrapper/attributes"
require "active_record_schema_scrapper/association"
require "active_record_schema_scrapper/associations"

class ActiveRecordSchemaScrapper
  def initialize(model:, association_opts: {}, attribute_opts: {})
    @model            = model
    @association_opts = association_opts.merge(model: model)
    @attribute_opts   = attribute_opts.merge(model: model)
  end

  def associations
    @associations ||= Associations.new(association_opts)
  end

  def attributes
    @attributes ||= Attributes.new(attribute_opts)
  end

  def table_name
    model.table_name
  end

  def abstract_class?
    model.abstract_class? || false
  end

  private
  attr_reader :model, :association_opts, :attribute_opts
end
