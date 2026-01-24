# Splits a written ingredient line into its parts.
#
#   IngredientParser.parse("2 tbsp olive oil, plus extra to serve")
#   # => #<Result quantity=(2/1) unit="tbsp" name="olive oil" note="plus extra to serve">
#
# Lines without a recognisable amount ("salt and pepper") keep a nil quantity.
class IngredientParser
  Result = Data.define(:quantity, :unit, :name, :note) do
  end

  BULLET = /\A(?:[-*•·–]|\d+[.)](?=\s))\s*/
  # "1 (400 g) can tomatoes": the bracket describes the can, it isn't the amount.
  PACKAGE_SIZE = /\A\(([^)]*)\)\s*/

  def self.parse(line)
    new(line).parse
  end

  def initialize(line)
    @line = line.to_s
  end

  def parse
    text = @line.squish.sub(BULLET, "")
    return if text.empty?

    quantity, rest = Quantity.scan(text)
    notes = []
    if quantity && (size = rest.match(PACKAGE_SIZE))
      notes << size[1].strip
      rest = size.post_match
    end

    unit, rest = take_unit(rest) if quantity
    rest = rest.sub(/\Aof\s+/i, "")

    name, note = split_note(rest)
    notes << note if note.present?

    Result.new(quantity: quantity, unit: unit&.code, name: name, note: notes.join(", ").presence)
  end

  private
    def take_unit(text)
      Unit.aliases.each do |name|
        next unless text.downcase.start_with?(name.downcase)

        rest = text[name.length..]
        next unless rest.empty? || rest.match?(/\A[.\s,]/)

        return [ Unit.find(name), rest.sub(/\A\.?/, "").strip ]
      end
      Unit::CASE_SENSITIVE.each_key do |letter|
        return [ Unit.find(letter), text[1..].strip ] if text.match?(/\A#{letter}(?:\.|\s)/)
      end
      [ nil, text ]
    end

    # Comma separates the ingredient from how it is prepared; a trailing bracket
    # ("butter (softened)") is a note too.
    def split_note(text)
      name, note = text.split(",", 2).map(&:strip)
      if (bracket = name.to_s.match(/\A(.+?)\s*\(([^)]*)\)\z/))
        name = bracket[1]
        note = [ bracket[2], note ].compact_blank.join(", ")
      end
      [ name.to_s, note.presence ]
    end
end
