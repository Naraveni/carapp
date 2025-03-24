Rails.application.routes.draw do
  resources :cars do
    collection do
      get 'upload'
      post 'upload_csv'
      get 'download_csv_template'
    end
  end
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  devise_for :users
  resources :bookings
  get 'admin/dashboard', to: 'admin#dashboard', as: 'admin_dashboard'
  post 'admin/send_csv', to: 'admin#send_csv', as: 'send_csv_admin_dashboard'
end
