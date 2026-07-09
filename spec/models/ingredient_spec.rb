require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should have_many(:recipe_ingredients) }
  it { should have_many(:recipes).through(:recipe_ingredients) }
end
