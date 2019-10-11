class Rule < ApplicationRecord
  has_many :game_rules
  has_many :rules, through: :game_rules
  has_many :turn
end
