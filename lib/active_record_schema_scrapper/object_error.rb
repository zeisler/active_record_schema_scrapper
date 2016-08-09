# frozen_string_literal: true
require "virtus"

class ActiveRecordSchemaScrapper
  if defined?(ActiveMocker::ErrorObject)
    ErrorObject = Class.new(ActiveMocker::ErrorObject)
  else
    class ErrorObject
      include Virtus.model
      attribute :message
      attribute :level
      attribute :original_error
      attribute :type
      attribute :class_name
    end
  end
end
