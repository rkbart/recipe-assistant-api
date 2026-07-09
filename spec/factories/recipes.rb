FactoryBot.define do
  factory :recipe do
    sequence(:title) { |number| "Recipe #{number}" }
    instructions { "Mix everything together and cook until done." }
    servings { 4 }
    prep_time { 15 }
    cook_time { 30 }
  end
end
