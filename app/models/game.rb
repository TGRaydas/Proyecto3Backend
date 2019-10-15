class Game < ApplicationRecord
  has_many :round
  has_many :game_rules
  has_many :rules, through: :game_rules
  has_many :game_users
  has_many :users, through: :game_users


  def search_previous_alive_player(current_position)
    alive = true
    while alive
      if current_position == 1
        current_position = players.length
      elsif current_position > 1
        current_position -= 1
      end
      possible_player = players.where(position: current_position).first
      if possible_player.final_place == nil
        alive = false
        puts "search_previous_alive_player return: #{User.find(possible_player.user_id).email}"
        return User.find(possible_player.user_id)
      end
    end
  end

  def search_next_alive_player(current_position, players)
    alive = true
    while alive
      if current_position < players.length
        current_position += 1
      elsif current_position == players.length
        current_position = 1
      end
      puts "players: #{players}, players.length: #{players.length}, players[0]: #{players[0]}"
      possible_player = players.where(position:current_position).first
      if possible_player.final_place == nil
        alive = false
        return User.find(possible_player.user_id)
      end
    end
  end
end
