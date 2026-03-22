# Sample account for trying the app: demo@example.com / demo-password with a
# recipe box, this week and last week planned, a pantry and a few ticked-off
# grocery items.
# Run with SEED_DEMO=true bin/rails db:seed.
#
# Safe to run more than once: an existing demo account is left alone.
class DemoData
  EMAIL = "demo@example.com"
  PASSWORD = "demo-password"

  RECIPES = [
    {
      title: "Weeknight Spaghetti Bolognese",
      description: "A quick ragù that tastes like it simmered all afternoon. Makes great leftovers.",
      servings: 4, prep_minutes: 15, cook_minutes: 40, favourite: true, tags: "pasta, family, freezer friendly",
      ingredients: <<~TEXT,
        1 tbsp olive oil
        1 onion, finely chopped
        2 carrots, finely chopped
        2 sticks celery, finely chopped
        3 cloves garlic, crushed
        500 g beef mince
        2 tbsp tomato paste
        1 can chopped tomatoes (400 g)
        150 ml red wine
        1 tsp dried oregano
        400 g spaghetti
        30 g parmesan, grated
      TEXT
      steps: <<~TEXT
        Heat the oil in a large pan and soften the onion, carrot and celery for 8 minutes.
        Add the garlic and mince and cook, breaking it up, until browned.
        Stir in the tomato paste, then the tomatoes, wine and oregano. Simmer for 30 minutes.
        Cook the spaghetti in salted water, drain and toss with the sauce. Serve with parmesan.
      TEXT
    },
    {
      title: "Chickpea and Spinach Curry",
      description: "Pantry-friendly curry that is on the table in half an hour.",
      servings: 4, prep_minutes: 10, cook_minutes: 20, favourite: true, tags: "vegetarian, quick, curry",
      ingredients: <<~TEXT,
        2 tbsp vegetable oil
        1 onion, sliced
        3 cloves garlic, minced
        1 tbsp grated ginger
        2 tbsp curry powder
        1 tsp ground cumin
        2 cans chickpeas, drained
        1 can coconut milk (400 ml)
        200 g spinach
        1 lime, juiced
        300 g basmati rice
      TEXT
      steps: <<~TEXT
        Fry the onion in the oil until golden, about 8 minutes.
        Add the garlic, ginger and spices and cook for a minute.
        Add the chickpeas and coconut milk and simmer for 10 minutes.
        Stir in the spinach until wilted, then add the lime juice.
        Serve with the rice.
      TEXT
    },
    {
      title: "Overnight Oats",
      description: "Make a few jars on Sunday night for the week's breakfasts.",
      servings: 2, prep_minutes: 5, cook_minutes: nil, favourite: false, tags: "breakfast, make ahead",
      ingredients: <<~TEXT,
        100 g rolled oats
        200 ml milk
        100 g greek yogurt
        1 tbsp chia seeds
        1 tbsp maple syrup
        1 banana, sliced
      TEXT
      steps: <<~TEXT
        Mix the oats, milk, yogurt, chia seeds and maple syrup in two jars.
        Cover and leave in the fridge overnight.
        Top with banana in the morning.
      TEXT
    },
    {
      title: "Sheet Pan Lemon Chicken",
      description: "Everything roasts together on one tray.",
      servings: 4, prep_minutes: 15, cook_minutes: 45, favourite: true, tags: "chicken, one pan, family",
      ingredients: <<~TEXT,
        8 chicken thighs
        800 g new potatoes, halved
        2 red onions, cut into wedges
        2 lemons
        4 cloves garlic
        3 tbsp olive oil
        1 tbsp dried thyme
        200 g green beans
      TEXT
      steps: <<~TEXT
        Heat the oven to 200°C.
        Toss the potatoes, onions and garlic with 2 tbsp oil and the thyme on a large tray.
        Add the chicken, skin up, squeeze over one lemon and tuck in the halves. Roast for 35 minutes.
        Add the green beans with the rest of the oil and roast 10 minutes more.
      TEXT
    },
    {
      title: "Tomato and Basil Soup",
      description: nil,
      servings: 4, prep_minutes: 10, cook_minutes: 30, favourite: false, tags: "vegetarian, soup",
      ingredients: <<~TEXT,
        2 tbsp butter
        1 onion, chopped
        2 cloves garlic
        1 kg ripe tomatoes, chopped
        500 ml vegetable stock
        1 tsp sugar
        1 handful basil leaves
        100 ml double cream
      TEXT
      steps: <<~TEXT
        Melt the butter and soften the onion and garlic.
        Add the tomatoes, stock and sugar and simmer for 20 minutes.
        Add the basil and blend until smooth. Stir in the cream and season.
      TEXT
    },
    {
      title: "Fish Tacos with Lime Slaw",
      description: "Crispy fish, crunchy slaw and a quick chipotle mayo.",
      servings: 4, prep_minutes: 20, cook_minutes: 10, favourite: false, tags: "fish, quick",
      ingredients: <<~TEXT,
        500 g white fish fillets
        1 tsp smoked paprika
        1 tsp ground cumin
        8 small tortillas
        1/4 red cabbage, shredded
        2 limes
        3 tbsp mayonnaise
        1 tsp chipotle paste
        1 handful coriander
      TEXT
      steps: <<~TEXT
        Rub the fish with the spices and a pinch of salt.
        Toss the cabbage with the juice of one lime.
        Mix the mayonnaise with the chipotle paste.
        Pan-fry the fish for 3 minutes a side, then flake it.
        Warm the tortillas and fill with fish, slaw, mayo and coriander.
      TEXT
    },
    {
      title: "Banana Bread",
      description: "The best use for brown bananas.",
      servings: 10, prep_minutes: 15, cook_minutes: 60, favourite: true, tags: "baking, snack",
      ingredients: <<~TEXT,
        3 ripe bananas
        75 g butter, melted
        150 g brown sugar
        1 egg, beaten
        1 tsp vanilla extract
        1 tsp baking soda
        1 pinch salt
        190 g plain flour
      TEXT
      steps: <<~TEXT
        Heat the oven to 175°C and line a loaf tin.
        Mash the bananas and mix in the butter, sugar, egg and vanilla.
        Stir in the baking soda, salt and flour until just combined.
        Bake for 55-60 minutes until a skewer comes out clean.
      TEXT
    },
    {
      title: "Greek Salad",
      description: nil,
      servings: 2, prep_minutes: 10, cook_minutes: nil, favourite: false, tags: "vegetarian, salad, quick",
      ingredients: <<~TEXT,
        3 tomatoes, cut into wedges
        1 cucumber, sliced
        1/2 red onion, thinly sliced
        100 g feta
        1 handful kalamata olives
        2 tbsp olive oil
        1 tsp dried oregano
      TEXT
      steps: <<~TEXT
        Put the tomatoes, cucumber, onion and olives in a bowl.
        Top with the feta, drizzle with oil and sprinkle with oregano.
      TEXT
    },
    {
      title: "Mushroom Risotto",
      description: "Worth the stirring.",
      servings: 4, prep_minutes: 10, cook_minutes: 35, favourite: false, tags: "vegetarian, rice",
      ingredients: <<~TEXT,
        1 tbsp olive oil
        30 g butter
        1 onion, finely chopped
        2 cloves garlic
        300 g chestnut mushrooms, sliced
        300 g arborio rice
        150 ml white wine
        1.2 l vegetable stock
        50 g parmesan, grated
      TEXT
      steps: <<~TEXT
        Fry the mushrooms in the oil until golden and set aside.
        Soften the onion and garlic in the butter, then stir in the rice for a minute.
        Add the wine and let it bubble away.
        Add the hot stock a ladle at a time, stirring, for about 20 minutes.
        Stir in the mushrooms and parmesan and rest for 2 minutes.
      TEXT
    },
    {
      title: "Pancakes",
      description: "Fluffy American-style pancakes for slow weekends.",
      servings: 4, prep_minutes: 10, cook_minutes: 20, favourite: true, tags: "breakfast, weekend",
      ingredients: <<~TEXT,
        1 1/2 cups plain flour
        2 tbsp sugar
        2 tsp baking powder
        1 pinch salt
        1 1/4 cups milk
        1 egg
        3 tbsp butter, melted
        maple syrup, to serve
      TEXT
      steps: <<~TEXT
        Whisk the flour, sugar, baking powder and salt in a bowl.
        Whisk the milk, egg and butter, then stir into the dry ingredients until just combined.
        Cook ladlefuls in a hot pan for 2 minutes a side.
        Serve with maple syrup.
      TEXT
    },
    {
      title: "Black Bean Chilli",
      description: "Smoky, filling and better the next day.",
      servings: 6, prep_minutes: 15, cook_minutes: 45, favourite: false, tags: "vegetarian, freezer friendly",
      ingredients: <<~TEXT,
        2 tbsp olive oil
        2 onions, chopped
        2 red peppers, chopped
        4 cloves garlic
        2 tsp ground cumin
        2 tsp smoked paprika
        1 tsp chilli flakes
        3 cans black beans, drained
        2 cans chopped tomatoes (400 g)
        250 ml vegetable stock
        1 lime
        sour cream, to serve
      TEXT
      steps: <<~TEXT
        Soften the onions and peppers in the oil for 10 minutes.
        Add the garlic and spices and cook for a minute.
        Add the beans, tomatoes and stock and simmer for 30 minutes until thick.
        Squeeze in the lime and serve with sour cream.
      TEXT
    },
    {
      title: "Salmon with Soy and Honey",
      description: nil,
      servings: 2, prep_minutes: 5, cook_minutes: 15, favourite: false, tags: "fish, quick",
      ingredients: <<~TEXT,
        2 salmon fillets
        2 tbsp soy sauce
        1 tbsp honey
        1 clove garlic, grated
        1 tsp grated ginger
        150 g basmati rice
        1 head broccoli
      TEXT
      steps: <<~TEXT
        Mix the soy sauce, honey, garlic and ginger and pour over the salmon.
        Bake at 200°C for 12-15 minutes.
        Cook the rice and steam the broccoli. Serve together.
      TEXT
    }
  ].freeze

  # Day offset from Monday, meal, recipe title, servings
  THIS_WEEK = [
    [ 0, "dinner", "Weeknight Spaghetti Bolognese", 4 ],
    [ 1, "breakfast", "Overnight Oats", 2 ],
    [ 1, "dinner", "Chickpea and Spinach Curry", 4 ],
    [ 2, "lunch", "Greek Salad", 2 ],
    [ 2, "dinner", "Salmon with Soy and Honey", 2 ],
    [ 3, "dinner", "Sheet Pan Lemon Chicken", 4 ],
    [ 4, "dinner", "Fish Tacos with Lime Slaw", 4 ],
    [ 5, "breakfast", "Pancakes", 4 ],
    [ 5, "dinner", "Mushroom Risotto", 4 ],
    [ 6, "lunch", "Tomato and Basil Soup", 4 ],
    [ 6, "snack", "Banana Bread", 10 ]
  ].freeze

  LAST_WEEK = [
    [ 0, "dinner", "Black Bean Chilli", 6 ],
    [ 2, "dinner", "Sheet Pan Lemon Chicken", 4 ],
    [ 4, "dinner", "Weeknight Spaghetti Bolognese", 4 ],
    [ 6, "breakfast", "Pancakes", 4 ]
  ].freeze

  PANTRY = [
    [ "salt", nil ], [ "black pepper", nil ], [ "olive oil", nil ], [ "vegetable oil", nil ],
    [ "plain flour", "1 kg" ], [ "basmati rice", "500 g" ], [ "garlic", "6 cloves" ],
    [ "dried oregano", nil ], [ "ground cumin", nil ], [ "smoked paprika", nil ],
    [ "soy sauce", nil ], [ "honey", nil ], [ "onion", "2" ]
  ].freeze

  def self.load
    new.load
  end

  def load
    return User.find_by(email_address: EMAIL) if User.exists?(email_address: EMAIL)

    User.transaction do
      user = User.create!(name: "Demo Cook", email_address: EMAIL, password: PASSWORD)
      recipes = create_recipes(user)
      plan(user, recipes, Week.current, THIS_WEEK)
      plan(user, recipes, Week.current.previous, LAST_WEEK)
      PANTRY.each { |name, amount| user.pantry_items.create!(name: name, amount_text: amount) }
      user.grocery_checks.create!(week_start: Week.current.start, item_key: "spaghetti")
      user.grocery_extras.create!(week_start: Week.current.start, name: "coffee beans")
      user.grocery_extras.create!(week_start: Week.current.start, name: "kitchen roll", checked: true)
      user
    end
  end

  private
    def create_recipes(user)
      RECIPES.each_with_index.to_h do |attributes, index|
        recipe = user.recipes.create!(
          title: attributes[:title],
          description: attributes[:description],
          servings: attributes[:servings],
          prep_minutes: attributes[:prep_minutes],
          cook_minutes: attributes[:cook_minutes],
          favourite: attributes[:favourite],
          tag_list: attributes[:tags],
          ingredients_text: attributes[:ingredients],
          steps_text: attributes[:steps],
          created_at: (RECIPES.size - index).weeks.ago
        )
        [ recipe.title, recipe ]
      end
    end

    def plan(user, recipes, week, entries)
      entries.each do |offset, meal, title, servings|
        user.meal_plan_entries.create!(recipe: recipes.fetch(title), on: week.start + offset, meal: meal, servings: servings)
      end
    end
end
