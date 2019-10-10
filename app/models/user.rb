class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :hand

  def get_last_hand_on_game(game_id)
    actual_round = Round.where(game_id: game_id).order(created_at: :desc).first
    hand = Hand.where(user_id: self.id, round_id: actual_round.id).first
    hand.dices

  end
end
