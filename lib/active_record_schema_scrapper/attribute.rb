require "virtus"

class ActiveRecordSchemaScrapper
  class UnregisteredType < StandardError
  end

  class Attribute
    include Virtus.model
    attribute :name

    class DBToRubyType < Virtus::Attribute
      def coerce(value)
        return value if value.nil?
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
        if (a = Attributes.registered_types.detect { |name, klass| value.to_sym == name.to_sym })
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
        if (r = Attributes.registered_defaults.detect { |name, _| value.to_s == name.to_s })
          r.last
        else
          value
        end
      end
    end
    attribute :default, DefaultValueType
  end
end