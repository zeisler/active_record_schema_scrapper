require "spec_helper"
require "models/db"
require "models"
require "active_record_schema_scrapper/attributes"

describe ActiveRecordSchemaScrapper::Attributes do
  describe "Enumerable" do

    subject { described_class.new(model: model) }

    def filter_results(enum)
      enum.map do |e|
        e.to_h.each_with_object({}) do |(k,v),h|
          h[k] = v unless k == :cast_type || v.nil?
        end
      end
    end

    after do
      expect(subject.errors).to eq([])
    end

    context "returns columns with meta data" do

      let(:model) { User }

      it "User" do
        expect(filter_results(subject))
          .to eq(
                [{ name: "id", type: Integer },
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
        let(:model) { Account }
        it "can iterate over twice" do
          expect(filter_results(subject))
          .to eq(
                [{ name: "id", type: Integer },
                 { name: "user_id", type: Integer },
                 { name: "balance", type: BigDecimal }]
              )
          expect(filter_results(subject))
            .to eq(
                  [{ name: "id", type: Integer },
                   { name: "user_id", type: Integer },
                   { name: "balance", type: BigDecimal }]
                )
        end
      end

      context "ChildModel" do
        let(:model) { ChildModel }
        it do
          expect(filter_results(subject))
            .to eq(
                  [{ name: "id", type: Integer },
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
  end

  describe "#errors" do

    it "returns errors messages when and model doesn't respond to column_hash" do
      class InvalidClass
      end

      subject = described_class.new(model: InvalidClass)
      error = subject.errors.first
      expect(error.class_name).to eq("InvalidClass")
      expect(error.message).to eq("InvalidClass is not a valid ActiveRecord model.")
      expect(error.original_error.to_s).to eq("undefined method `columns_hash' for InvalidClass:Class")
      expect(error.level).to eq(:error)
      expect(error.type).to eq(:invalid_model)
    end

    it "has no table error for abstract class" do
      subject = described_class.new(model: HasNoTable)
      error = subject.errors.first
      expect(error.class_name).to eq("HasNoTable")
      expect(error.message).to eq("HasNoTable is an abstract class and has no associated table.")
      expect(error.original_error.to_s).to match(/Could not find table/)
      expect(error.level).to eq(:warn)
      expect(error.type).to eq(:no_table)
    end

    it "has no table error for non abstract class" do
      subject = described_class.new(model: HasNoTable)
      allow(HasNoTable).to receive(:abstract_class?){false}
      error = subject.errors.first
      expect(error.class_name).to eq("HasNoTable")
      expect(error.message).to match(/Could not find table/)
      expect(error.original_error.to_s).to match(/Could not find table/)
      expect(error.level).to eq(:error)
      expect(error.type).to eq(:no_table)
    end
  end

  describe "::register_type" do

    after do
      described_class.reset_registered_types
    end

    it "add new type" do
      described_class.register_type(name: :array, klass: Array)
      expect(ActiveRecordSchemaScrapper::Attribute.new(type: :array).type).to eq(Array)
    end

    context "with cast_type" do
      it "as a proc" do
        cast_type_proc = -> (cast_type) {
          cast_type == Array
        }
        described_class.register_type(name: :string, klass: Array[String], cast_type: cast_type_proc)
        attribute = ActiveRecordSchemaScrapper::Attribute.new(type: :string, cast_type: Array, default: "{}")
        expect(attribute.type).to eq(Array[String])
      end

      it "as a class" do
        described_class.register_type(name: :string, klass: Array[String], cast_type: Array)
        attribute = ActiveRecordSchemaScrapper::Attribute.new(type: :string, cast_type: Array, default: "{}")
        expect(attribute.type).to eq(Array[String])
      end

      it "does not catch on type alone" do
        described_class.register_type(name: :string, klass: Array[String], cast_type: Array)
        attribute = ActiveRecordSchemaScrapper::Attribute.new(type: :string, cast_type: String, default: 0)
        expect(attribute.type).to eq(String)
      end

      it "matches on the top ranking" do
        described_class.register_type(name: :super_string, klass: Array[String])
        described_class.register_type(name: :super_string, klass: String, cast_type: String)
        attribute = ActiveRecordSchemaScrapper::Attribute.new(type: :super_string, cast_type: String, default: 0)
        expect(attribute.type).to eq(String)
      end
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

    before do
      described_class.reset_registered_types
      described_class.reset_registered_defaults
    end

    after do
      described_class.reset_registered_types
      described_class.reset_registered_defaults
    end

    it "add default type converter" do
      described_class.register_default(name: "T", klass: true)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "T").default).to eq(true)
    end

    it "as a proc" do
      cast_type_proc = -> (cast_type) {
        cast_type == Array
      }
      described_class.register_default(default: "{}", replacement_default: [], cast_type: cast_type_proc, type: :string)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "{}", cast_type: Array, type: :string).default).to eq([])
    end

    it "as a class" do
      described_class.register_default(default: "{}", replacement_default: [], cast_type: Array, type: :string)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "{}", cast_type: Array, type: :string).default).to eq([])
    end

    it "without a type" do
      described_class.register_default(default: "{}", replacement_default: [], cast_type: Array)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "{}", cast_type: Array, type: :string).default).to eq([])
    end

    it "does not catch register when cast_type is different" do
      described_class.register_default(default: "{}", replacement_default: [], cast_type: Array, type: :string)
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "{}", cast_type: String, type: :string).default).to eq("{}")
    end

    it "does not catch register when type is different" do
      described_class.register_default(default: "{}", replacement_default: [], cast_type: Array, type: :string)
      puts "registered_defaults count: #{described_class.registered_defaults.count}"
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: "{}", cast_type: Array, type: :decimal).default).to eq("{}")
    end

    it "will pass nil if no registered value" do
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: nil).default).to eq(nil)
    end

    it "will pass value if no registered value" do
      expect(ActiveRecordSchemaScrapper::Attribute.new(default: :Q).default).to eq(:Q)
    end
  end
end
