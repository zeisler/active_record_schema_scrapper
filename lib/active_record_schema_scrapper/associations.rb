class ActiveRecordSchemaScrapper
  class Associations

    def initialize(model:, types: self.class.types)
      @model  = model
      @types  = types
      @errors = []
    end

    def errors
      to_a
      @errors
    end

    include Enumerable

    def each
      return [] if abstract_class
      @each ||= types.each do |type|
        model.reflect_on_all_associations(type).each do |a|
          begin
            hash = if a.try(:delegate_reflection)
                     { source:    a.delegate_reflection.options[:source],
                       through:   a.delegate_reflection.options[:through],
                       dependent: a.delegate_reflection.options[:dependent],
                     }
                   else
                     { source:    (a.try(:delegate_reflection) || a.try(:source_reflection)).try(:name),
                       through:   a.try(:through) || a.try(:through_reflection).try(:name),
                       dependent: a.options[:dependent] }
                   end.merge(name:        a.name,
                             foreign_key: a.foreign_key,
                             class_name:  a.klass.name,
                             type:        type)

            yield(ActiveRecordSchemaScrapper::Association.new(hash))
          rescue NameError => e
            @errors << ErrorObject.new(
              class_name:     model.name,
              message:        "Missing model #{a.name.to_s.camelize.singularize} for association #{model.name}.belongs_to :#{a.name}",
              original_error: e,
              level:          :error,
              type:           :association
            )
          end
        end
      end
    end

    def to_a
      @to_a ||= map { |v| v }
    end

    def self.types
      [:has_and_belongs_to_many, :belongs_to, :has_one, :has_many]
    end

    private

    attr_reader :model, :types

    def abstract_class
      if model.abstract_class?
        @errors << ErrorObject.new(
          class_name: model.name,
          message:    "#{model.name} is an abstract class and has no associated table.",
          level:      :warn,
          type:       :no_table
        )
      end
    end
  end
end
