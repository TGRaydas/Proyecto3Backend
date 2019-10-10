class GameRule < ApplicationRecord
  belongs_to :game
  belongs_to :rule
end
