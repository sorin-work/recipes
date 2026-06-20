# Turns a recipe pasted from a web page, an email or a note into recipe
# attributes. Nothing is saved: the result fills in the new recipe form so it
# can be checked before saving.
#
# The text is read top to bottom. The first line is the title, lines under an
# "Ingredients" heading are ingredients and lines under "Method", "Directions",
# "Instructions" or "Steps" are steps. Lines like "Serves 4" or "Prep time: 15
# mins" anywhere are picked up as details.
class RecipeImport
  include ActiveModel::Model
  include ActiveModel::Attributes

  MAX_LENGTH = 50_000

  INGREDIENTS_HEADING = /\A(?:ingredients?|you(?:'ll| will) need|shopping list)\s*:?\z/i
  STEPS_HEADING = /\A(?:method|directions?|instructions?|steps?|preparation|how to make(?: it)?)\s*:?\z/i
  SERVINGS = /\A(?:serves|servings|yield|yields|makes|portions)\s*:?\s*(\d+)/i
  # "Prep: 10 mins" or "Prep time 10 mins", but not a step like "Bake for 30 minutes".
  PREP_TIME = /\Aprep(?:aration)?(?:\s+time\s*:?|\s*:)\s*(.+)\z/i
  COOK_TIME = /\A(?:cook(?:ing)?|bake|baking)(?:\s+time\s*:?|\s*:)\s*(.+)\z/i
  TOTAL_TIME = /\Atotal(?:\s+time\s*:?|\s*:)\s*(.+)\z/i
  URL = %r{\A(?:source\s*:\s*)?(https?://\S+)\z}i
  TAGS = /\A(?:tags|keywords|categories)\s*:\s*(.+)\z/i
  STEP_NUMBER = /\A(?:step\s*\d+\s*[:.)-]?|\d+\s*[.)-]|[-*•])\s*/i
  # Bits of recipe web pages that come along when copying the whole page.
  JUNK = /\A(?:advertisement|jump to recipe|print recipe|pin recipe|save recipe|rate this recipe|share)\z/i

  attribute :text, :string

  validates :text, presence: { message: "is empty - paste a recipe first" }
  validates :text, length: { maximum: MAX_LENGTH, message: "is too long to be one recipe" }
  validate :looks_like_a_recipe

  # Attributes for Recipe.new.
  def recipe_attributes
    parsed.slice(:title, :description, :servings, :prep_minutes, :cook_minutes, :source_url, :tag_list)
      .merge(ingredients_text: parsed[:ingredients].join("\n"), steps_text: parsed[:steps].join("\n\n"))
      .compact_blank
  end

  def parsed
    @parsed ||= parse
  end

  private
    def lines
      text.to_s.gsub(/\r\n?/, "\n").split("\n").map { |line| line.gsub(/[[:space:]]+/, " ").strip }
    end

    def parse
      result = { title: nil, description: [], ingredients: [], steps: [] }
      section = :intro

      lines.each do |line|
        next if line.empty?
        next if line.match?(JUNK)

        if line.match?(INGREDIENTS_HEADING)
          section = :ingredients
        elsif line.match?(STEPS_HEADING)
          section = :steps
        elsif detail?(line, result)
          next
        elsif result[:title].nil?
          result[:title] = line.delete_suffix(":").truncate(150)
        else
          add_line(result, section, line)
        end
      end

      guess_sections(result) if result[:ingredients].empty? && result[:steps].empty?
      result[:description] = result[:description].join(" ").truncate(2000).presence
      result
    end

    def add_line(result, section, line)
      case section
      when :intro then result[:description] << line
      when :ingredients then result[:ingredients] << line.sub(/\A[-*•·]\s*/, "")
      when :steps then add_step(result, line)
      end
    end

    def add_step(result, line)
      body = line.sub(STEP_NUMBER, "").strip
      return if body.empty? || body.match?(/\Astep\s*\d+\z/i)

      result[:steps] << body
    end

    def detail?(line, result)
      if (match = line.match(SERVINGS))
        result[:servings] ||= match[1].to_i.clamp(1, 100)
      elsif (match = line.match(PREP_TIME))
        result[:prep_minutes] ||= DurationParser.minutes(match[1])
      elsif (match = line.match(COOK_TIME))
        result[:cook_minutes] ||= DurationParser.minutes(match[1])
      elsif line.match?(TOTAL_TIME)
        true
      elsif (match = line.match(URL))
        result[:source_url] ||= match[1]
      elsif (match = line.match(TAGS))
        result[:tag_list] ||= match[1]
      else
        false
      end
    end

    # Without headings: the lines that start with an amount right after the
    # title are the ingredients and everything after them is the method.
    def guess_sections(result)
      intro = result[:description]
      first = intro.index { |line| ingredient_like?(line) }
      return unless first

      rest = intro[first..]
      last = rest.index { |line| !ingredient_like?(line) } || rest.size
      result[:description] = intro[0...first]
      result[:ingredients] = rest[0...last].map { |line| line.sub(/\A[-*•·]\s*/, "") }
      rest[last..].each { |line| add_step(result, line) }
    end

    def ingredient_like?(line)
      line = line.sub(/\A[-*•·]\s*/, "")
      Quantity.scan(line).first.present? && line.length < 120
    end

    def looks_like_a_recipe
      return if text.blank? || errors.any?

      if parsed[:title].blank?
        errors.add(:text, "doesn't have a title on its first line")
      elsif parsed[:ingredients].empty? && parsed[:steps].empty?
        errors.add(:text, "doesn't have any ingredients or steps we could find")
      end
    end
end
