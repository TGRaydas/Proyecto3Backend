class SuitsController < ApplicationController
  before_action :set_suit, only: [:show, :update, :destroy]

  # GET /suits
  def index
    @suits = Suit.all

    render json: @suits
  end

  # GET /suits/1
  def show
    render json: @suit
  end

  # POST /suits
  def create
    @suit = Suit.new(suit_params)

    if @suit.save
      render json: @suit, status: :created, location: @suit
    else
      render json: @suit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /suits/1
  def update
    if @suit.update(suit_params)
      render json: @suit
    else
      render json: @suit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /suits/1
  def destroy
    @suit.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_suit
      @suit = Suit.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def suit_params
      params.require(:suit).permit(:name)
    end
end
