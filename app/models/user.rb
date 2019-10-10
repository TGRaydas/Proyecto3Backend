class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :hand
  has_many :game_users
  has_many :games, through: :game_users

  def get_last_hand_on_game(game_id)
    actual_round = Round.where(game_id: game_id).order(created_at: :desc).first
    hand = Hand.where(user_id: self.id, round_id: actual_round.id).first
    hand.dices
  end

  def get_my_friends(nickname)
    friends = []
    receivers = Friend.where(user_receiver_id: self.id, state:2)
    senders = Friend.where(user_sender_id: self.id, state:2)

    receivers.each do |friend|
      profile = Profile.where(user_id: friend[:user_sender_id]).first
      if profile[:nickname].include? nickname
        friends.push(profile)
      end
    end
    senders.each do |friend|
      profile = Profile.where(user_id: friend[:user_receiver_id]).first
      if profile[:nickname].include? nickname
        friends.push(profile)
      end
    end
    friends
  end

  def get_my_invitations
    invitations = []
    game_users = GameUser.where(user_id: self.id, position: nil)

    game_users.each do |gu|
      game = Game.find(gu[:game_id])
      inviter = GameUser.where(game_id: game[:id], position: 1).first
      profile = Profile.find_by_user_id(inviter[:user_id])
      invitations.push({game_user: inviter, profile:profile, game:game})
    end
    invitations
  end
end
