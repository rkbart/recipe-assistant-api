module Api
  module V1
    module Ai
      class RecipeSuggestionsController < ApplicationController
        def create
          suggestion = RecipeSuggestion.create!(
            prompt: suggestion_params[:prompt],
            status: "pending"
          )

          # Run synchronously for now. In production, enqueue with:
          # ::Ai::RecipeSuggestionJob.perform_later(suggestion)
          # Process inline since both web + job run in same process
          ::Ai::RecipeSuggestionService.new(suggestion).call

          render json: RecipeSuggestionBlueprint.render(suggestion), status: :accepted
        end

        def show
          suggestion = RecipeSuggestion.find(params[:id])
          render json: RecipeSuggestionBlueprint.render(suggestion)
        end

        def index
          suggestions = RecipeSuggestion.recent.limit(20)
          render json: RecipeSuggestionBlueprint.render(suggestions)
        end

        private

        def suggestion_params
          params.require(:recipe_suggestion).permit(:prompt)
        end
      end
    end
  end
end