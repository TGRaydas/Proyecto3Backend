# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


def check_calzo(looked_quantity, looked_suit, dices)
    suits = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
    # puts "suits 1: #{suits}"
    # puts "suits[1]: #{suits[1]}"
    dices.each do |d|
        suits[d.suit.id] += 1
    end
    # puts "suits 2: #{suits}"
    if looked_suit == 1
        if suits[looked_suit] == looked_quantity
            true
        end
    else
        if suits[looked_suit] + suits[1] == looked_quantity
            true
        end
    end
    false
end

def check_dudo(doubt_quantity, doubt_suit, dices)
    suits = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
    dices.each do |d|
        suits[d.suit.id] += 1
    end
    if doubt_suit == 1
        if suits[doubt_suit] < doubt_quantity
            true
        end
    else
        if suits[doubt_suit] + suits[1] < doubt_quantity
            true
        end
    end
    false
end

def search_next_alive_player(current_position, players)
    alive = true
    while alive
        if current_position < players.length
            current_position += 1
        elsif current_position == players.length
            current_position = 1
        end
        # puts "players: #{players}, players.length: #{players.length}, players[0]: #{players[0]}"
        possible_player = players.where(position: current_position).first
        if possible_player.final_place == nil
            alive = false
            # puts "search_next_alive_player return: #{User.find(possible_player.user_id).email}"
            return User.find(possible_player.user_id)
        end
    end
end

def search_previous_alive_player(current_position, players)
    alive = true
    while alive
        if current_position == 1
            current_position = players.length
        elsif current_position > 1
            current_position -= 1
        end
        # puts "players: #{players}, players.length: #{players.length}, players[0]: #{players[0]}"
        possible_player = players.where(position: current_position).first
        if possible_player.final_place == nil
            alive = false
            # puts "search_previous_alive_player return: #{User.find(possible_player.user_id).email}"
            return User.find(possible_player.user_id)
        end
    end
end


constants = {game_1: "GAME 1",
             description_siciliana: "Si el segundo jugador en jugar en una ronda duda,
                                    el perdedor de la acción pierde dos dados en vez de uno",
             description_picado: "Si un jugador posee dos ases, puede picar. Cuando un jugador pica, el sentido del juego cambia.
                                    El siguiente jugador solamente puede dudar el picado o seguir jugando.",
             description_paso: "Si un jugador posee 5 dados y todos estos son iguales, distintos o tiene un trio y un par, puede pasar.
                                  Cuando un jugador pasa, le toca al siguiente jugador y este solamente puede seguir juganddo o dudar el paso",
             description_cambio_as: "En cualquier momento un jugador puede cambiar la cantidad de dados a la mitad más uno de ases.\n Ej: Si tiene 7 cuadras puede decir 4 ases.\n
                                        Si otro jugador desea volver a otra pinta, debe decir duplicar el numero de dados. \n Ej: Si tiene 3 ases puede decir 7 de algo "
}
Suit.create(name: "As")
Suit.create(name: "Tontos")
Suit.create(name: "Trenes")
Suit.create(name: "Cuadras")
Suit.create(name: "Quina")
Suit.create(name: "Sexta")

Rule.create(name: "Siciliana", description: constants["description_siciliana"])
Rule.create(name: "Picado", description: constants["description_picado"])
Rule.create(name: "Paso", description: constants["description_paso"])
Rule.create(name: "Cambio a As", description: constants["description_cambio_as"])

User.create(email: "pgrand@miuandes.cl", password: "password")
User.create(email: "ijfigueroa@miuandes.cl", password: "password")
User.create(email: "vicorrea@miuandes.cl", password: "password")
User.create(email: "mmestevez@miuandes.cl", password: "password")
User.create(email: "mrecabarren@miuandes.cl", password: "password")
User.create(email: "rmarin@miuandes.cl", password: "password")
User.create(email: "jtellez@miuandes.cl", password: "password")

Profile.create(nickname: 'Pedrito ElCaja Grand', user_id: 1)
Profile.create(nickname: 'Ignacio ElAngry Figueroa', user_id: 2)
Profile.create(nickname: 'Vicente ElHacker Correa', user_id: 3)
Profile.create(nickname: 'Margarita LaAyudante Estevez', user_id: 4)
Profile.create(nickname: 'Matias SeCayoSaf Recabarren', user_id: 5)
Profile.create(nickname: "Raimundo ELPiscolas Marin", user_id: 6)
Profile.create(nickname: "Joaquin ElJats Tellez", user_id: 7)

