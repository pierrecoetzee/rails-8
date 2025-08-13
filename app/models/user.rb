class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :projects, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true
  validates :name, presence: true  # Changed back to :name

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end