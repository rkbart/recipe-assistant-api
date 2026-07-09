Rails.application.routes.draw do
  namespace :api do
    resources :recipes
    resources :ingredients
  end
end
