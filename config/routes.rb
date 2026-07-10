Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :recipes
      resources :ingredients

      namespace :ai do
        resources :recipe_suggestions, only: %i[create show index]
      end
    end
  end
end
