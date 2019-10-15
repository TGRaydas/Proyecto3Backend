class Round < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true
  has_many :hands
  has_many :turns

  def finished?
    if self.user_action_id != nil
      false
    else
      true
    end
  end

  def calzo?
    if self.action == true
      true
    else
      false
    end
  end

  def success?
    if self.success == true
      true
    else
      false
    end
  end

  def last_turn_user_position
    last_turn = Turn.where(round_id: self.id).order(created_at: :desc).first
    GameUser.where(game_id: self.game_id, user_id: last_turn.user_id).order(created_at: :desc).first
  end

  def user_action_position
    GameUser.where(game_id: self.game_id, user_id: self.user_action_id).first.position
  end
end
