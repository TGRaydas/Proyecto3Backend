class Game < ApplicationRecord
  has_many :round
  has_many :game_rules
  has_many :rules, through: :game_rules
end
