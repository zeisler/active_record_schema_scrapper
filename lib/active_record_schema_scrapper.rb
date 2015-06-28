require "active_record_schema_scrapper/version"
require 'active_record_schema_scrapper/attribute'

module ActiveRecordSchemaScrapper
  def self.get(model)
    model.columns_hash.map do |k, v|
      Attribute.new(name:      k,
                    type:      v.type,
                    precision: v.cast_type.precision,
                    limit:     v.cast_type.limit,
                    scale:     v.cast_type.scale,
                    default:   v.default,
                    null:      v.null,
      )
    end

  end
end
