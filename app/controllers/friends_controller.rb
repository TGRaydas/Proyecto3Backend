class FriendsController < ApplicationController
	def get_requests
		friends = Friend.where(user_receiver:current_user)
		render json: friends
	end

	def get_friends
		friends = []
		pending_out = []
		friends_1 = Friend.where(user_receiver_id:params[:user_id], state:2)
		friends_2 = Friend.where(user_sender_id:params[:user_id], state:2)
		pending = Friend.where(user_receiver_id:params[:user_id], state:1)
		friends_1.each do |f|
			p = Profile.where(user:f.user_sender_id)
			p[:created_at] = f.state
			friends.push(p)
		end
		friends_2.each do |f|
			p = Profile.where(user:f.user_receiver_id)
			p[:created_at] = f.state
			friends.push(p)
		end

		pending.each do |f|
			p = Profile.where(user:f.user_sender_id)
			p[:created_at]= f.state
			pending_out.push(p)
		end

		render json:{friends:friends, pending:pending_out}
	end

	def create_requests
		Friend.create(user_sender: current_user, user_receiver:params[:user_receiver])
		render json: {status: "ok"}
	end
end
