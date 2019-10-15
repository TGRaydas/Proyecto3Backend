Rails.application.routes.draw do
    resources :dices
    resources :hands
    resources :turns
    resources :suits
    resources :rounds
    resources :rules
    resources :games
    resources :game_users
    resources :profiles
    devise_for :users, controllers: {registrations: 'users/registrations', sessions: 'users/sessions'}
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
    get '/my_invitations', to: "game_users#my_invitations"
    get '/statistics/:user_id', to: "profiles#statistics"
    post '/update_game_request', to: "game_users#update_game_request"
    post '/game_invitation/create', to: "game_users#create_invitation"
    get '/game_started', to: "games#started_game"
    post '/start_game', to: "games#start_game"
    get '/my_hand', to: "hands#my_hand"
    get '/games/:id/give_options', to: "games#give_options"
    get '/games/:id/is_my_turn', to: "games#is_my_turn"
    get '/games/:id/dices_in_round', to: "games#current_dices"
    post '/games/:id/end_round', to: "games#end_round"
    post '/games/:id/end_turn', to: "games#end_turn"
    get '/my_user_information/:user_id', to: "profiles#get_my_user_information"
end
