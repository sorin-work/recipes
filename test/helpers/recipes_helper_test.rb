require "test_helper"

class RecipesHelperTest < ActionView::TestCase
  test "ingredient amounts carry what the browser needs to rescale them" do
    html = ingredient_amount(ingredients(:pancakes_flour), 2)
    assert_dom_equal %(<span class="ingredient__amount" data-scale-target="amount" data-quantity="1.5" data-unit="cup" data-unit-plural="cups" data-style="fraction">3 cups</span>),
      html
  end

  test "source link shows the site name" do
    recipe = Recipe.new(source_url: "https://www.example.com/recipes/42")
    assert_dom_equal %(<a rel="noopener noreferrer nofollow" target="_blank" href="https://www.example.com/recipes/42">example.com</a>),
      source_link(recipe)
  end

  test "source link refuses anything but http" do
    assert_equal "javascript:alert(1)", source_link(Recipe.new(source_url: "javascript:alert(1)"))
  end
end
