class Turn < ApplicationRecord
  belongs_to :suit, optional: true
  belongs_to :rule, optional: true
  belongs_to :round
end
