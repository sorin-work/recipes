# Splits a written ingredient line into its parts.
#
#   IngredientParser.parse("2 tbsp olive oil, plus extra to serve")
#   # => #<Result quantity=(2/1) unit="tbsp" name="olive oil" note="plus extra to serve">
#
# Lines without a recognisable amount ("salt and pepper") keep a nil quantity.
class IngredientParser
  Result = Data.define(:quantity, :unit, :name, :note) do
    def heading? = false
  end

  # "For the sauce:" style lines that group the ingredients below them.
  Heading = Data.define(:name) do
    def heading? = true
    def quantity = nil
    def unit = nil
    def note = nil
  end

  BULLET = /\A(?:[-*•·–]|\d+[.)](?=\s))\s*/
  # "1 (400 g) can tomatoes": the bracket describes the can, it isn't the amount.
  PACKAGE_SIZE = /\A\(([^)]*)\)\s*/
  # "a few" or "a little" are not one of anything.
  ARTICLE = /\A(?:a|an|one)\s+(?!(?:few|little|bit|couple|good|generous|splash|drizzle)\b)/i
  MULTIPLIER = /\A[x×]\s*(?=\d)/i

  def self.parse(line)
    new(line).parse
  end

  def initialize(line)
    @line = line.to_s
  end

  def parse
    text = @line.squish.sub(BULLET, "")
    return if text.empty?
    return Heading.new(name: text.delete_suffix(":").strip) if heading?(text)

    quantity, rest = Quantity.scan(text)
    quantity, rest = article_quantity(rest) if quantity.nil?
    notes = []
    if quantity && (size = rest.match(PACKAGE_SIZE))
      notes << size[1].strip
      rest = size.post_match
    end
    # "2 x 400g tins" - two tins; the size goes in the note.
    if quantity && (times = rest.match(MULTIPLIER))
      size, rest = split_package(times.post_match)
      notes << size if size
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

    # "a pinch of salt", "an onion"
    def article_quantity(text)
      match = text.match(ARTICLE)
      return [ nil, text ] unless match

      [ 1r, match.post_match ]
    end

    def split_package(text)
      size, rest = Quantity.scan(text)
      return [ nil, text ] unless size

      unit, rest = take_unit(rest)
      return [ nil, text ] unless unit

      [ "#{Quantity.format(size, unit)} #{unit.code}", rest ]
    end

    def heading?(text)
      text.end_with?(":") && text.length <= 60 && !text.match?(/\A[\d#{Quantity::VULGAR_FRACTIONS.keys.join}]/)
    end
end
