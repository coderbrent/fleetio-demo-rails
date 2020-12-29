Rails.application.routes.draw do
  get "dashboard/index"
  root "dashboard#index"
  get "vendors/all"
  match "vendors/performance/:id" => "vendors#performance", via: [:get]
  match "vendors/calculate_performance/:id" => "vendors#calculate_performance", via: [:get]
  match "vendors/get_hours/:id" => "vendors#get_hours", via: [:get]
end
