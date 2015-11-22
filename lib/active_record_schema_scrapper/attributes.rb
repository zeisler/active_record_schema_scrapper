class ActiveRecordSchemaScrapper
  class Attributes

    def initialize(model:)
      @model  = model
      @errors = []
    end

    include Enumerable

    def each
      call.each { |attr| yield(attr) }
    end

    def to_a
      map { |v| v }
    end

    def self.register_type(name:, klass:)
      registered_types << [name, klass]
    end

    def self.registered_types
      @registered_types ||= []
    end

    def self.register_default(name:, klass:)
      registered_defaults << [name, klass]
    end

    def self.registered_defaults
      @registered_defaults ||= []
    end

    attr_reader :errors

    private

    attr_reader :model

    def call
      @attributes ||= model.columns_hash.map do |k, v|
        ActiveRecordSchemaScrapper::Attribute.new(
            name:      k,
            type:      v.type,
            precision: v.cast_type.precision,
            limit:     v.cast_type.limit,
            scale:     v.cast_type.scale,
            default:   v.default,
            null:      v.null,
        )
      end
    rescue NoMethodError => e
      @errors << OpenStruct.new(class_name:    model.name,
                                message:       "#{model.name} is not a valid ActiveRecord model.",
                                original_error: e)
    end
  end
end