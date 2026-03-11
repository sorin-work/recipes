# Everything to buy for the meals planned in a week.
#
# Each planned meal's ingredients are scaled to the servings planned, matched by
# normalised name (see IngredientName) and added up (see Amount).
# Whatever the pantry already has is taken off; items the pantry fully covers
# move to a separate "already have" list.
class GroceryList
  class Item
    attr_reader :key, :name, :amounts, :recipes
    attr_reader :aisle
    attr_accessor :checked
    attr_accessor :pantry_item

    def initialize(key, name)
      @key = key
      @name = name
      @amounts = []
      @recipes = []
      @as_needed = false
      @aisle = Aisle.for(name)
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

    def subtract(have)
      @amounts = @amounts.map { |amount| amount.unit == have.unit ? amount - have : amount }
    end

    def in_pantry?
      return false unless pantry_item
      return true if pantry_item.staple? || @amounts.empty?

      @amounts.all?(&:zero?)
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
    items.reject(&:in_pantry?)
  end

  def in_pantry
    items.select(&:in_pantry?)
  end

  # [ ["produce", [items...]], ["dairy & eggs", [...]], ... ] in shop order.
  def sections
    to_buy.group_by(&:aisle).sort_by { |aisle, _| Aisle::ORDER.index(aisle) }
  end

  def empty?
    items.empty?
  end

  def to_text
    lines = [ "Grocery list for #{week.label}", "" ]
    sections.each do |aisle, section_items|
      lines << aisle.capitalize
      section_items.each { |item| lines << "#{item.checked ? '[x]' : '[ ]'} #{item.name} - #{item.amount_text}" }
      lines << ""
    end
    extras = user.grocery_extras.where(week_start: week.start).order(:created_at)
    if extras.any?
      lines << "Extras"
      extras.each { |extra| lines << "#{extra.checked ? '[x]' : '[ ]'} #{extra.name}" }
      lines << ""
    end
    lines.join("\n").strip + "\n"
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
      mark_checked(items)
      apply_pantry(items)
      items
    end

    def entries
      user.meal_plan_entries.in_week(week).includes(recipe: :ingredients)
    end

    def display_name(name)
      name.sub(/\A(?:#{IngredientName::DESCRIPTORS.to_a.join('|')})\s+/i, "").downcase
    end

    def mark_checked(items)
      checked = user.grocery_checks.where(week_start: week.start).pluck(:item_key).to_set
      items.each { |item| item.checked = checked.include?(item.key) }
    end

    def apply_pantry(items)
      pantry = user.pantry_items.index_by(&:key)
      items.each do |item|
        next unless (pantry_item = pantry[item.key])

        item.pantry_item = pantry_item
        item.subtract(Amount.from(pantry_item.quantity, pantry_item.unit)) unless pantry_item.staple?
      end
    end
end
