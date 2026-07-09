require 'rails_helper'

RSpec.describe "Api::V1::Ingredients", type: :request do
  def json
    JSON.parse(response.body)
  end

  describe "GET /api/v1/ingredients" do
    it "returns all ingredients" do
      ingredients = create_list(:ingredient, 2)

      get "/api/v1/ingredients"

      expect(response).to have_http_status(:ok)
      expect(json.map { |ingredient| ingredient["id"] }).to match_array(ingredients.map(&:id))
    end
  end

  describe "GET /api/v1/ingredients/:id" do
    it "returns the ingredient" do
      ingredient = create(:ingredient, name: "Flour")

      get "/api/v1/ingredients/#{ingredient.id}"

      expect(response).to have_http_status(:ok)
      expect(json).to include(
        "id" => ingredient.id,
        "name" => "Flour"
      )
    end

    it "returns a JSON 404 when the ingredient does not exist" do
      get "/api/v1/ingredients/999999"

      expect(response).to have_http_status(:not_found)
      expect(json["errors"]).to contain_exactly(
        a_hash_including(
          "status" => "404",
          "title" => "Not found",
          "detail" => "Ingredient not found"
        )
      )
    end
  end

  describe "POST /api/v1/ingredients" do
    it "creates an ingredient" do
      expect do
        post "/api/v1/ingredients",
             params: { ingredient: { name: "Sugar" } },
             as: :json
      end.to change(Ingredient, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Sugar")
    end

    it "returns validation errors when the ingredient is invalid" do
      post "/api/v1/ingredients",
           params: { ingredient: { name: "" } },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to contain_exactly(
        a_hash_including(
          "status" => "422",
          "title" => "Unprocessable content",
          "detail" => "Name can't be blank",
          "source" => { "attribute" => "name" }
        )
      )
    end
  end

  describe "PATCH /api/v1/ingredients/:id" do
    it "updates the ingredient" do
      ingredient = create(:ingredient, name: "Caster Sugar")

      patch "/api/v1/ingredients/#{ingredient.id}",
            params: { ingredient: { name: "Brown Sugar" } },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Brown Sugar")
      expect(ingredient.reload.name).to eq("Brown Sugar")
    end

    it "returns validation errors when the update is invalid" do
      ingredient = create(:ingredient)

      patch "/api/v1/ingredients/#{ingredient.id}",
            params: { ingredient: { name: "" } },
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to contain_exactly(
        a_hash_including(
          "status" => "422",
          "title" => "Unprocessable content",
          "detail" => "Name can't be blank",
          "source" => { "attribute" => "name" }
        )
      )
    end
  end

  describe "DELETE /api/v1/ingredients/:id" do
    it "destroys the ingredient" do
      ingredient = create(:ingredient)

      expect do
        delete "/api/v1/ingredients/#{ingredient.id}"
      end.to change(Ingredient, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
