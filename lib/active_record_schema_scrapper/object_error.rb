class ActiveRecordSchemaScrapper
  class ErrorObject
    attr_reader :level, :message, :class_name, :type, :original_error

    def initialize(level: :warn, message:, class_name:, type:, original_error: nil)
      @level          = level
      @message        = message
      @class_name     = class_name
      @type           = type
      @original_error = original_error
    end

    def original_error?
      original_error.present?
    end

    private

    def self.levels
      [:info, :warn, :error, :fatal]
    end
  end
end