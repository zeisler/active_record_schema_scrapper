class ActiveRecordSchemaScrapper
  class Attributes

    class << self
      # @param [Symbol] name original type from schema
      # @param [Object, Virtus::Attribute] klass a ruby type used to coerce values
      # @param [Object#===, Proc#===] cast_type to be compared to the db schema returned value
      def register_type(name:, klass:, cast_type: nil)
        registered_types << [name, klass, cast_type]
      end

      def registered_types
        @registered_types ||= []
      end

      # @param [String] name original default value from schema
      # @param [Object] klass the replacement value
      # @param [Object#===, Proc#===] cast_type to be compared to the db schema returned value
      # @param [Symbol] type matches the type from the schema
      def register_default(name:, klass:, cast_type: nil, type: nil)
        registered_defaults << [name, klass, cast_type, type]
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
          cast_type: cast_type(v)
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

    def cast_type(v)
      if v.respond_to?(:cast_type)
        v.cast_type
      elsif v.respond_to?(:sql_type_metadata)
        v.sql_type_metadata
      end
    end
  end
end
