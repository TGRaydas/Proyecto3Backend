class GamesController < ApplicationController
    before_action :set_game, only: [:show, :update, :destroy, :give_options, :check_calzo, :check_dudo, :is_my_turn,
                                    :start_round, :end_round, :current_dices, :end_turn, :chat]
    before_action :set_game_user, only: [:give_options, :end_round]
    before_action :set_actual_round, only: [:give_options, :check_calzo, :check_dudo, :end_round, :end_turn]
    before_action :set_previous_turn, only: [:give_options]
    # GET /games
    def index
        @games = Game.all
        render json: @games
    end

    # GET /games/1
    def show
        render json: @game
    end

    def chat
        final_obj = {status: true, items:[]}
        @game.round.order(created_at: :asc).each do |round|
            nickname = nil
            action = nil
            success = nil
            if !round.user_action_id.nil?
                nickname = Profile.where(user_id: round.user_action_id).first.nickname
                if round.action
                    action = "Calzo"
                else
                    action = "Dudo"
                end
                success = round.success
            end
            turns = []
            round.turns.order(created_at: :asc).each do |t|
                turns.push(suit_id: Suit.find(t.suit_id).name, quantity: t.quantity, nickname:Profile.where(user_id: t.user_id).first.nickname)
            end
            final_obj[:items].push(nickname:nickname, action:action, success:success, turns:turns)
        end
        render json: final_obj
    end

    def start_game
        game = Game.find(params[:game_id])
        round = Round.create(game_id: game.id)
        users = GameUser.where(game_id: game.id).where.not(position: nil)
        users.each do |user|
            hand = Hand.create(round_id: round.id, user_id: user.user_id, dice_quantity: 5)
            (0..4).each do |i|
                Dice.create(hand_id: hand.id, suit_id: Suit.all.sample.id)
            end
            begin
                client = Exponent::Push::Client.new
                messages = [
                    {to: User.find(user.user_id).token, body: "Game started: " + game.name}
                ]
                client.publish messages
            rescue
            end
        end
        render json: {started: true}
    end


    def end_turn
        quantity = params[:quantity]
        suit_id = params[:suit_id]
        user_id = params[:user_id]
        Turn.create(suit_id: suit_id, quantity: quantity, user_id: user_id, round_id: @round.id)
        next_user_id = @game.next_player_turn_notification.id
        puts "Siguiente jugador: #{User.find(next_user_id).email}"
        @game.notify_next_turn(next_user_id)
    end


    def end_round
        puts "Entro a terminar la ronda"
        action = params[:action_id]
        puts "Accion #{action}"
        user_action_id = params[:user_id]
        looked_quantity = params[:looked_quantity]
        looked_suit = params[:looked_suit].to_i
        status = nil
        message = nil
        if action == "calzo"
            puts "entrando al calzo"
            puts "accion", action, "fin accion"
            if @game.check_calzo(looked_suit, looked_quantity)
                @round.update(user_action_id: user_action_id, action: true, success: true)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, 1)
                status = true
                message = "Bien Calzado"
                puts "1"
            else
                @round.update(user_action_id: user_action_id, action: true, success: false)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, -1)
                status = false
                message = "Fallaste"
                puts "2"
            end
        elsif action == "dudo"
            puts "Entre al dudo controlador"
            if @game.check_dudo(looked_suit, looked_quantity)
                puts "BIEN DUDADO"
                @round.update(user_action_id: user_action_id, action: false, success: true)
                actual_player_position = GameUser.where(game_id: @game.id, user_id: user_action_id).first.position
                to_remove_dice_player = @game.search_previous_alive_player(actual_player_position)
                @game.change_dice_quantity_from_hand(@round.id, to_remove_dice_player.id, -1)
                status = true
                message = "Bien dudado"

            else
                puts "MAL DUDADO"
                @round.update(user_action_id: user_action_id, action: false, success: false)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, -1)
                status = false
                message = "Fallaste"

            end
        end
        @game.set_final_positions
        if @game.alive_players.length <= 1
            @game.update(finished: true)
        else
            @game.start_round
        end
        render json: {status: status, message: message}
    end

    # POST /games
    def create
        @game = Game.new(name: params[:name], finished: false, startable: false)
        rules = params[:rules]
        if @game.save
            rules.each do |r|
                GameRule.create(game_id: @game.id, rule_id: r[:id])
            end
            GameUser.create(user_id: params[:user_id], game_id: @game.id, position: 1, final_place: nil, accepted: true)
            render json: @game, status: :created, location: @game
        else
            render json: @game.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /games/1
    def update
        if @game.update(game_params)
            render json: @game
        else
            render json: @game.errors, status: :unprocessable_entity
        end
    end

    def is_my_turn
        rounds = @game.round.order(created_at: :desc)
        next_player = nil
        if rounds.length == 1 #Si el juego está en la primera ronda
            if rounds.first.turns.length == 0 #Si estoy en la primera ronda y primer turno
                next_player = @game.next_player_starting_game
            else
                next_player = @game.next_player_turn_notification
            end
        else
            if rounds.first.turns.length == 0 #Si estoy en la ronda 2 o mas y primer turno
                next_player = @game.next_player_second_round_start_notification
            else
                next_player = @game.next_player_turn_notification
            end
        end
        usuario = params[:user_id]
        finished_for_user = @game.game_finished_for_user(params[:user_id])
        last_position = nil
        if finished_for_user
            last_position = GameUser.where(game_id: game_id, user_id: params[:user_id]).first.final_place
        end
        if params[:user_id].to_i == next_player.id
            render json: {status: true, message: "Is your turn", final_place: last_position, finished_for_user: finished_for_user, game_finished: @game.finished}
        else
            render json: {status: false, message: "Is not your turn", final_place: last_position, finished_for_user: finished_for_user, game_finished: @game.finished}
        end
    end

    def started_game
        game_user_owner = GameUser.where(user_id: params[:user_id], position: 1, game_id: params[:game_id]).first
        game = Game.find(params[:game_id])
        round = Round.where(game_id: game.id).first
        if game_user_owner.nil? #Si no soy el dueño
            if round.nil?
                render json: {owner: false, started: false} #Si no ha empezazo
            else
                render json: {owner: false, started: true}
            end
        else
            if round.nil?
                render json: {owner: true, started: false, startable: game.startable} #Si no ha empezazo
            else
                render json: {owner: true, started: true}
            end
        end
    end

    # DELETE /games/1
    def destroy
        @game.destroy
    end

    #params: user_id
    def give_options
        increment_suit = false
        increment_quantity = true
        decrement_suit = false
        calzo = false
        dudo = false
        lower_limit_quantity = nil
        previous_suit = nil
        if !@previous_turn.nil?
            lower_limit_quantity = @previous_turn.quantity
            previous_suit = @previous_turn.suit_id
            if @previous_turn.suit_id >= 2
                decrement_suit = true
            end
            if @previous_turn.suit_id <= 5
                increment_suit = true
            end
            calzo = true
            dudo = true
        else
            increment_suit = true
            decrement_suit = true
        end
        render json: {increment_suit: increment_suit,
                      increment_quantity: increment_quantity,
                      lower_limit_quantity: lower_limit_quantity,
                      previous_suit: previous_suit,
                      decrement_suit: decrement_suit,
                      calzo: calzo,
                      dudo: dudo}
    end

    def current_dices
        render json: {quantity: @game.current_dices.values.inject {|a, b| a + b}}
    end


    private

    # Use callbacks to share common setup or constraints between actions.
    def set_game
        @game = Game.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_params
        params.require(:game).permit(:name, :user_id)
    end

    def set_game_user
        @game_user = GameUser.where(game_id: @game.id, user_id: params[:user_id])
    end

    def set_actual_round
        @round = Round.where(game_id: @game.id).order(created_at: :desc).first
    end

    def set_previous_turn
        @previous_turn = Turn.where(round_id: @round.id).order(created_at: :desc).first
    end


end
