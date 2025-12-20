# Reading and writing the numbers at the start of ingredient lines.
#
#   Quantity.scan("1 1/2 cups flour")  # => [(3/2), "cups flour"]
#   Quantity.format(1.5, Unit["cup"])  # => "1 1/2"
#   Quantity.format(1250, Unit["g"])   # => "1250"
module Quantity
  VULGAR_FRACTIONS = {
    "½" => 1/2r, "⅓" => 1/3r, "⅔" => 2/3r, "¼" => 1/4r, "¾" => 3/4r, "⅕" => 1/5r,
    "⅖" => 2/5r, "⅗" => 3/5r, "⅘" => 4/5r, "⅙" => 1/6r, "⅚" => 5/6r, "⅛" => 1/8r,
    "⅜" => 3/8r, "⅝" => 5/8r, "⅞" => 7/8r
  }.freeze

  VULGAR = "[#{VULGAR_FRACTIONS.keys.join}]".freeze
  # Order matters: try "1 1/2" before "1", and "1½" before "1".
  NUMBER = %r{\d+\s+\d+\s*/\s*\d+|\d*\s*#{VULGAR}|\d+\s*/\s*\d+|\d+(?:[.,]\d+)?}
  LEADING = /\A(#{NUMBER})(?![\d\/])\s*/

  FRACTIONS = [ 0, 1/8r, 1/4r, 1/3r, 3/8r, 1/2r, 5/8r, 2/3r, 3/4r, 7/8r, 1 ].freeze
  FRACTION_TOLERANCE = 0.03

  module_function

  # Pulls a quantity off the front of +text+. Returns [quantity, rest], with a nil
  # quantity when the text does not start with a number.
  def scan(text)
    text = text.to_s.strip
    match = LEADING.match(text)
    return [ nil, text ] unless match

    value = parse(match[1])
    [ value, match.post_match ]
  end

  # Parses a single number: "2", "0.5", "1,5", "3/4", "1 1/2", "1½" or "½".
  def parse(string)
    string = string.to_s.strip
    if (vulgar = string[/#{VULGAR}/o])
      whole = string.delete(vulgar).strip
      return (whole.empty? ? 0 : whole.to_i) + VULGAR_FRACTIONS[vulgar]
    end
    if (mixed = string.match(%r{\A(\d+)\s+(\d+)\s*/\s*(\d+)\z}))
      return nil if mixed[3].to_i.zero?

      return mixed[1].to_i + Rational(mixed[2].to_i, mixed[3].to_i)
    end

    if (fraction = string.match(%r{\A(\d+)\s*/\s*(\d+)\z}))
      return nil if fraction[2].to_i.zero?

      Rational(fraction[1].to_i, fraction[2].to_i)
    elsif string.match?(/\A\d+(?:[.,]\d+)?\z/)
      string.tr(",", ".").to_r
    end
  end

  # Cups, spoons and counted things read best as fractions ("1 1/2 cups", "1/2
  # onion"); grams and millilitres as plain numbers ("250 g").
  def style_for(unit)
    unit&.metric? ? :decimal : :fraction
  end

  def format(value, unit = nil)
    return "" if value.nil?

    style_for(unit) == :decimal ? decimal(value) : fraction(value)
  end

  # 1.5 => "1 1/2", 0.333 => "1/3", 2 => "2". Falls back to a decimal when the
  # value is not close to a common kitchen fraction.
  def fraction(value)
    value = value.to_r
    whole = value.floor
    rest = value - whole
    nearest = FRACTIONS.min_by { |f| (rest - f).abs }
    return decimal(value) if (rest - nearest).abs > FRACTION_TOLERANCE

    # 0.999 after scaling a third back up is a whole number, not "1/1".
    if nearest == 1
      whole += 1
      nearest = 0
    end
    return whole.to_s if nearest.zero?

    part = "#{nearest.numerator}/#{nearest.denominator}"
    whole.zero? ? part : "#{whole} #{part}"
  end

  # Two decimals under 10, one under 100, whole numbers above that.
  def decimal(value)
    value = value.to_f
    digits = if value.abs < 10 then 2
    elsif value.abs < 100 then 1
    else 0
    end
    rounded = value.round(digits)
    rounded == rounded.to_i ? rounded.to_i.to_s : rounded.to_s
  end
end
