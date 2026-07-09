require 'rails_helper'

RSpec.describe "Api::Ingredients", type: :request do
  def json
    JSON.parse(response.body)
  end

  describe "GET /api/ingredients" do
    it "returns all ingredients" do
      ingredients = create_list(:ingredient, 2)

      get "/api/ingredients"

      expect(response).to have_http_status(:ok)
      expect(json.map { |ingredient| ingredient["id"] }).to match_array(ingredients.map(&:id))
    end
  end

  describe "GET /api/ingredients/:id" do
    it "returns the ingredient" do
      ingredient = create(:ingredient, name: "Flour")

      get "/api/ingredients/#{ingredient.id}"

      expect(response).to have_http_status(:ok)
      expect(json).to include(
        "id" => ingredient.id,
        "name" => "Flour"
      )
    end
  end

  describe "POST /api/ingredients" do
    it "creates an ingredient" do
      expect do
        post "/api/ingredients",
             params: { ingredient: { name: "Sugar" } },
             as: :json
      end.to change(Ingredient, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Sugar")
    end

    it "returns validation errors when the ingredient is invalid" do
      post "/api/ingredients",
           params: { ingredient: { name: "" } },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json).to include("name")
    end
  end

  describe "PATCH /api/ingredients/:id" do
    it "updates the ingredient" do
      ingredient = create(:ingredient, name: "Caster Sugar")

      patch "/api/ingredients/#{ingredient.id}",
            params: { ingredient: { name: "Brown Sugar" } },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Brown Sugar")
      expect(ingredient.reload.name).to eq("Brown Sugar")
    end

    it "returns validation errors when the update is invalid" do
      ingredient = create(:ingredient)

      patch "/api/ingredients/#{ingredient.id}",
            params: { ingredient: { name: "" } },
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json).to include("name")
    end
  end

  describe "DELETE /api/ingredients/:id" do
    it "destroys the ingredient" do
      ingredient = create(:ingredient)

      expect do
        delete "/api/ingredients/#{ingredient.id}"
      end.to change(Ingredient, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
