require "spec_helper"
require "models/db"
require "models"

describe ActiveRecordSchemaScrapper do
  describe "new" do

    subject { described_class.new(model: User) }

    describe "#attributes" do
      it "passes model in" do
        expect(described_class::Attributes).to receive(:new).and_call_original.with({model: User})
        subject.attributes
      end

      it "returns an Attributes class" do
        expect(subject.attributes.class).to eq(described_class::Attributes)
      end
    end

    describe "#associations" do
      it "passes any attributes through" do
        expect(described_class::Associations).to receive(:new).and_call_original.with({model: User, types: [:belongs_to]})
        subject.associations(types: [:belongs_to])
      end

      it "returns an Associations class" do
        expect(subject.associations.class).to eq(described_class::Associations)
      end
    end

    describe "table_name" do
      it { expect(subject.table_name).to eq('users') }
    end
  end
end
