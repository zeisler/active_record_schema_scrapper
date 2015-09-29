class ActiveRecordSchemaScrapper
  class Association
    include Virtus.model
    attribute :name, Symbol
    attribute :class_name, Symbol
    attribute :type, Symbol
    attribute :through, Symbol
    attribute :source, Symbol
    attribute :foreign_key, Symbol
    attribute :join_table, Symbol
    attribute :dependent, Symbol
  end
end