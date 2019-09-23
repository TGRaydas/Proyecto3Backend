Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/friends_requests', to: "friends#get_requests"
  get '/friends/:user_id', to: "friends#get_friends"
  post '/friends_requests', to: "friends#create_requests"

end
