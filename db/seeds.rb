Recipe.destroy_all
Ingredient.destroy_all
RecipeIngredient.destroy_all

recipes_data = [
  { title: "Chicken Adobo", servings: 4, prep_time: 15, cook_time: 40, instructions: "Marinate chicken, simmer with soy sauce and vinegar.", ingredients: [ [ "Chicken", 1, "kg" ], [ "Soy Sauce", 0.5, "cup" ], [ "Vinegar", 0.5, "cup" ], [ "Garlic", 6, "cloves" ] ] },
  { title: "Pork Adobo", servings: 5, prep_time: 20, cook_time: 50, instructions: "Simmer pork in soy sauce and vinegar until tender.", ingredients: [ [ "Pork", 1, "kg" ], [ "Soy Sauce", 0.5, "cup" ], [ "Vinegar", 0.5, "cup" ], [ "Garlic", 8, "cloves" ] ] },
  { title: "Sinigang na Baboy", servings: 6, prep_time: 20, cook_time: 60, instructions: "Boil pork with tamarind and vegetables.", ingredients: [ [ "Pork", 1, "kg" ], [ "Tamarind", 1, "pack" ], [ "Kangkong", 1, "bunch" ], [ "Tomato", 2, "pieces" ] ] },
  { title: "Tinolang Manok", servings: 4, prep_time: 15, cook_time: 35, instructions: "Cook chicken with ginger and green papaya.", ingredients: [ [ "Chicken", 1, "kg" ], [ "Ginger", 1, "thumb" ], [ "Green Papaya", 1, "piece" ] ] }, { title: "Chicken Curry", servings: 5, prep_time: 20, cook_time: 45, instructions: "Cook chicken with curry powder and coconut milk.", ingredients: [ [ "Chicken", 1, "kg" ], [ "Curry Powder", 2, "tbsp" ], [ "Coconut Milk", 2, "cups" ] ] },
  { title: "Beef Caldereta", servings: 6, prep_time: 25, cook_time: 90, instructions: "Slow-cook beef with tomato sauce and liver spread.", ingredients: [ [ "Beef", 1, "kg" ], [ "Tomato Sauce", 2, "cups" ], [ "Liver Spread", 1, "can" ] ] },
  { title: "Pancit Canton", servings: 4, prep_time: 15, cook_time: 20, instructions: "Stir-fry noodles with vegetables and meat.", ingredients: [ [ "Canton Noodles", 500, "g" ], [ "Chicken", 250, "g" ], [ "Cabbage", 0.5, "head" ] ] },
  { title: "Garlic Fried Rice", servings: 3, prep_time: 5, cook_time: 10, instructions: "Fry garlic and mix with rice.", ingredients: [ [ "Rice", 3, "cups" ], [ "Garlic", 8, "cloves" ] ] },
  { title: "Chicken Afritada", servings: 5, prep_time: 20, cook_time: 45, instructions: "Cook chicken in tomato sauce with potatoes and carrots.", ingredients: [ [ "Chicken", 1, "kg" ], [ "Tomato Sauce", 2, "cups" ], [ "Potato", 2, "pieces" ], [ "Carrot", 1, "piece" ] ] },
  { title: "Menudo", servings: 6, prep_time: 25, cook_time: 50, instructions: "Cook pork with liver, potatoes, and tomato sauce.", ingredients: [ [ "Pork", 1, "kg" ], [ "Liver", 250, "g" ], [ "Tomato Sauce", 2, "cups" ] ] },
  { title: "Bicol Express", servings: 4, prep_time: 15, cook_time: 35, instructions: "Cook pork in coconut milk and chili.", ingredients: [ [ "Pork", 500, "g" ], [ "Coconut Milk", 2, "cups" ], [ "Chili", 5, "pieces" ] ] },
  { title: "Sisig", servings: 4, prep_time: 30, cook_time: 20, instructions: "Chop and fry pork with onions and chili.", ingredients: [ [ "Pork", 500, "g" ], [ "Onion", 1, "piece" ], [ "Chili", 3, "pieces" ] ] } ]

  recipes_data.each do |data|
    recipe = Recipe.create!(
      title: data[:title],
      servings: data[:servings],
      prep_time: data[:prep_time],
      cook_time: data[:cook_time],
      instructions: data[:instructions]
    )

    data[:ingredients].each do |name, quantity, unit|
      ingredient = Ingredient.find_or_create_by!(name: name)
      RecipeIngredient.create!(recipe: recipe, ingredient: ingredient, quantity: quantity, unit: unit)
    end
  end

  puts "Seeded #{Recipe.count} recipes!"
  puts "Seeded #{Ingredient.count} ingredients!"
  puts "Seeded #{RecipeIngredient.count} recipe ingredients!"
