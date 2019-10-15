class Game < ApplicationRecord
    has_many :round
    has_many :game_rules
    has_many :rules, through: :game_rules
    has_many :game_users
    has_many :users, through: :game_users


    def search_previous_alive_player(current_position)
        alive = true
        players = self.players
        while alive
            if current_position == 1
                current_position = players.length
            elsif current_position > 1
                current_position -= 1
            end
            possible_player = players.where(position: current_position).first
            if possible_player.final_place == nil
                alive = false
                return User.find(possible_player.user_id)
            end
        end
    end

    def search_next_alive_player(current_position)
        alive = true
        players = self.players
        while alive
            if current_position < players.length
                current_position += 1
            elsif current_position == players.length
                current_position = 1
            end
            possible_player = players.where(position: current_position).first
            if possible_player.final_place.nil?
                alive = false
                return User.find(possible_player.user_id)
            end
        end
    end

    def current_dices
        actual_round = Round.where(game_id: self.id).order(created_at: :desc).first
        hands = actual_round.hands
        dices = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
        hands.each do |h|
            h.dices.each do |d|
                dices[d.suit_id] += 1
            end
        end
        dices
    end

    def next_player
        game_rounds = Round.where(game_id: self.id).order(created_at: :desc)
        last_round = game_rounds.first
        if last_round.finished?
            user_action_position = last_round.user_action_position
            if last_round.calzo?
                return User.find(last_round.user_action_id)
            elsif last_round.dudo?
                if last_round.success?
                    return search_previous_alive_player(user_action_position)
                else
                    return User.find(last_round.user_action_id)
                end
            end
        else
            last_player_position = last_round.last_turn_user_position
            return search_next_alive_player(last_player_position)
        end
    end

    def alive_players
        players = GameUser.where(game_id: self.id, final_place: nil)
    end

    def players
        players = GameUser.where(game_id: self.id)
    end

    def start_round #Funciona desde la segunda ronda en adelante
        new_round = Round.create(game_id: self.id)
        alive_players = self.alive_players
        alive_players.each do |ap|
            last_round = Round.where(game_id: self.id).order(created_at: :desc).second
            last_hand_dice_quantity = Hand.where(user_id: ap.user_id, round_id: last_round.id).first.dice_quantity
            hand = Hand.create(round_id:new_round.id, dice_quantity: last_hand_dice_quantity, user_id:ap.user_id)
            (1..last_hand_dice_quantity).each do |_|
                Dice.create(suit_id: rand(1..6), hand_id: hand.id)
            end
        end
    end

    def check_calzo(looked_suit, looked_quantity)
        dices = self.current_dices
        if looked_suit == 1
            if suits[looked_suit] == looked_quantity
                return true
            else
                return false
            end
        else
            if suits[looked_suit] + suits[1] == looked_quantity
                return true
            else
                return false
            end
        end
    end

    def check_dudo(looked_suit, looked_quantity)
        suits = @game.current_dices
        if looked_suit == 1
            if suits[looked_suit] < doubt_quantity
                return true
            end
        else
            if suits[looked_suit] + suits[1] < looked_quantity
                return true
            end
        end
        return false
    end
end

