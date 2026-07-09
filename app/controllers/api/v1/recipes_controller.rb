class Api::V1::RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show update destroy]

  def index
    @pagy, @recipes = pagy(
      Recipe
        .includes(recipe_ingredients: :ingredient)
        .search(params[:search])
        .by_servings(params[:servings])
        .sorted(params[:sort]),
      limit: per_page
    )

    render json: {
      data: RecipeBlueprint.render_as_hash(@recipes),
      pagination: {
        page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      }
    }
  end

  def show
    render json: RecipeBlueprint.render(@recipe)
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      render json: RecipeBlueprint.render(@recipe), status: :created
    else
      render_validation_errors(@recipe)
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: RecipeBlueprint.render(@recipe)
    else
      render_validation_errors(@recipe)
    end
  end

  def destroy
    @recipe.destroy
    head :no_content
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :instructions,
      :servings,
      :prep_time,
      :cook_time,
      ingredient_ids: []
    )
  end

  def set_recipe
    @recipe = Recipe
                .includes(recipe_ingredients: :ingredient)
                .find(params[:id])
  end

  def per_page
    [[params.fetch(:per_page, 10).to_i, 1].max, 100].min
  end
end
