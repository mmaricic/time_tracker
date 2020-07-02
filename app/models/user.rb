class User < ApplicationRecord
  include Clearance::User
  validates :name, presence: true, length: {maximum: 50}
end
