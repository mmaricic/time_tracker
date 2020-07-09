require 'contracts'

class User < ApplicationRecord
  include Clearance::User
  include Contracts::Core
  include Contracts::Builtin

  has_many :time_entries, dependent: :destroy

  validates :name, presence: true, length: {maximum: 50}

  Contract None => String
  def first_name
    name.split(" ").first
  end

  Contract None => CustomTypes::Initials
  def initials
    words = name.split(" ")
    if words.size > 1
      (words.first[0] + words.second[0]).upcase
    else
      words.first[0, 2].upcase
    end
  end
end
