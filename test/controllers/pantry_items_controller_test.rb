require "test_helper"

class PantryItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "index" do
    get pantry_items_path
    assert_response :success
    assert_select "td", "plain flour"
    assert_select "td", "1 kg"
    assert_select ".badge", "Always in stock"
  end

  test "create" do
    assert_difference -> { @user.pantry_items.count } do
      post pantry_items_path, params: { pantry_item: { name: "rice", amount_text: "2 kg" } }
    end
    assert_redirected_to pantry_items_path
    assert_equal 2, @user.pantry_items.find_by(name: "rice").quantity
  end

  test "create with errors" do
    post pantry_items_path, params: { pantry_item: { name: "salt", amount_text: "" } }
    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end

  test "update" do
    item = pantry_items(:flour)
    patch pantry_item_path(item), params: { pantry_item: { name: "plain flour", amount_text: "500 g" } }
    assert_redirected_to pantry_items_path
    assert_equal "g", item.reload.unit
  end

  test "destroy" do
    assert_difference -> { @user.pantry_items.count }, -1 do
      delete pantry_item_path(pantry_items(:salt))
    end
  end
end
