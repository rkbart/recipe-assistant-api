class RecipeBlueprint < Blueprinter::Base
  identifier :id

  fields :title,
         :instructions,
         :servings,
         :prep_time,
         :cook_time

  association :recipe_ingredients,
              blueprint: RecipeIngredientBlueprint,
              name: :ingredients
end
