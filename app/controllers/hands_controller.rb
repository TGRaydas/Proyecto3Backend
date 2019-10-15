class HandsController < ApplicationController
  before_action :set_hand, only: [:show, :update, :destroy]

  # GET /hands
  def index
    @hands = Hand.all

    render json: @hands
  end

  # GET /hands/1
  def show
    render json: @hand
  end

  def my_hand
    user = User.find(params[:user_id])
    dices = user.get_last_hand_on_game(params[:game_id])
    render json: dices
  end

  # POST /hands
  def create
    @hand = Hand.new(hand_params)

    if @hand.save
      render json: @hand, status: :created, location: @hand
    else
      render json: @hand.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /hands/1
  def update
    if @hand.update(hand_params)
      render json: @hand
    else
      render json: @hand.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hands/1
  def destroy
    @hand.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hand
      @hand = Hand.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def hand_params
      params.require(:hand).permit(:user_id, :round_id)
    end
end
