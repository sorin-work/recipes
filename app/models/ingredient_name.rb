# Turns ingredient names into a key for matching the same thing written in
# different ways: "Onions", "large onion" and "onion (red)" are all "onion",
# so they end up on one line of the grocery list and match a pantry "onion".
module IngredientName
  # Words that describe size, state or preparation rather than what to buy.
  DESCRIPTORS = %w[
    large small medium big extra fresh freshly ripe organic finely roughly thinly
    chopped diced minced sliced grated crushed peeled softened melted beaten
    cold warm room temperature
  ].to_set.freeze

  module_function

  def key(name)
    words = name.to_s.downcase
      .gsub(/\([^)]*\)/, " ")
      .gsub(/[^\p{L}\p{N}\s-]/, " ")
      .split
      .reject { |word| DESCRIPTORS.include?(word) }
    return "" if words.empty?

    # Only words ending in s can be plurals; the inflector would otherwise turn
    # "feta" into "fetum" (as in data and datum).
    words[-1] = words[-1].singularize if words[-1].end_with?("s")
    words.join(" ")
  end
end
