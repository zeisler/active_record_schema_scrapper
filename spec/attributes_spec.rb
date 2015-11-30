require "spec_helper"
require "models/db"
require "models"
require "active_record_schema_scrapper/attributes"

describe ActiveRecordSchemaScrapper::Attributes do
  describe "Enumerable" do
    context "returns columns with meta data" do
      it "User" do
        expect(described_class.new(model: User).map(&:to_h).map { |h| h.reject { |_, v| v.nil? } })
          .to eq(
                [{ name: "id", type: Fixnum },
                 { name: "name", type: String },
                 { name: "email", type: String, default: "" },
                 { name: "credits", type: BigDecimal, precision: 19, scale: 6 },
                 { name: "created_at", type: DateTime },
                 { name: "updated_at", type: DateTime },
                 { name: "password_digest", type: String },
                 { name: "remember_token", type: Axiom::Types::Boolean, default: true },
                 { name: "admin", type: Axiom::Types::Boolean, default: false }]
              )
      end

      context "Account" do
        it "can iterate over twice" do
          subject = described_class.new(model: Account)
          expect(subject.map(&:to_h).map { |h| h.reject { |_, v| v.nil? } })
          .to eq(
                [{ name: "id", type: Fixnum },
                 { name: "user_id", type: Fixnum },
                 { name: "balance", type: BigDecimal }]
              )
          expect(subject.map(&:to_h).map { |h| h.reject { |_, v| v.nil? } })
            .to eq(
                  [{ name: "id", type: Fixnum },
                   { name: "user_id", type: Fixnum },
                   { name: "balance", type: BigDecimal }]
                )
        end
      end

      it "ChildModel" do
        expect(described_class.new(model: ChildModel).map(&:to_h).map { |h| h.reject { |_, v| v.nil? } })
          .to eq(
                [{ name: "id", type: Fixnum },
                 { name: "name", type: String },
                 { name: "email", type: String, default: "" },
                 { name: "credits", type: BigDecimal, precision: 19, scale: 6 },
                 { name: "created_at", type: DateTime },
                 { name: "updated_at", type: DateTime },
                 { name: "password_digest", type: String },
                 { name: "remember_token", type: Axiom::Types::Boolean, default: true },
                 { name: "admin", type: Axiom::Types::Boolean, default: false }]
              )
      end
    end
  end

  describe "#errors" do

    it "returns errors messages when and model doesn't respond to column_hash" do
      class InvalidClass
      end

      subject = described_class.new(model: InvalidClass)
      expect(subject.to_a).to eq([])
      error = subject.errors.first
      expect(error.class_name).to eq("InvalidClass")
      expect(error.message).to eq("InvalidClass is not a valid ActiveRecord model.")
      expect(error.original_error.to_s).to eq("undefined method `columns_hash' for InvalidClass:Class")
      expect(error.level).to eq(:error)
    end

    it "has no table error for abstract class" do
      subject = described_class.new(model: HasNoTable)
      expect(subject.to_a).to eq([])
      error = subject.errors.first
      expect(error.class_name).to eq("HasNoTable")
      expect(error.message).to eq("Could not find table for abstract_class")
      expect(error.original_error.to_s).to match(/Could not find table/)
      expect(error.level).to eq(:warn)
    end

    it "has no table error for non abstract class" do
      subject = described_class.new(model: HasNoTable)
      allow(HasNoTable).to receive(:abstract_class?){false}
      expect(subject.to_a).to eq([])
      error = subject.errors.first
      expect(error.class_name).to eq("HasNoTable")
      expect(error.message).to eq("Could not find table 'has_no_tables'")
      expect(error.original_error.to_s).to eq("Could not find table 'has_no_tables'")
      expect(error.level).to eq(:error)
    end
  end

  describe "::register_type" do

    it "add new type" do
      described_class.register_type(name: :array, klass: Array)
      expect(ActiveRecordSchemaScrapper::Attribute.new(type: :array).type).to eq(Array)
    end

    context "unknown types will raise" do

      it "foo_type" do
        expect { ActiveRecordSchemaScrapper::Attribute.new(type: :foo_type).type }
          .to raise_error(ActiveRecordSchemaScrapper::UnregisteredType, "Database type 'foo_type' is not a registered type.\nTo register use ActiveRecordSchemaScrapper::Attributes.register_type(name: :foo_type, klass: <RubyClass>)")
      end

      it "another_type" do
        expect { ActiveRecordSchemaScrapper::Attribute.new(type: :another_type).type }
          .to raise_error(ActiveRecordSchemaScrapper::UnregisteredType, "Database type 'another_type' is not a registered type.\nTo register use ActiveRecordSchemaScrapper::Attributes.register_type(name: :another_type, klass: <RubyClass>)")
      end
    end
  end

  describe "::register_default" do

    it "add default type converter" do
      described_class.register_default(name: "T", klass: true)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: :T).default).to eq(true)
    end

    it "will pass nil if no registered value" do
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: nil).default).to eq(nil)
    end

    it "will pass value if no registered value" do
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: :Q).default).to eq(:Q)
    end
  end
end