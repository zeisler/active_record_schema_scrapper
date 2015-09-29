class ActiveRecordSchemaScrapper
  class Attributes

    def initialize(model:)
      @model = model
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
    end
  end
end