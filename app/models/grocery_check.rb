# A ticked-off line on a week's grocery list, keyed by the normalised name so
# it stays ticked when the plan changes.
class GroceryCheck < ApplicationRecord
  belongs_to :user

  validates :week_start, :item_key, presence: true
  validates :item_key, uniqueness: { scope: [ :user_id, :week_start ] }, length: { maximum: 200 }
end
