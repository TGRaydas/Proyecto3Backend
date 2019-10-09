class Turn < ApplicationRecord
  belongs_to :suit
  belongs_to :rule
  belongs_to :round
end
