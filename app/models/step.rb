class Step < ApplicationRecord
  belongs_to :recipe

  validates :body, presence: true, length: { maximum: 3000 }
end
