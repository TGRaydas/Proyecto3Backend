class FriendsController < ApplicationController
	def get_requests
		friends = Friend.where(user_receiver:current_user)
		render json: friends
	end

	def get_friends
		friends_1 = Friend.where(user_receiver_id:params[:user_id], state:2)
		friends_2 = Friend.where(user_sender_id:params[:user_id], state:2)
		render json:{friends:friends_2}
	end

	def create_requests
		Friend.create(user_sender: current_user, user_receiver:params[:user_receiver])
		render json: {status: "ok"}
	end
end
