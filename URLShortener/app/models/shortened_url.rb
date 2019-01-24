# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  long_url   :string           not null
#  short_url  :string
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'securerandom'

class ShortenedUrl < ApplicationRecord
    validates :long_url, presence: true, uniqueness: true
    validates :short_url, uniqueness: true
    validates :user_id, presence: true

    belongs_to :submitter,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :User

    has_many :visits,
        primary_key: :id,
        foreign_key: :shortened_url_id,
        class_name: :Visit
        
    has_many :visitors,
        -> { distinct },
        through: :visits,
        source: :user
    
    def self.random_code
         SecureRandom.urlsafe_base64
    end

    def self.create!(user, long_url)
        short_url = ShortenedUrl.random_code
        while ShortenedUrl.exists?(short_url: short_url)
            short_url = ShortenedUrl.random_code
        end

        ShortenedUrl.new(long_url: long_url, short_url: short_url, user_id: user.id)
    end

    def num_clicks
        self.visits.count
    end

    def num_uniques
        self.visitors.count
    end

    def num_recent_uniques
        date = DateTime.parse("2014-12-14 09:38:00.000000")
        self.visits.distinct.where(["created_at > ?", 10.minutes.ago]).count
    end
end
