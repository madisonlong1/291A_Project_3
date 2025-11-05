class User < ApplicationRecord
  has_secure_password #needed this
  validates :username, presence: true, uniqueness: true
end
