require "virtus"

class ActiveRecordSchemaScrapper
  class UnregisteredType < StandardError
  end

  class Attribute
    include Virtus.model
    attribute :name

    def initialize(type: nil,
                   precision: nil,
                   scale: nil,
                   default: nil,
                   cast_type: nil,
                   name: nil,
                   limit: nil,
                   null: nil)

      type    = init_type(type, cast_type)
      default = init_default(default, cast_type, type)
      super
    end

    def init_type(type, cast_type)
      return type unless type
      registered_type = Attributes.registered_types.detect do |reg_type, klass, reg_cast_type|
        if type.to_sym == reg_type.to_sym && reg_cast_type && reg_cast_type === cast_type
          klass
        elsif type.to_sym == reg_type.to_sym
          klass
        end
      end
      (registered_type && !registered_type.empty?) ? registered_type[1] : type
    end

    def init_default(default, cast_type, type)
      return default unless default
      registered_default = Attributes.registered_defaults.detect do |reg_default, klass, reg_cast_type, reg_type|
        if (default.to_s == reg_default.to_s) && ((reg_cast_type && reg_cast_type === cast_type) || (type === reg_type))
          klass
        elsif default.to_s == reg_default.to_s
          klass
        end
      end
      (registered_default && !registered_default.empty?) ? registered_default[1] : default
    end

    class DBToRubyType < Virtus::Attribute
      def coerce(value)
        return value if value.nil?
        return value unless value.is_a?(String) || value.is_a?(Symbol)
        case value.to_sym
          when :integer
            Fixnum
          when :float
            Float
          when :decimal
            BigDecimal
          when :timestamp, :time
            Time
          when :datetime
            DateTime
          when :date
            Date
          when :text, :string, :binary
            String
          when :boolean
            Axiom::Types::Boolean
          when :hstore
            Hash
          else
            registered(value) do
              raise UnregisteredType.new "Database type '#{value}' is not a registered type.\nTo register use ActiveRecordSchemaScrapper::Attributes.register_type(name: :#{value}, klass: <RubyClass>)"
            end
        end
      end

      def registered(value)
        if (a = Attributes.registered_types.detect { |name, _, _| value.to_sym == name.to_sym })
          a.last
        else
          yield
        end
      end
    end
    attribute :type, DBToRubyType
    attribute :precision, Fixnum
    attribute :scale, Fixnum
    class DefaultValueType < Virtus::Attribute
      def coerce(value)
        return value unless value.is_a?(String) || value.is_a?(Symbol)
        case value.to_s
          when 'f'
            false
          when 't'
            true
          else
            registered(value)
        end
      end

      def registered(value)
        if (r = Attributes.registered_defaults.detect { |name, _, _| name.to_s == value.to_s })
          r[1]
        else
          value
        end
      end
    end
    attribute :default, DefaultValueType
    attribute :cast_type
  end
end
