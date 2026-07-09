require 'rails_helper'

RSpec.describe "Api::Recipes", type: :request do
  def json
    JSON.parse(response.body)
  end

  describe "GET /api/recipes" do
    it "returns recipes with pagination metadata" do
      recipes = create_list(:recipe, 2)

      get "/api/recipes"

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |recipe| recipe["id"] }).to match_array(recipes.map(&:id))
      expect(json["pagination"]).to include(
        "page" => 1,
        "per_page" => 10,
        "total_pages" => 1,
        "total_count" => 2
      )
    end

    it "filters by title search term" do
      chicken = create(:recipe, title: "Spicy Chicken")
      create(:recipe, title: "Tomato Soup")

      get "/api/recipes", params: { search: "Chicken" }

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |recipe| recipe["id"] }).to eq([chicken.id])
    end

    it "filters by servings" do
      serves_two = create(:recipe, servings: 2)
      create(:recipe, servings: 4)

      get "/api/recipes", params: { servings: 2 }

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |recipe| recipe["id"] }).to eq([serves_two.id])
    end

    it "sorts by an allowed column" do
      create(:recipe, title: "Ziti")
      create(:recipe, title: "Apple Pie")

      get "/api/recipes", params: { sort: "title" }

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |recipe| recipe["title"] }).to eq(["Apple Pie", "Ziti"])
    end

    it "limits per_page to the requested page size" do
      create_list(:recipe, 3)

      get "/api/recipes", params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(json["data"].size).to eq(2)
      expect(json["pagination"]).to include(
        "per_page" => 2,
        "total_pages" => 2,
        "total_count" => 3
      )
    end
  end

  describe "GET /api/recipes/:id" do
    it "returns the recipe with its ingredients" do
      recipe = create(:recipe, title: "Pancakes")
      ingredient = create(:ingredient, name: "Flour")
      create(:recipe_ingredient, recipe: recipe, ingredient: ingredient, quantity: 2, unit: "cups")

      get "/api/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      expect(json).to include(
        "id" => recipe.id,
        "title" => "Pancakes"
      )
      expect(json["ingredients"]).to contain_exactly(
        a_hash_including(
          "name" => "Flour",
          "quantity" => "2.0",
          "unit" => "cups"
        )
      )
    end
  end

  describe "POST /api/recipes" do
    it "creates a recipe" do
      recipe_params = {
        title: "Omelette",
        instructions: "Whisk, pour, and fold.",
        servings: 2,
        prep_time: 5,
        cook_time: 8
      }

      expect do
        post "/api/recipes",
             params: { recipe: recipe_params },
             as: :json
      end.to change(Recipe, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json).to include(
        "title" => "Omelette",
        "servings" => 2,
        "prep_time" => 5,
        "cook_time" => 8
      )
    end

    it "returns validation errors when the recipe is invalid" do
      post "/api/recipes",
           params: { recipe: { title: "", servings: 0 } },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to include("Title can't be blank", "Servings must be greater than 0")
    end
  end

  describe "PATCH /api/recipes/:id" do
    it "updates the recipe" do
      recipe = create(:recipe, title: "Soup", servings: 4)

      patch "/api/recipes/#{recipe.id}",
            params: { recipe: { title: "Stew", servings: 6 } },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json).to include(
        "title" => "Stew",
        "servings" => 6
      )
      expect(recipe.reload.title).to eq("Stew")
    end

    it "returns validation errors when the update is invalid" do
      recipe = create(:recipe)

      patch "/api/recipes/#{recipe.id}",
            params: { recipe: { servings: 0 } },
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to include("Servings must be greater than 0")
    end
  end

  describe "DELETE /api/recipes/:id" do
    it "destroys the recipe" do
      recipe = create(:recipe)

      expect do
        delete "/api/recipes/#{recipe.id}"
      end.to change(Recipe, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
