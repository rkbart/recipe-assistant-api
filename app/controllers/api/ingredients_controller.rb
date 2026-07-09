class Api::IngredientsController < ApplicationController
  before_action :set_ingredient, only: [ :show, :update, :destroy ]

  def index
    @ingredients = Ingredient.all

    render json: IngredientBlueprint.render(@ingredients)
  end

  def show
    render json: IngredientBlueprint.render(@ingredient)
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)
    if @ingredient.save
      render json: IngredientBlueprint.render(@ingredient), status: :created
    else
      render json: @ingredient.errors, status: :unprocessable_entity
    end
  end

  def update
    if @ingredient.update(ingredient_params)
      render json: IngredientBlueprint.render(@ingredient)
    else
      render json: @ingredient.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient.destroy
    head :no_content
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name)
  end

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
end
