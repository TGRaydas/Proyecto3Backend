class ProfilesController < ApplicationController
    before_action :set_profile, only: [:show, :update, :destroy]
    before_action :set_user, only: [:total_games, :games_winned, :average_final_position, :statistics]

    # GET /profiles
    def index
        @profiles = Profile.all
        render json: @profiles
    end

    # GET /profiles/1
    def show
        render json: @profile
    end

    # POST /profiles
    def create
        @profile = Profile.new(profile_params)

        if @profile.save
            render json: @profile, status: :created, location: @profile
        else
            render json: @profile.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /profiles/1
    def update
        if @profile.update(profile_params)
            render json: @profile
        else
            render json: @profile.errors, status: :unprocessable_entity
        end
    end

    # DELETE /profiles/1
    def destroy
        @profile.destroy
    end

    def statistics
        begin
            user = User.find(params[:user_id])
            total_games = user.total_games
            won_games = user.won_games
            percentage_won_games = user.percentage_won_games
            average_final_position = user.average_final_position
            most_frequent_play = user.most_frequent_play
            percentage_correct_dudos = user.percentage_correct_dudos
            percentage_correct_calzos = user.percentage_correct_calzos
            average_final_dices_won_games = user.average_final_dices_won_games
            percentage_special_moves = user.percentage_special_moves
            render json: {
                state: "success",
                total_games: total_games.length,
                won_games: won_games.length,
                percentage_won_games: percentage_won_games,
                average_final_position: average_final_position,
                most_frequent_play: most_frequent_play,
                percentage_correct_dudos: percentage_correct_dudos,
                percentage_correct_calzos: percentage_correct_calzos,
                average_final_dices_won_games: average_final_dices_won_games,
                percentage_special_moves: percentage_special_moves
            }
        rescue
            render json: {
                state: "error",
		total_games: "-",
                won_games: "-",
                percentage_won_games: "-",
                average_final_position: "-",
                most_frequent_play: {quantity: "-", suit: "multiple", frequency: "0"},
                percentage_correct_dudos: "-",
                percentage_correct_calzos: "-",
                average_final_dices_won_games: "-",
                percentage_special_moves: "-"
            }
        end
    end


    private

    # Use callbacks to share common setup or constraints between actions.
    def set_profile
        @profile = Profile.find(params[:id])
    end

    def set_user
        @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def profile_params
        params.fetch(:profile, {})
    end

end
