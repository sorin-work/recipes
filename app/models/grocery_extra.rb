# Something to buy that is not in any recipe: kitchen roll, coffee, snacks.
class GroceryExtra < ApplicationRecord
  belongs_to :user

  normalizes :name, with: ->(name) { name.squish }

  validates :week_start, presence: true
  validates :name, presence: true, length: { maximum: 100 }
end
