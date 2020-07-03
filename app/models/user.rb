class User < ApplicationRecord
  include Clearance::User

  has_many :time_entries, dependent: :destroy

  validates :name, presence: true, length: {maximum: 50}
end
