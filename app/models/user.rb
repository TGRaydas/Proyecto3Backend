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

  def average_final_dices_won_games
    final_dices = []
    won_games.each do |wg|
      final_round = Round.where(game_id: wg.game_id).order(created_at: :desc).first
      final_hand = Hand.where(round_id: final_round.id, user_id: self.id).order(created_at: :desc).first
      final_dices.push(final_hand.dice_quantity)
    end
    average_final_dices_won_games = final_dices.sum.to_f / final_dices.length.to_f
    average_final_dices_won_games
  end

  def most_frequent_play
    most_frequent_play = Turn.where(user_id: self.id).group(:quantity, :suit_id).count.sort_by{|pair, amount| amount}.last
    most_frequent_play_json = {
        quantity: most_frequent_play[0][0],
        suit: most_frequent_play[0][1],
        frequency: most_frequent_play[1]
    }
    most_frequent_play_json
  end

  def percentage_correct_dudos
    total_dudos = Round.where(user_action_id: self.id, action: false)
    correct_dudos = Round.where(user_action_id: self.id, action: false, success: true)
    percentage_correct_dudos = ((correct_dudos.length.to_f / total_dudos.length.to_f) * 100).round(2)
    percentage_correct_dudos
  end

  def percentage_correct_calzos
    total_calzos = Round.where(user_action_id: self.id, action: true)
    correct_calzos = Round.where(user_action_id: self.id, action: true, success: true)
    percentage_correct_calzos = ((correct_calzos.length.to_f / total_calzos.length.to_f) * 100).round(2)
    percentage_correct_calzos
  end

  def percentage_special_moves
    total_turns = Turn.where(user_id: self.id)
    special_turns = total_turns.where.not(rule_id: nil)
    percentage_special_moves =  ((special_turns.length.to_f / total_turns.length.to_f) * 100).round(2)
    percentage_special_moves
  end

end
