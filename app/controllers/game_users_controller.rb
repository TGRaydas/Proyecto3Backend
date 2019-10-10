class GameUsersController < ApplicationController
  before_action :set_game_user, only: [:show, :update, :destroy]

  # GET /game_users
  def index
    @game_users = GameUser.all

    render json: @game_users
  end

  # GET /game_users/1
  def show
    render json: @game_user
  end

  # POST /game_users
  def create
    @game_user = GameUser.new(game_user_params)

    if @game_user.save
      render json: @game_user, status: :created, location: @game_user
    else
      render json: @game_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /game_users/1
  def update
    if @game_user.update(game_user_params)
      render json: @game_user
    else
      render json: @game_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /game_users/1
  def destroy
    @game_user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_user
      @game_user = GameUser.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_user_params
      params.require(:game_user).permit(:user_id, :game_id, :position, :final_place)
    end
end
