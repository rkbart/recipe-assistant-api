require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
  it { should validate_presence_of(:title) }
  it { should validate_numericality_of(:servings).is_greater_than(0) }

  describe "scopes" do
    let!(:recipe1) { create(:recipe, title: "Spicy Chicken", servings: 2, created_at: 2.days.ago) }
    let!(:recipe2) { create(:recipe, title: "Tomato Soup", servings: 4, created_at: 1.day.ago) }
    let!(:recipe3) { create(:recipe, title: "Chicken Salad", servings: 2, created_at: 3.days.ago) }

    describe ".search" do
      it "returns recipes matching the title term" do
        expect(Recipe.search("Chicken")).to match_array([recipe1, recipe3])
      end

      it "returns all recipes if term is blank" do
        expect(Recipe.search("")).to match_array([recipe1, recipe2, recipe3])
      end
    end

    describe ".by_servings" do
      it "returns recipes with the specified servings" do
        expect(Recipe.by_servings(2)).to match_array([recipe1, recipe3])
      end

      it "returns all recipes if servings is blank" do
        expect(Recipe.by_servings(nil)).to match_array([recipe1, recipe2, recipe3])
      end
    end

    describe ".sorted" do
      it "sorts by title in ascending order" do
        expect(Recipe.sorted("title")).to eq([recipe3, recipe1, recipe2])
      end

      it "sorts by created_at in descending order by default" do
        expect(Recipe.sorted("invalid_column")).to eq([recipe2, recipe1, recipe3])
      end

      it "sorts by servings in ascending order" do
        expect(Recipe.sorted("servings")).to eq([recipe1, recipe3, recipe2])
      end

      it "sorts by created_at in ascending order" do
        expect(Recipe.sorted("created_at")).to eq([recipe3, recipe1, recipe2])
      end
    end
  end
end
