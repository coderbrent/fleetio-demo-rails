Rails.application.routes.draw do
  get "dashboard/index"
  root "dashboard#index"
  get "vendors/all"
  match "vendors/performance/:id" => "vendors#performance", via: [:get]
  # resources :vendors, defaults: { format: :json }
end
