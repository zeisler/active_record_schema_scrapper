require "spec_helper"
require "models/db"
require "models"
require "active_record_schema_scrapper/association"
require "active_record_schema_scrapper/associations"

describe ActiveRecordSchemaScrapper::Associations do

  describe 'User' do

    subject{ described_class.new(model: User) }

    it 'microposts' do
      expect(subject.detect { |a| a.name == :microposts }.to_h)
        .to eq({ name: :microposts, class_name: :Micropost, type: :has_many, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil })
    end

    it 'relationships' do
      expect(subject.detect { |a| a.name == :relationships }.to_h)
        .to eq({ name: :relationships, class_name: :Relationship, type: :has_many, through: nil, source: nil, foreign_key: :follower_id, join_table: nil , dependent: :destroy})
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
      expect(subject.detect{|a| a.name == :account}.to_h)
        .to eq({ name: :account, class_name: :Account, type: :has_one, through: nil, source: nil, foreign_key: :user_id, join_table: nil, dependent: nil })
    end

  end

end