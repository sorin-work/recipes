class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, -> { order(:position) }, dependent: :delete_all, inverse_of: :recipe
  has_many :steps, -> { order(:position) }, dependent: :delete_all, inverse_of: :recipe
  has_many :taggings, dependent: :delete_all
  has_many :tags, -> { order(:name) }, through: :taggings
  has_one_attached :photo do |attachable|
    attachable.variant :card, resize_to_fill: [ 640, 420 ], preprocessed: false
    attachable.variant :large, resize_to_limit: [ 1200, 900 ], preprocessed: false
  end

  PHOTO_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  PHOTO_MAX_SIZE = 5.megabytes

  normalizes :title, with: ->(title) { title.squish }

  validates :title, presence: true, length: { maximum: 150 }
  validates :servings, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :prep_minutes, :cook_minutes,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2880 }, allow_nil: true
  validates :description, length: { maximum: 2000 }
  validate :photo_is_an_acceptable_image
  validate :ingredient_lines_are_reasonable

  before_save :rebuild_ingredients, if: -> { @ingredients_text }
  before_save :rebuild_steps, if: -> { @steps_text }
  before_save :assign_tags, if: -> { @tag_list }

  scope :favourites, -> { where(favourite: true) }
  scope :tagged, ->(name) { joins(:tags).where(tags: { name: Tag.normalize_name(name) }) }
  scope :search, ->(query) {
    words = query.to_s.split.first(5)
    words.reduce(all) do |scope, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      scope.where(
        "recipes.title ILIKE :pattern OR recipes.description ILIKE :pattern OR EXISTS (" \
        "SELECT 1 FROM ingredients WHERE ingredients.recipe_id = recipes.id AND ingredients.name ILIKE :pattern)",
        pattern: pattern
      )
    end
  }

  def total_minutes
    return if prep_minutes.nil? && cook_minutes.nil?

    prep_minutes.to_i + cook_minutes.to_i
  end

  # The ingredients as one editable line each, the way the form shows them.
  def ingredients_text
    @ingredients_text || ingredients.map(&:to_line).join("\n")
  end

  def ingredients_text=(text)
    @ingredients_text = text.to_s
  end

  def steps_text
    @steps_text || steps.map(&:body).join("\n\n")
  end

  # One step per paragraph. Single line breaks inside a paragraph start a new
  # step too, unless the text uses blank lines between steps.
  def steps_text=(text)
    @steps_text = text.to_s
  end

  def step_bodies
    text = steps_text.gsub("\r\n", "\n").strip
    parts = text.include?("\n\n") ? text.split(/\n\s*\n/) : text.split("\n")
    parts.map(&:squish).compact_blank
  end

  def tag_list
    @tag_list || tags.map(&:name).join(", ")
  end

  def tag_list=(list)
    @tag_list = list.to_s
  end

  private
    def parsed_ingredient_lines
      @parsed_ingredient_lines ||= @ingredients_text.to_s.lines.filter_map { |line| IngredientParser.parse(line) }
    end

    def ingredient_lines_are_reasonable
      return unless @ingredients_text

      lines = parsed_ingredient_lines
      errors.add(:ingredients_text, "has too many lines (100 at most)") if lines.size > 100
      if lines.any? { |line| line.name.length > 200 || line.note.to_s.length > 200 }
        errors.add(:ingredients_text, "has a line that is too long")
      end
    end

    def rebuild_ingredients
      @parsed_ingredient_lines = nil
      ingredients.delete_all
      parsed_ingredient_lines.each.with_index(1) do |line, position|
        ingredients.build(quantity: line.quantity, unit: line.unit, name: line.name, note: line.note, position: position)
      end
      @ingredients_text = nil
    end

    def rebuild_steps
      bodies = step_bodies
      steps.delete_all
      bodies.each.with_index(1) { |body, position| steps.build(body: body, position: position) }
      @steps_text = nil
    end

    def assign_tags
      names = @tag_list.split(",").map { |name| Tag.normalize_name(name) }.compact_blank.uniq.first(20)
      self.tags = names.map { |name| user.tags.find_or_create_by!(name: name) }
      @tag_list = nil
    end

    def photo_is_an_acceptable_image
      return unless photo.attached?

      if PHOTO_TYPES.exclude?(photo.blob.content_type)
        errors.add(:photo, "must be a JPEG, PNG, WebP or GIF image")
      elsif photo.blob.byte_size > PHOTO_MAX_SIZE
        errors.add(:photo, "must be smaller than 5 MB")
      end
    end
end
