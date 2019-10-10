
class FriendsController < ApplicationController
	def get_requests
		friends = Friend.where(user_receiver_id:params[:user_id])
		render json: friends
	end

	def get_friends
		friends = []
		pending_out = []
		friends_1 = Friend.where(user_receiver_id:params[:user_id], state:2)
		friends_2 = Friend.where(user_sender_id:params[:user_id], state:2)
		pending = Friend.where(user_receiver_id:params[:user_id], state:1)
		friends_1.each do |f|
			p = Profile.find_by(user_id:f.user_sender_id)
			friends.push(p)
		end
		friends_2.each do |f|
			p = Profile.find_by(user_id:f.user_receiver_id)
			friends.push(p)
		end
		pending.each do |f|
			p = Profile.find_by(user_id:f.user_sender_id)
			pending_out.push(p)
		end
		render json:{friends:friends, pending:pending_out}
	end

	def create_request
		p = Profile.find_by(nickname: params[:user_sender])
		Friend.create(user_sender_id: params[:user_id], user_receiver_id: p.user_id)
		friend_token = User.find(p.user_id).token
		client = Exponent::Push::Client.new		
		messages = [
			{to: friend_token, body:"Friend request from " + p.nickname}
		]
		client.publish messages
		puts "amigo:"
		puts  User.find(p.user_id)
		puts "friend_token:"
		puts friend_token
		render json: {status: "ok", friend_token: friend_token}
	end

	def update_request
		f = Friend.where(user_receiver_id: params[:user_id], user_sender_id: params[:user_sender]).first
		f.update(state: params[:state])
		render json:{status:"ok"}
	end

	def search_friends
		query = params[:query]
		profiles = Profile.where("nickname LIKE ?", "%#{query}%")
		render json:{profiles:profiles}
		
	end
	def my_friends
    		user = User.find(params[:user_id])
    		@friends_by_nickname = user.get_my_friends(params[:query])
    		render json: @friends_by_nickname
  	end
end
