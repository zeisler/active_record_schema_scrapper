class ActiveRecordSchemaScrapper
  class Attributes
    DEFAULT_REGISTERED_TYPES = [
      { type: :integer, replacement_type: Integer },
      { type: :float, replacement_type: Float },
      { type: :decimal, replacement_type: BigDecimal },
      { type: Proc.new { |type| [:timestamp, :time].include?(type) }, replacement_type: Time },
      { type: :datetime, replacement_type: DateTime },
      { type: :date, replacement_type: Date },
      { type: Proc.new { |type| [:text, :string, :binary].include?(type) }, replacement_type: String },
      { type: :boolean, replacement_type: Axiom::Types::Boolean },
      { type: :hstore, replacement_type: Hash },
    ].freeze

    DEFAULT_REGISTERED_DEFAULTS = [
      { default: Proc.new { |d| d == "t" }, replacement_default: true },
      { default: Proc.new { |d| d == "f" }, replacement_default: false }
    ].freeze

    class << self
      # @param [Symbol] name original type from schema
      # @param [Object, Virtus::Attribute] klass a ruby type used to coerce values
      # @param [Object#===, Proc#===] cast_type to be compared to the db schema returned value
      def register_type(name:, klass:, cast_type: :not_given)
        registered_types << { type: name, replacement_type: klass, cast_type: cast_type }
      end

      def registered_types
        @registered_types ||= DEFAULT_REGISTERED_TYPES.dup
      end

      def reset_registered_types
        @registered_types = DEFAULT_REGISTERED_TYPES.dup
      end

      module DeprecatedRegisterDefaultKeywords
        # @param [String] name original default value from schema
        # @param [Object] klass the replacement value
        # @param [Object#===, Proc#===] cast_type to be compared to the db schema returned value
        # @param [Symbol] type matches the type from the schema
        def register_default(**args)
          if args.has_key?(:name)
            deprecation_warning(:name, :default)
            args[:default] = args.delete(:name)
          end
          if args.has_key?(:klass)
            deprecation_warning(:klass, :replacement_default)
            args[:replacement_default] = args.delete(:klass)
          end
          super(args)
        end

        private

        def deprecation_warning(old_key, new_key)
          puts "Deprecation warning ActiveRecordSchemaScrapper::Attributes.register_default: keyword `#{old_key}` is replaced by `#{new_key}`"
        end
      end

      prepend DeprecatedRegisterDefaultKeywords

      # @param [String] default original default value from schema
      # @param [Object] replacement_default the replacement value
      # @param [Object#===, Proc#===] cast_type to be compared to the db schema returned value
      # @param [Symbol] type matches the type from the schema
      def register_default(default:, replacement_default:, cast_type: :not_given, type: :not_given)
        registered_defaults << { default: default, replacement_default: replacement_default, cast_type: cast_type, type: type }
      end

      def registered_defaults
        @registered_defaults ||= DEFAULT_REGISTERED_DEFAULTS.dup
      end

      def reset_registered_defaults
        @registered_defaults = DEFAULT_REGISTERED_DEFAULTS.dup
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
