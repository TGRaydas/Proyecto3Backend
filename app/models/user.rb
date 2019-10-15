class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :hand
  has_many :game_users
  has_many :games, through: :game_users
  has_one :profile
  def get_last_hand_on_game(game_id)
    actual_round = Round.where(game_id: game_id).order(created_at: :desc).first
    hand = Hand.where(user_id: self.id, round_id: actual_round.id).first
    hand.dice
  end

  def my_current_games
    games = GameUser.where(user_id: self.id).where.not(position: nil)
    my_current_games = []
	games.each do |g|
      game = Game.find(g.game_id)
      if !game.finished
        my_current_games.push(game)
      end
	end  
    return my_current_games
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
      if game.finished
        next
      end
      inviter = GameUser.where(game_id: game[:id], position: 1).first
      profile = Profile.find_by_user_id(inviter[:user_id])
      invitations.push({game_user_inviter: inviter, profile:profile, game:game, game_user: gu})
    end
    invitations
  end

  def total_games
    games = GameUser.where(user_id: self.id, accepted: true).where.not(final_place: nil)
    games
  end

  def won_games
    won_games = GameUser.where(user_id: self.id, accepted: true, final_place: 1)
    won_games
  end

  def percentage_won_games
    percentage_won_games = ((won_games.length.to_f / total_games.length.to_f) * 100).round(2)
    percentage_won_games
  end

  def average_final_position
    average_final_position = total_games.average(:final_place).to_f.round(2)
    average_final_position
  end

  # def average_final_dice
  #   average_final_dice =
  # end

  def most_frequent_play
    turns = Turn.where(user_id: self.id)
    most_frequent_play = turns.group(:suit_id, :quantity).count.sort_by{|pair, amount| amount}.last
    most_frequent_play
  end

end
