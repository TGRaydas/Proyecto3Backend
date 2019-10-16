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
            h.dice.each do |d|
                dices[d.suit_id] += 1
            end
        end
        dices
    end

    def notify_next_turn(user_id)
        begin
            client = Exponent::Push::Client.new
            messages = [
                {to: User.find(user_id).token, body: "Is your turn to play in " + self.name}
            ]
            client.publish messages
        rescue
        end
    end

    def next_player_turn_notification
        game_rounds = Round.where(game_id: self.id).order(created_at: :desc)
        last_round = game_rounds.first
        last_player_position = last_round.last_turn_user_position.position
        puts "wea", last_player_position, "fin"
        return search_next_alive_player(last_player_position)
    end

    def next_player_second_round_start_notification
        last_round = Round.where(game_id: self.id).order(created_at: :desc).second
        game_user = GameUser.where(game_id: self.id, user_id: last_round.user_action_id).first
        if last_round.calzo?
            return User.find(last_round.user_action_id)
        elsif last_round.dudo?
            puts "Logro de la ultima ronda: #{last_round.success}"
            if last_round.success
                return self.search_previous_alive_player(game_user.position)
            else
                return User.find(last_round.user_action_id)
            end
        end
    end

    def next_player_starting_game
        player_with_first_position = GameUser.where(game_id: self.id, position: 1).first
        return User.find(player_with_first_position.user_id)
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
            hand = Hand.create(round_id: new_round.id, dice_quantity: last_hand_dice_quantity, user_id: ap.user_id)
            (1..last_hand_dice_quantity).each do |_|
                Dice.create(suit_id: rand(1..6), hand_id: hand.id)
            end
        end
        next_user_id = self.next_player_second_round_start_notification
        self.notify_next_turn(next_user_id.id)
    end

    def check_calzo(looked_suit, looked_quantity)
        suits = self.current_dices
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
        suits = self.current_dices
        puts suits
        if looked_suit == 1
            puts "revisando ases"
            if suits[looked_suit] < looked_quantity
                return true
            end
        else
            puts "Entre al else"
            if suits[looked_suit] + suits[1] < looked_quantity
                puts "Entre donde tengo que entrar "
                return true
            end
        end
        puts "Retornando false"
        return false
    end

    def change_dice_quantity_from_hand(round_id, user_id, update_quantity)
        hand = Hand.where(round_id: round_id, user_id: user_id).first
        if update_quantity > 0 and hand.dice_quantity == 5
            return
        end
        hand.update(dice_quantity: hand.dice_quantity + update_quantity)
    end

    def set_final_positions
        last_hands = self.round.order(created_at: :desc).first.hands
        last_hands.each do |h|
            if h.dice_quantity == 0
                players = GameUser.where(game_id: self.id)
                new_position = players.length
                last_player_positioned = players.where.not(final_place: nil).order(final_place: :desc).first
                if !last_player_positioned.nil?
                    new_position = last_player_positioned.position - 1
                end
                puts "Nueva posicion final #{new_position}"
                players.where(user_id: h.user_id).first.update(final_place: new_position)
            end
        end
    end

    def game_finished_for_user(user_id)
        last_user_hand = self.round.order(created_at: :desc).first.hands.where(user_id: user_id).first
        if last_user_hand.dice_quantity == 0
            true
        else
            false
        end
    end
end

