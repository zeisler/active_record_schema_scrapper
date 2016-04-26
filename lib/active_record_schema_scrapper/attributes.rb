class ActiveRecordSchemaScrapper
  class Attributes

    class << self
      def register_type(name:, klass:)
        registered_types << [name, klass]
      end

      def registered_types
        @registered_types ||= []
      end

      def register_default(name:, klass:)
        registered_defaults << [name, klass]
      end

      def registered_defaults
        @registered_defaults ||= []
      end
    end

    attr_reader :errors, :model
    private :model

    def initialize(model:)
      @model  = model
      @errors = []
    end

    include Enumerable

    def each
      call.each { |attr| yield(attr) }
    end

    def to_a
      @to_a ||= map { |v| v }
    end

    private

    def call
      @attributes ||= model.columns_hash.map do |k, v|
        ActiveRecordSchemaScrapper::Attribute.new(
          name:      k,
          type:      v.type,
          precision: v.precision,
          limit:     v.limit,
          scale:     v.scale,
          default:   v.default,
          null:      v.null,
        )
      end
    rescue NoMethodError => e
      @errors << ErrorObject.new(class_name:     model.name,
                                message:        "#{model.name} is not a valid ActiveRecord model.",
                                original_error: e,
                                level:          :error,
                                type:           :invalid_model)
      []
    rescue ActiveRecord::StatementInvalid => e
      level   = model.abstract_class? ? :warn : :error
      message = model.abstract_class? ? "#{model.name} is an abstract class and has no associated table." : e.message
      @errors << ErrorObject.new(class_name:     model.name,
                                message:        message,
                                original_error: e,
                                level:          level,
                                type:           :no_table)
      []
    end
  end
end
