class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy, :give_options]
  before_action :set_game_user, only: [:give_options]
  before_action :set_actual_round, only: [:give_options]

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
      hand = Hand.create(round_id: round.id, user_id: user.user_id)
      (0..4).each do |i|
        Dice.create(hand_id: hand.id, suit_id: Suit.all.sample.id)
      end
      client = Exponent::Push::Client.new
        messages = [
            {to: User.find(user.user_id).token, body: "Game started: " + game.name}
        ]
        client.publish messages
    end
    render json:{started: true}
  end

  # POST /games
  def create
    @game = Game.new(name:params[:name], finished:false, startable: false)
    rules = params[:rules]
    if @game.save
      rules.each do |r|
        GameRule.create(game_id:@game.id, rule_id:r[:id])
      end
      GameUser.create(user_id: params[:user_id], game_id:@game.id, position: 1, final_place:nil)
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

  def started_game
    game_user_owner = GameUser.where(user_id: params[:user_id], position: 1, game_id: params[:game_id]).first
    game = Game.find(params[:game_id])
    round = Round.where(game_id: game.id).first
    if game_user_owner.nil?  #Si no soy el dueño
      if round.nil?
        render json:{owner: false, started:false} #Si no ha empezazo
      else
        render json: {owner: false, started: true}
      end
    else
        if round.nil?
            render json:{owner: true, started:false, startable: game.startable} #Si no ha empezazo
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
    if @previous_turn != nil
      if @previous_turn.suit_id >= 2
        decrement_suit = true
      end
      if @previous_turn.suit_id <= 5
        increment_suit = true
      end
      calzo = true
      dudo = true
    end
    render json: {increment_suit: increment_suit, increment_quantity:increment_quantity}
  end

  def check_calzo(looked_quantity, looked_suit, dices)
    suits = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
    puts "suits 1: #{suits}"
    puts "suits[1]: #{suits[1]}"
    dices.each do |d|
      suits[d.suit.id] += 1
    end
    puts "suits 2: #{suits}"
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
      @game_user = GameUser.where(game_id: @game.id, user_id:params[:user_id])
    end

    def set_actual_round
      @round = Round.where(game_id: @game.id).order(created_at: :desc).first
    end

    def set_previous_turn
      @previous_turn = Turn.where(round_id: @round.id).order(created_at: :desc).first
    end
end
