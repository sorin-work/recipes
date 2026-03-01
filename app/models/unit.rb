# A unit of measure an ingredient can be written in.
#
# Mass and volume units convert through a base unit (grams and millilitres), so
# "500 g" and "1 kg" or "3 tsp" and "1 tbsp" can be added up. Everything else
# ("clove", "can", "pinch") is a counted unit that only adds up with itself.
class Unit
  attr_reader :code, :dimension, :factor, :system, :singular, :plural, :aliases

  def initialize(code:, dimension:, factor: 1, system: nil, plural: nil, aliases: [])
    @code = code
    @dimension = dimension
    @factor = factor.to_r
    @system = system
    @singular = code
    @plural = plural || code
    @aliases = [ code, plural, *aliases ].compact.uniq
  end

  def mass? = dimension == :mass
  def volume? = dimension == :volume
  def count? = dimension == :count
  def metric? = system == :metric

  # Whether quantities in this unit and +other+ can be added together.
  def convertible_to?(other)
    return false unless other
    return code == other.code if count? || other.count?

    dimension == other.dimension
  end

  def to_base(quantity)
    quantity.to_r * factor
  end

  def from_base(quantity)
    quantity.to_r / factor
  end

  # "cup" or "cups", depending on the quantity. Symbols like "g" never change.
  def label_for(quantity)
    quantity.nil? || quantity.to_r <= 1 ? singular : plural
  end

  def to_s = code

  def ==(other)
    other.is_a?(Unit) && other.code == code
  end
  alias eql? ==

  def hash = code.hash

  # Spoons and cups are defined from each other so three teaspoons are exactly one
  # tablespoon, rather than a rounding error short of it.
  TABLESPOON = 14.78676478125r
  TEASPOON = TABLESPOON / 3
  CUP = TABLESPOON * 16

  ALL = [
    new(code: "g", dimension: :mass, system: :metric, aliases: %w[gr gm gram grams gramme grammes]),
    new(code: "kg", dimension: :mass, factor: 1000, system: :metric, aliases: %w[kgs kilo kilos kilogram kilograms]),
    new(code: "oz", dimension: :mass, factor: 28.349523125r, system: :imperial, aliases: %w[ounce ounces]),
    new(code: "lb", dimension: :mass, factor: 453.59237r, system: :imperial, aliases: %w[lbs pound pounds]),
    new(code: "ml", dimension: :volume, system: :metric,
      aliases: %w[mls millilitre millilitres milliliter milliliters]),
    new(code: "l", dimension: :volume, factor: 1000, system: :metric, aliases: %w[litre litres liter liters ltr]),
    new(code: "tsp", dimension: :volume, factor: TEASPOON, system: :us, aliases: %w[tsps teaspoon teaspoons]),
    new(code: "tbsp", dimension: :volume, factor: TABLESPOON, system: :us,
      aliases: %w[tbsps tbs tbl tbls tablespoon tablespoons]),
    new(code: "cup", plural: "cups", dimension: :volume, factor: CUP, system: :us),
    new(code: "fl oz", dimension: :volume, factor: TABLESPOON * 2, system: :us,
      aliases: [ "fl. oz", "fl.oz", "floz", "fluid ounce", "fluid ounces" ]),
    new(code: "clove", plural: "cloves", dimension: :count),
    new(code: "can", plural: "cans", dimension: :count, aliases: %w[tin tins]),
    new(code: "jar", plural: "jars", dimension: :count),
    new(code: "pack", plural: "packs", dimension: :count, aliases: %w[packet packets pkg]),
    new(code: "pinch", plural: "pinches", dimension: :count),
    new(code: "dash", plural: "dashes", dimension: :count),
    new(code: "bunch", plural: "bunches", dimension: :count),
    new(code: "handful", plural: "handfuls", dimension: :count),
    new(code: "sprig", plural: "sprigs", dimension: :count),
    new(code: "slice", plural: "slices", dimension: :count),
    new(code: "stick", plural: "sticks", dimension: :count),
    new(code: "sheet", plural: "sheets", dimension: :count),
    new(code: "head", plural: "heads", dimension: :count),
    new(code: "knob", plural: "knobs", dimension: :count)
  ].freeze

  # Single letters where case matters: 1 t is a teaspoon, 1 T a tablespoon.
  CASE_SENSITIVE = { "t" => "tsp", "T" => "tbsp", "c" => "cup", "C" => "cup" }.freeze

  BY_ALIAS = ALL.each_with_object({}) do |unit, index|
    unit.aliases.each { |name| index[name.downcase] = unit }
  end.freeze

  BY_CODE = ALL.index_by(&:code).freeze

  class << self
    # Finds a unit by any of its spellings ("tablespoons", "Tbsp.", "kg").
    def find(name)
      return if name.blank?

      name = name.to_s.strip
      return BY_CODE[CASE_SENSITIVE[name]] if CASE_SENSITIVE.key?(name)

      BY_ALIAS[name.downcase.delete_suffix(".")]
    end

    def [](code)
      BY_CODE.fetch(code)
    end

    def codes
      BY_CODE.keys
    end

    # Longest aliases first so "fl oz" wins over "oz".
    def aliases
      @aliases ||= BY_ALIAS.keys.sort_by { |name| -name.length }
    end
  end
end
