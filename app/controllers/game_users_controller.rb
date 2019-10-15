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
    @game_user.accepted = false
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

  def update_game_request
    game_user = GameUser.find(params[:game_user_id])
    position = GameUser.where(game_id: game_user.game_id).where.not(position: nil).order(position: :desc).first
    if params[:status] == 1
      game_user.update(accepted: false)
    else
      game = Game.find(game_user.game_id)
      if !game.startable
        game.update(startable: true)
      end
      game_user.update(position: position.position + 1, accepted: true)
    end
    render json: game_user
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game_user
    @game_user = GameUser.find(params[:id])
  end

  def my_games
    @games = User.find(game_user_params[:user_id]).my_current_games
    render json: @games
  end

  def my_invitations
    user = User.find(params[:user_id])
    invitations = user.get_my_invitations
    render json: invitations
  end

  def create_invitation
    game = Game.find(params[:game])
    friend = User.find(params[:friend])
    user = User.find(params[:user_id])
    pos = GameUser.where(game_id: game).order(position: :desc).first
    game_user = GameUser.create(game_id: game.id, user_id: friend.id)
    client = Exponent::Push::Client.new   
    messages = [
      {to: friend.token, body:"Games invitation from " + user.profile.nickname}
    ]
    client.publish messages
    render json: game_user
  end

  # Only allow a trusted parameter "white list" through.


  def accept_game
    @invitation = GameUser.where(game_id: game_user_params[:game_id], user_id: game_user_params[:user_id])
    last_user = GameUser.where(game_id: game_user_params[:game_id]).where.not(position: nil).order(position: :desc).first
    if invitation.update(accepted: true, position:last_user[:position] + 1)
      game = Game.find(game_user_params[:game_id])
      if !game.startable
        game.update(startable: true)
      end
      render json: @invitation
    else
      render json: @invitation.errors, status: :unprocessable_entity
    end
  end

  private
  def game_user_params
    params.permit(:user_id, :game_id)
  end

end
