class PantryItemsController < ApplicationController
  before_action :set_pantry_item, only: %i[ edit update destroy ]

  def index
    @pantry_items = Current.user.pantry_items.alphabetical
    @pantry_item = Current.user.pantry_items.new
  end

  def new
    @pantry_item = Current.user.pantry_items.new
  end

  def create
    @pantry_item = Current.user.pantry_items.new(pantry_item_params)

    if @pantry_item.save
      redirect_back_or_to pantry_items_path, notice: "Added #{@pantry_item.name} to the pantry.", status: :see_other
    else
      @pantry_items = Current.user.pantry_items.alphabetical
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @pantry_item.update(pantry_item_params)
      redirect_to pantry_items_path, notice: "Updated #{@pantry_item.name}.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pantry_item.destroy!
    redirect_to pantry_items_path, notice: "Removed #{@pantry_item.name} from the pantry.", status: :see_other
  end

  private
    def set_pantry_item
      @pantry_item = Current.user.pantry_items.find(params[:id])
    end

    def pantry_item_params
      params.expect(pantry_item: %i[ name amount_text ])
    end
end
