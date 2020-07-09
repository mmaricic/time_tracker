class User < ApplicationRecord
  include Clearance::User

  has_many :time_entries, dependent: :destroy

  validates :name, presence: true, length: {maximum: 50}

  def first_name
    name.split(" ").first
  end

  def initials
    words = name.split(" ")
    if words.size > 1
      (words.first[0] + words.second[0]).upcase
    else
      words.first[0, 2].upcase
    end
  end
end
