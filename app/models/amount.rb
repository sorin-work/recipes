# How much of something is needed, in a form that can be added up.
#
# Mass is kept in grams and volume in millilitres, so 500 g + 1 kg is 1.5 kg and
# 2 tbsp + 2 tbsp is 1/4 cup. Counted units ("2 cans") add up only with the same
# unit, and plain numbers ("3 eggs") with other plain numbers.
class Amount
  attr_reader :dimension, :value, :unit, :systems

  # +quantity+ in +unit+ (a code like "g" or nil for a plain count).
  def self.from(quantity, unit)
    unit = Unit.find(unit) unless unit.nil? || unit.is_a?(Unit)
    quantity = quantity.to_r
    if unit.nil?
      new(:each, quantity)
    elsif unit.count?
      new(:count, quantity, unit)
    else
      new(unit.dimension, unit.to_base(quantity), unit, [ unit.system ])
    end
  end

  def initialize(dimension, value, unit = nil, systems = [])
    @dimension = dimension
    @value = value.to_r
    @unit = unit
    @systems = systems.to_set
  end

  # Amounts that can be added together share a bucket.
  def bucket
    dimension == :count ? [ :count, unit.code ] : [ dimension ]
  end

  def compatible?(other)
    other.is_a?(Amount) && bucket == other.bucket
  end

  def +(other)
    raise ArgumentError, "can't add #{other.bucket} to #{bucket}" unless compatible?(other)

    Amount.new(dimension, value + other.value, unit || other.unit, systems | other.systems)
  end

  # What is left after taking +other+ away, never below zero.
  def -(other)
    raise ArgumentError, "can't subtract #{other.bucket} from #{bucket}" unless compatible?(other)

    Amount.new(dimension, [ value - other.value, 0 ].max, unit, systems)
  end

  def *(factor)
    Amount.new(dimension, value * factor.to_r, unit, systems)
  end

  def zero?
    value <= 0
  end

  # The unit to show this amount in: kg once there is a kilo of something, cups
  # for a quarter cup or more of liquid measured with spoons, and so on.
  def display_unit
    case dimension
    when :mass then mass_unit
    when :volume then volume_unit
    when :count then unit
    end
  end

  def display_quantity
    display_unit ? display_unit.from_base(base_value) : value
  end

  def to_s
    shown = display_unit
    quantity = display_quantity
    [ Quantity.format(quantity, shown), shown&.label_for(quantity) ].compact.join(" ")
  end

  def inspect
    "#<Amount #{self}>"
  end

  private
    # Count amounts are stored in their own unit, mass and volume in g and ml.
    def base_value
      dimension == :count ? unit.to_base(value) : value
    end

    def mass_unit
      value >= 1000 ? Unit["kg"] : Unit["g"]
    end

    def volume_unit
      if systems == Set[:us]
        if value >= Unit["cup"].factor / 4
          Unit["cup"]
        elsif value >= Unit["tbsp"].factor
          Unit["tbsp"]
        else
          Unit["tsp"]
        end
      else
        value >= 1000 ? Unit["l"] : Unit["ml"]
      end
    end
end
