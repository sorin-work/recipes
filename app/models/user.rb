class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :meal_plan_entries, dependent: :delete_all
  has_many :grocery_checks, dependent: :delete_all
  has_many :grocery_extras, dependent: :delete_all
  has_many :pantry_items, dependent: :delete_all

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :email_address, presence: true, uniqueness: true, length: { maximum: 254 },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8, maximum: 72 }, allow_nil: true

  def first_name
    name.to_s.split.first
  end
end
