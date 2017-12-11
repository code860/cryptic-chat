Rails.application.routes.draw do
  resources :chat_rooms
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  get 'hello_world', to: 'hello_world#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/chat_cable'
end
