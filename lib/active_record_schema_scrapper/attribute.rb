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

      default = init_default({ default: default, cast_type: cast_type, type: type })
      type    = init_type(type, { type: type, cast_type: cast_type })
      super
    end

    private

    def init_type(name, attr_values)
      type = match_abstract(:replacement_type, :type, Attributes.registered_types, attr_values)
      if type.is_a?(String) || type.is_a?(Symbol)
        raise UnregisteredType.new "Database type '#{attr_values[:type]}' is not a registered type.\nTo register use ActiveRecordSchemaScrapper::Attributes.register_type(name: :#{name}, klass: <RubyClass>)"
      else
        type
      end
    end

    def init_default(attr_values)
      match_abstract(:replacement_default, :default, Attributes.registered_defaults, attr_values)
    end

    def match_abstract(replacement_key, default, registers, attr_values)
      return unless attr_values[default]
      top_ranked_match     = nil
      last_top_match_count = 0
      registers.each do |register|
        all_given = register.reject { |_, v| v == :not_given }.dup
        all_given.delete(replacement_key)

        matches         = all_given.map do |k, v|
          attr_values.has_key?(k) ? (v === attr_values[k] || v == attr_values[k]) : true
        end
        max_match_count = matches.inject(0) { |sum, bool| bool ? sum += 1 : sum -= 10 }
        if max_match_count > 0 && max_match_count > last_top_match_count
          last_top_match_count = max_match_count
          top_ranked_match     = register
        end
      end

      top_ranked_match ? top_ranked_match[replacement_key] : attr_values[default]
    end

    attribute :type
    attribute :precision, Integer
    attribute :scale, Integer
    attribute :default
    attribute :cast_type
  end
end
