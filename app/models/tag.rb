class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :delete_all
  has_many :recipes, through: :taggings

  normalizes :name, with: ->(name) { Tag.normalize_name(name) }

  validates :name, presence: true, length: { maximum: 40 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  # "Quick ", "quick" and "QUICK" are one tag.
  def self.normalize_name(name)
    name.to_s.squish.downcase
  end
end
