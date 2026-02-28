# Everything to buy for the meals planned in a week.
#
# Each planned meal's ingredients are scaled to the servings planned, matched by
# normalised name (see IngredientName) and added up (see Amount).
class GroceryList
  class Item
    attr_reader :key, :name, :amounts, :recipes

    def initialize(key, name)
      @key = key
      @name = name
      @amounts = []
      @recipes = []
      @as_needed = false
    end

    def add(amount, recipe)
      @recipes |= [ recipe ]
      return @as_needed = true if amount.nil?

      index = @amounts.index { |existing| existing.compatible?(amount) }
      if index
        @amounts[index] += amount
      else
        @amounts << amount
      end
    end

    # "1.5 kg" or "2 cans + 400 g" when the recipes measure it differently.
    def amount_text
      text = @amounts.reject(&:zero?).map(&:to_s)
      text << "as needed" if text.empty?
      text.join(" + ")
    end

    def as_needed?
      @as_needed
    end
  end

  attr_reader :user, :week

  def initialize(user, week)
    @user = user
    @week = week
  end

  def items
    @items ||= build_items
  end

  def to_buy
    items
  end

  def empty?
    items.empty?
  end

  private
    def build_items
      by_key = {}
      entries.each do |entry|
        factor = entry.scale
        entry.recipe.ingredients.each do |ingredient|
          key = IngredientName.key(ingredient.name)
          next if key.empty?

          item = by_key[key] ||= Item.new(key, display_name(ingredient.name))
          amount = ingredient.quantity && Amount.from(ingredient.scaled_quantity(factor), ingredient.unit)
          item.add(amount, entry.recipe.title)
        end
      end
      items = by_key.values.sort_by(&:name)
      items
    end

    def entries
      user.meal_plan_entries.in_week(week).includes(recipe: :ingredients)
    end

    def display_name(name)
      name.sub(/\A(?:#{IngredientName::DESCRIPTORS.to_a.join('|')})\s+/i, "").downcase
    end
end
