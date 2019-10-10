class Hand < ApplicationRecord
  belongs_to :user
  belongs_to :round
  has_many :dice

end
