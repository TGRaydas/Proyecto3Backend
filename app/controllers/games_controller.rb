class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy]

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
    @game = Game.new(name:params[:name])
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
    game = GameUser.where(user_id: params[:user_id], position: 1, game_id: params[:game_id]).first
    if game.nil?
      render json:{status: false}
    else
      round = Round.where(game_id: game.game_id).first
      if round.nil?
        render json:{status: false}
      else
        render json:{status: true}
      end
    end
  end
  # DELETE /games/1
  def destroy
    @game.destroy
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
end
