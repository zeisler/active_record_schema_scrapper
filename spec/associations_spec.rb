require "spec_helper"
require "models/db"
require "models"
require "active_record_schema_scrapper/association"
require "active_record_schema_scrapper/associations"

describe ActiveRecordSchemaScrapper::Associations do
  describe 'User' do
    describe 'by type' do

      def subject(type)
        described_class.new(model: User, types: type).to_a.map(&:name)
      end

      context '[:has_many]' do
        it do
          expect(subject([:has_many]))
            .to eq([:microposts, :relationships, :followed_users, :reverse_relationships, :followers])
        end

        context 'when an association cannot not be found' do
          it 'is added to the errors array' do
            subject = described_class.new(model: User, types: [:has_many])
            subject.to_a
            error = subject.errors.first
            expect(error.message).to eq('Missing model IDontExist for association User.belongs_to :i_dont_exists')
            expect(error.class_name).to eq("User")
            expect(error.original_error.to_s).to eq("uninitialized constant User::IDontExist")
            expect(error.level).to eq(:error)
            expect(error.type).to eq(:association)
          end
        end
      end

      it do
        expect(described_class.new(model: User).map(&:to_h))
          .to eq([
                   { name: :account, class_name: :Account, type: :has_one, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil },
                   { name: :microposts, class_name: :Micropost, type: :has_many, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil },
                   { name: :relationships, class_name: :Relationship, type: :has_many, through: nil, source: nil, foreign_key: :follower_id, join_table: nil, dependent: :destroy },
                   { name: :followed_users, class_name: :User, type: :has_many, through: :relationships, source: :followed, foreign_key: :followed_id, join_table: nil, dependent: nil },
                   { name: :reverse_relationships, class_name: :Relationship, type: :has_many, through: nil, source: nil, foreign_key: :followed_id, join_table: nil, dependent: :destroy },
                   { name: :followers, :class_name => :User, :type => :has_many, :through => :reverse_relationships, :source => :follower, :foreign_key => :follower_id, :join_table => nil, :dependent => nil }
                 ])
      end

      context '[:belongs_to]' do
        it do
          expect(subject([:belongs_to]))
            .to eq([])
        end

        context 'when an association cannot not be found' do
          it 'is added to the errors array' do
            subject = described_class.new(model: User, types: [:belongs_to])
            expect(subject.to_a).to eq([])
            error = subject.errors.first
            expect(error.message).to eq('Missing model IDontExist for association User.belongs_to :i_dont_exist')
            expect(error.class_name).to eq("User")
            expect(error.original_error.to_s).to eq("uninitialized constant User::IDontExist")
            expect(error.level).to eq(:error)
            expect(error.type).to eq(:association)
          end
        end

        context 'when a table is an abstract class' do
          it 'is added to the errors array' do
            subject = described_class.new(model: OpenStruct.new(abstract_class?: true, name: "AbstractClass"))
            expect(subject.to_a).to eq([])
            error = subject.errors.first
            expect(error.message).to eq("AbstractClass is an abstract class and has no associated table.")
            expect(error.class_name).to eq("AbstractClass")
            expect(error.level).to eq(:warn)
            expect(error.type).to eq(:no_table)
          end
        end
      end

      it '[:has_one]' do
        expect(subject([:has_one]))
          .to eq([:account])
      end

      it '[:has_and_belongs_to_many]' do
        expect(subject([:has_and_belongs_to_many]))
          .to eq([])
      end
    end

    subject { described_class.new(model: User) }

    it 'microposts' do
      expect(subject.detect { |a| a.name == :microposts }.to_h)
        .to eq({ name: :microposts, class_name: :Micropost, type: :has_many, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil })
    end

    it 'relationships' do
      expect(subject.detect { |a| a.name == :relationships }.to_h)
        .to eq({ name: :relationships, class_name: :Relationship, type: :has_many, through: nil, source: nil, foreign_key: :follower_id, join_table: nil, dependent: :destroy })
    end

    it 'followed_users' do
      expect(subject.detect { |a| a.name == :followed_users }.to_h)
        .to eq({ name: :followed_users, class_name: :User, type: :has_many, through: :relationships, source: :followed, foreign_key: :followed_id, join_table: nil, dependent: nil })
    end

    it 'reverse_relationships' do
      expect(subject.detect { |a| a.name == :reverse_relationships }.to_h)
        .to eq({ name: :reverse_relationships, class_name: :Relationship, type: :has_many, through: nil, source: nil, foreign_key: :followed_id, join_table: nil, dependent: :destroy })
    end

    it 'followers' do
      expect(subject.detect { |a| a.name == :followers }.to_h)
        .to eq({ name: :followers, class_name: :User, type: :has_many, through: :reverse_relationships, source: :follower, foreign_key: :follower_id, join_table: nil, dependent: nil })
    end

    it 'account' do
      expect(subject.detect { |a| a.name == :account }.to_h)
        .to eq({ name: :account, class_name: :Account, type: :has_one, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil })
    end
  end
end