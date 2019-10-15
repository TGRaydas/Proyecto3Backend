class GamesController < ApplicationController
    before_action :set_game, only: [:show, :update, :destroy, :give_options, :check_calzo, :check_dudo, :is_my_turn, :start_round, :end_round, :current_dices]
    before_action :set_game_user, only: [:give_options, :end_round]
    before_action :set_actual_round, only: [:give_options, :check_calzo, :check_dudo, :end_round, :end_turn]

    # GET /games
    def index
        @games = Game.all
        render json: @games
    end

    # GET /games/1
    def show
        render json: @game
    end

    def start_game
        game = Game.find(params[:game_id])
        round = Round.create(game_id: game.id)
        users = GameUser.where(game_id: game.id)
        users.each do |user|
            hand = Hand.create(round_id: round.id, user_id: user.user_id, dice_quantity: 5)
            (0..4).each do |i|
                Dice.create(hand_id: hand.id, suit_id: Suit.all.sample.id)
            end
            client = Exponent::Push::Client.new
            messages = [
                {to: User.find(user.user_id).token, body: "Game started: " + game.name}
            ]
            client.publish messages
        end
        render json: {started: true}
    end


    def end_turn
        quantity = params[:quantity]
        suit_id = params[:suit_id]
        user_id = params[:user_id]
        Turn.create(suit_id: suit_id, quantity:quantity, user_id:user_id, round_id: @round.id)
        next_user_id = @game.next_player.id
        @game.notify_next_turn(next_user_id)
    end


    def end_round
        action = params[:action]
        user_action_id = params[:user_id]
        looked_quantity = params[:looked_quantity]
        looked_suit = params[:looked_suit]
        if action
            if @game.check_calzo(looked_suit, looked_quantity)
                @round.update(user_action_id: user_action_id, action: action, success: true)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, 1)
            else
                @round.update(user_action_id: user_action_id, action: action, success: false)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, -1)

            end
        else
            if @game.check_dudo(looked_suit, looked_quantity)
                @round.update(user_action_id: user_action_id, action: action, success: true)
                actual_player_position = GameUser.where(game_id: @game.id, user_id: user_action_id).first.position
                to_remove_dice_player = @game.search_previous_alive_player(actual_player_position)
                @game.change_dice_quantity_from_hand(@round.id, to_remove_dice_player.id, -1)
            else
                @round.update(user_action_id: user_action_id, action: action, success: true)
                @game.change_dice_quantity_from_hand(@round.id, user_action_id, -1)
            end
        end
        if @game.alive_players.length <= 1
            @game.update(finished: true)
        else
            @game.start_round

        end

    end

    # POST /games
    def create
        @game = Game.new(name: params[:name], finished: false, startable: false)
        rules = params[:rules]
        if @game.save
            rules.each do |r|
                GameRule.create(game_id: @game.id, rule_id: r[:id])
            end
            GameUser.create(user_id: params[:user_id], game_id: @game.id, position: 1, final_place: nil)
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
        next_player = @game.next_player
        usuario = params[:user_id]
        if params[:user_id].to_i == next_player.id
            render json: {status: true, message: "Is your turn"}
        else
            render json: {status: false, message: "Is not your turn"}
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
        if @previous_turn != nil
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
