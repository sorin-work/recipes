# Which part of the shop an ingredient is usually in, so the grocery list can be
# walked through in one pass. Matching is by keyword on the normalised name.
module Aisle
  SECTIONS = {
    "produce" => %w[
      apple avocado banana basil beansprout beetroot berry broccoli cabbage carrot
      cauliflower celery chard chilli chili cilantro coriander courgette cucumber dill
      eggplant aubergine fennel garlic ginger grape herb kale leek lemon lettuce lime
      mango mint mushroom onion orange parsley parsnip pea pear pepper potato pumpkin
      radish rocket rosemary sage salad scallion shallot spinach squash
      sweetcorn thyme tomato zucchini
    ],
    "meat & fish" => %w[
      bacon beef chicken chorizo cod fish ham lamb mince pork prawn salmon sausage
      shrimp steak tuna turkey
    ],
    "dairy & eggs" => %w[butter cheddar cheese cream egg feta milk mozzarella parmesan ricotta yogurt yoghurt],
    "bakery" => %w[bagel bread bun ciabatta pitta pita roll tortilla wrap baguette],
    "pantry" => %w[
      baking bean breadcrumb broth chickpea coconut couscous flour honey jam lentil
      mayonnaise molasses noodle nut oat oil olive pasta paste peanut quinoa rice sauce
      seed spaghetti stock sugar syrup tahini vinegar
    ],
    "spices" => %w[
      bay cardamom cinnamon cumin curry flake nutmeg oregano paprika peppercorn salt
      spice turmeric vanilla
    ],
    "frozen" => %w[frozen ice]
  }.freeze

  ORDER = [ *SECTIONS.keys, "other" ].freeze

  # Phrases that would otherwise land in the wrong section ("black pepper" is a
  # spice, "pepper" on its own is a vegetable).
  OVERRIDES = {
    "black pepper" => "spices", "white pepper" => "spices", "pepper" => "produce",
    "salt and pepper" => "spices", "coconut milk" => "pantry", "peanut butter" => "pantry",
    "tomato paste" => "pantry", "tomato puree" => "pantry", "tinned tomato" => "pantry",
    "stock cube" => "pantry", "frozen pea" => "frozen", "garlic powder" => "spices",
    "onion powder" => "spices", "ground ginger" => "spices", "soy sauce" => "pantry",
    "green bean" => "produce", "runner bean" => "produce"
  }.freeze

  module_function

  def for(name)
    key = IngredientName.key(name)
    return OVERRIDES[key] if OVERRIDES.key?(key)

    OVERRIDES.each { |phrase, section| return section if key.end_with?(" #{phrase}") }
    return "spices" if key.start_with?("dried ", "ground ")

    words = key.split
    # The last word says most about what something is: "chicken stock" is stock.
    words.reverse_each do |word|
      SECTIONS.each { |section, keywords| return section if keywords.include?(word) }
    end
    "other"
  end
end
