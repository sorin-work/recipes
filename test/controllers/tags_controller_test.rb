require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "index" do
    get tags_path
    assert_response :success
    assert_select "input[value=breakfast]"
    assert_select "input[value=dinner]", count: 0
  end

  test "rename" do
    patch tag_path(tags(:quick)), params: { tag: { name: "Weeknight" } }
    assert_redirected_to tags_path
    assert_equal "weeknight", tags(:quick).reload.name
  end

  test "renaming onto another tag merges them" do
    patch tag_path(tags(:quick)), params: { tag: { name: "breakfast" } }

    assert_not Tag.exists?(tags(:quick).id)
    assert_equal [ "breakfast" ], recipes(:pasta).reload.tags.map(&:name)
  end

  test "delete keeps the recipes" do
    assert_no_difference -> { Recipe.count } do
      delete tag_path(tags(:quick))
    end
    assert_empty recipes(:pasta).reload.tags
  end

  test "someone else's tag" do
    delete tag_path(tags(:dinner))
    assert_response :not_found
  end
end
