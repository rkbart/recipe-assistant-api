module Ai
  class RecipeSuggestionJob < ApplicationJob
    queue_as :default

    def perform(recipe_suggestion)
      Ai::RecipeSuggestionService.new(recipe_suggestion).call
    end
  end
end