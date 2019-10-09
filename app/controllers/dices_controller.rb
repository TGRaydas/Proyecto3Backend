class DicesController < ApplicationController
  before_action :set_dice, only: [:show, :update, :destroy]

  # GET /dices
  def index
    @dices = Dice.all

    render json: @dices
  end

  # GET /dices/1
  def show
    render json: @dice
  end

  # POST /dices
  def create
    @dice = Dice.new(dice_params)

    if @dice.save
      render json: @dice, status: :created, location: @dice
    else
      render json: @dice.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dices/1
  def update
    if @dice.update(dice_params)
      render json: @dice
    else
      render json: @dice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dices/1
  def destroy
    @dice.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dice
      @dice = Dice.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dice_params
      params.require(:dice).permit(:hand_id, :suit_id, :quantity)
    end
end
