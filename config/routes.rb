Rails.application.routes.draw do
  resources :dices
  resources :hands
  resources :turns
  resources :suits
  resources :rounds
  resources :rules
  resources :games
  resources :game_users
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/friends_requests', to: "friends#get_requests"
  get '/friends/:user_id', to: "friends#get_friends"
  post '/friends_requests', to: "friends#create_requests"
  post '/update_request', to: "friends#update_request"
  post '/create_request', to: "friends#create_request"
  get '/search_friends', to: "friends#search_friends"
  post '/accept_invitation', to: "game_users#accept_game"
  get '/my_games', to: "game_users#my_games"
  get '/my_friends', to: "friends#my_friends"
  get 'my_invitations', to: "game_users#my_invitations"
end
