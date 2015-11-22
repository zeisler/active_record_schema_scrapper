class ActiveRecordSchemaScrapper
  class Associations

    def initialize(model:, types: self.class.types)
      @model = model
      @types = types
    end

    include Enumerable

    def each
      types.each do |type|
        model.reflect_on_all_associations(type).each do |a|
          begin
            hash = if a.try(:delegate_reflection)
                     { source:    a.delegate_reflection.options[:source],
                       through:   a.delegate_reflection.options[:through],
                       dependent: a.delegate_reflection.options[:dependent],
                     }
                   else
                     { source:    a.try(:delegate_reflection).try(:name),
                       through:   a.try(:through),
                       dependent: a.options[:dependent] }
                   end.merge(name:        a.name,
                             foreign_key: a.foreign_key,
                             class_name:  a.klass.name,
                             type:        type)

            yield(ActiveRecordSchemaScrapper::Association.new(hash))
          rescue NameError => e
            errors << OpenStruct.new(class_name:    model.name,
                                     message:       "Missing model #{a.name.to_s.camelize} for association #{model.name}.belongs_to :#{a.name}",
                                     original_error: e)
          end
        end
      end
    end

    def to_a
      map { |v| v }
    end

    def errors
      @errors ||= []
    end


    def self.types
      [:has_and_belongs_to_many, :belongs_to, :has_one, :has_many]
    end

    private

    attr_reader :model, :types

  end
end