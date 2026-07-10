class RecipeSuggestionBlueprint < Blueprinter::Base
  identifier :id

  fields :prompt,
         :status,
         :model_used,
         :requested_at,
         :completed_at,
         :created_at

  field :response do |suggestion|
    if suggestion.response.present?
      begin
        JSON.parse(suggestion.response)
      rescue JSON::ParserError
        suggestion.response
      end
    end
  end
end