Friend.create(user_sender_id: 1, user_receiver_id: 2, state: 2)
Friend.create(user_sender_id: 1, user_receiver_id: 3, state: 2)
Friend.create(user_sender_id: 1, user_receiver_id: 4, state: 2)
Friend.create(user_sender_id: 1, user_receiver_id: 5, state: 0)

Friend.create(user_sender_id: 2, user_receiver_id: 3, state: 2)
Friend.create(user_sender_id: 2, user_receiver_id: 4, state: 2)
Friend.create(user_sender_id: 2, user_receiver_id: 5, state: 2)

Friend.create(user_sender_id: 5, user_receiver_id: 4, state: 2)

Friend.create(user_sender_id: 6, user_receiver_id: 3, state: 2)
Friend.create(user_sender_id: 6, user_receiver_id: 7, state: 2)
Friend.create(user_sender_id: 6, user_receiver_id: 2, state: 2)

Friend.create(user_sender_id: 7, user_receiver_id: 5, state: 2)
Friend.create(user_sender_id: 7, user_receiver_id: 4, state: 2)


game_count = 0
(1..10).each do |g|
    # puts "Juego #{game_count}"
    game_count += 1
    game = Game.create(name: "game #{g}", finished: false, startable: true)
    users = User.all
    owner = users[rand(0..users.length - 1)]
    GameUser.create(user_id: owner.id, game_id: game.id, position: 1, accepted: true, final_place: nil)
    owner_friendships = Friend.where(user_receiver_id: owner.id, state: 2).or(Friend.where(user_sender_id: owner.id, state: 2))
    owner_friends = []
    players = []
    owner_friendships.each do |of|
        if of.user_sender_id == owner.id
            owner_friends.push(User.find(of.user_receiver_id))
        else
            owner_friends.push(User.find(of.user_sender_id))
        end
    end
    position = 2
    while players.length < 2
        owner_friends.each do |of|
            accepted = rand(1..2)
            if accepted == 1
                GameUser.create(user_id: of.id, game_id: game.id, position: position, accepted: true)
                position += 1
            else
                GameUser.create(user_id: of.id, game_id: game.id, position: nil, accepted: false)
            end
        end
        players = GameUser.where(game_id: game.id, accepted: true).order(position: :asc)
        players.each do |p|
            owner_friends.delete(User.find(p.user_id))
        end
    end
    game_finished = false
    current_position = 1
    place = players.length
    round_count = 0
    while !game_finished
        # puts "\tRonda #{round_count}"
        round = Round.create(game_id: game.id)
        players.each do |p| #Crear una mano para cada jugador
            prev_round = Round.where(game_id: game.id).order(created_at: :desc).second
            if p.final_place != nil #Si el jugador perdio, no le crees una mano
                next
            end
            if prev_round != nil
                previous_hand = Hand.where(user_id: p.user_id, round_id: prev_round.id).first
                Hand.create(user_id: p.user_id, round_id: round.id, dice_quantity: previous_hand.dice_quantity)
            else
                Hand.create(user_id: p.user_id, round_id: round.id, dice_quantity: 5)
            end
        end
        hands = Hand.where(round_id: round.id)
        dices = []
        hands.each do |h| #crear los dados para cada mano
            (1..h.dice_quantity).each do |_|
                d = Dice.create(suit_id: rand(1..6), hand_id: h.id)
                dices.push(d)
            end
        end
        round_finished = false
        actual_dice_quantity = Hand.where(round_id: round.id).sum("dice_quantity") #CAntidad total de dados que hay en el juego
        round_count += 1
        turn_count = 0
        while !round_finished
            # puts "\t\tTurno #{turn_count}"
            turn_count += 1
            # # puts "current_position: #{current_position}"
            # puts "111"
            actual_player = User.find(players.where(position: current_position).first.user_id)
            # puts
            actual_hand = Hand.where(user_id: actual_player.id, round_id: round.id).first
            next_player = nil
            last_turn = Turn.where(round_id: round.id).order(created_at: :desc).first
            if last_turn != nil #Del turno 2 en adelante
                # # puts "current_position: #{current_position}"
                previous_player = search_previous_alive_player(current_position, players)
                previous_player_hand = Hand.where(user_id: previous_player.id).first
                probability = rand(1..10)
                #AQUI HAY QUE ASEGURARSE QUE SI LA CANTIDAD DE DADOS ES 1 MENOR QUE LA CANTIDAD TOTAL DE DADOS, HAY QUE DUDA
                if last_turn.quantity >= actual_dice_quantity - 2
                    probability = 9
                end
                if probability.between?(1, 2) #CALZO
                    action = true
                    success = false
                    new_dice_quantity = actual_hand.dice_quantity
                    if check_calzo(last_turn.quantity, last_turn.suit_id, dices)
                        # puts "BIEN CALZADO"
                        success = true
                        if actual_hand.dice_quantity <= 4
                            new_dice_quantity += 1
                        end
                    else
                        # puts "MAL CALZADO"
                        new_dice_quantity -= 1
                    end
                    next_player = actual_player
                    actual_hand.update(dice_quantity: new_dice_quantity)
                    round.update(user_action_id: actual_player.id, success: success, action: action)
                    round_finished = true
                elsif probability.between?(3, 7)
                    # puts"Juego"
                    #CONDICION DE SEGUIR LA PARTIDA
                    probability2 = 1
                    # # puts "last_turn.suit_id: #{last_turn.suit_id}, class of last_turn.suit_id: #{last_turn.suit_id.class}"
                    if last_turn.suit_id == 6
                        probability2 = rand(3..4)
                    elsif last_turn.suit_id == 1
                        probability2 = rand(1..3)
                    else
                        probability2 = rand(1..4)
                    end
                    new_dice_quantity = last_turn.quantity
                    new_suit = last_turn.suit_id
                    #PROBABILIDAD DE SUBIR LA PINTA Y SUBIR EL NUMERO
                    if probability2 == 1
                        new_suit += 1
                        new_dice_quantity += 1
                        # PROBABILIDAD DE SUBIR LA PINTA Y MANTENER EL NUMERO
                    elsif probability2 == 2
                        new_suit += 1
                        # PROBABILIDAD DE MANTENER LA PINTA Y SUBIR EL NUMERO
                    elsif probability2 == 3
                        new_dice_quantity += 1
                        # BAJAR PINTA SUBIR NUMERO
                    else
                        new_suit -= 1
                        new_dice_quantity += 1
                    end
                    Turn.create(suit_id: new_suit, round_id: round.id, user_id: actual_player.id, quantity: new_dice_quantity)
                    next_player = search_next_alive_player(current_position, players)
                elsif probability.between?(8, 10)
                    #CONDICION DE DUDAR
                    action = false
                    success = false
                    actual_dice_quantity = actual_hand.dice_quantity
                    if check_dudo(last_turn.quantity, last_turn.suit_id, dices)
                        # puts "BIEN DUDADO"
                        success = true
                        previous_player_hand.update(dice_quantity: previous_player_hand.dice_quantity - 1)
                        next_player = previous_player
                    else
                        # puts "MAL DUDADO"
                        actual_hand.update(dice_quantity: actual_dice_quantity - 1)
                        next_player = actual_player
                    end
                    round.update(user_action_id: actual_player.id, success: success, action: action)
                    round_finished = true
                end
                # # puts "next_player: #{next_player.email}"
                if hands.where(user_id: next_player.id).first.dice_quantity <= 0 #Si un jugador se quedo sin dados
                    players.where(user_id: next_player.id).first.update(final_place: place)
                    place -= 1
                end
                if place <= 1 #Si solamente queda un jugador
                    players.where(user_id: actual_player.id).first.update(final_place: place)
                    game_finished = true
                    game.update(finished: true)
                end
            else
                Turn.create(suit_id: rand(1..6), round_id: round.id, user_id: actual_player.id, quantity: rand(1..actual_dice_quantity / 2))
                next_player = search_next_alive_player(current_position, players)
            end
            # # puts "next_player: #{next_player.email}"
            current_position = GameUser.where(game_id: game.id, user_id: next_player.id).first.position
        end
    end
end


