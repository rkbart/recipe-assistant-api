class RecipeIngredientBlueprint < Blueprinter::Base
  field :name do |recipe_ingredient|
    recipe_ingredient.ingredient.name
  end

  fields :quantity,
         :unit
end
