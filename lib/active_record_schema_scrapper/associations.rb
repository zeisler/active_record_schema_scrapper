module ActiveRecordSchemaScrapper
  class Associations

    def initialize(model:)
      @model = model
    end

    include Enumerable

    def each
      types.each do |type|
        model.reflect_on_all_associations(type).each do |a|
          puts ''
          hash = if a.try(:delegate_reflection)
                   { source:    a.delegate_reflection.options[:source],
                     through:   a.delegate_reflection.options[:through],
                     dependent: a.delegate_reflection.options[:dependent],
                   }
                 else
                   { source:    a.try(:delegate_reflection).try(:name),
                     through:   a.try(:through),
                     dependent: a.options[:dependent] }
                 end.merge({
                             name:        a.name,
                             foreign_key: a.foreign_key,
                             class_name:  a.klass.name,
                             type:        type,
                           })
          yield(Association.new(hash))
        end
      end


    end

    private

    def select_only_current_class(type)
      model.reflect_on_all_associations(type).select do |a|
        klass.relationships.send(type).map(&:name).include?(a.name)
      end
    end

    def belongs_to
      select_only_current_class(:belongs_to)
    end

    def has_one
      select_only_current_class(:has_one)
    end

    def has_and_belongs_to_many
      select_only_current_class(:has_and_belongs_to_many)
    end

    def has_many
      select_only_current_class(:has_many)
    end

    def types
      [:has_and_belongs_to_many, :belongs_to, :has_one, :has_many]
    end

    attr_reader :model

  end
end