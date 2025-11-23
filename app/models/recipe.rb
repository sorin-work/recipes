class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, -> { order(:position) }, dependent: :delete_all, inverse_of: :recipe

  normalizes :title, with: ->(title) { title.squish }

  validates :title, presence: true, length: { maximum: 150 }
  validates :servings, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :prep_minutes, :cook_minutes,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2880 }, allow_nil: true
  validates :description, length: { maximum: 2000 }



  def total_minutes
    return if prep_minutes.nil? && cook_minutes.nil?

    prep_minutes.to_i + cook_minutes.to_i
  end

  private
end
