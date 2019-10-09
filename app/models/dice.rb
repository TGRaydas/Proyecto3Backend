class Dice < ApplicationRecord
  belongs_to :hand
  belongs_to :suit
end
