Rails.application.routes.draw do
  if Rails.env.production?
    mount ActionCable.server => '/cable'
  end

  devise_for :pilots, controllers: {
      sessions:      'sessions',
      registrations: 'registrations'
  }

  resources :flights, except: :edit do
    resources :passengers, only: %i[show create destroy]
  end

  root 'home#index'
end
