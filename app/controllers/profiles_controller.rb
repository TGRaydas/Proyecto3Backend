class ProfilesController < ApplicationController
    before_action :set_profile, only: [:show, :update, :destroy]
    before_action :set_user, only: [:total_games, :games_winned, :average_final_position]

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

    def games_winned
        @games_winned = @user.games_winned
        render json: @games_winned
    end

    def total_games
        @games = @user.total_games
        render json: @games
    end

    def statistics
        games = @user.total_games
        games_winned = @games.where(final_position: 1)
        average_position = games.average("final_position")

        last_hands = []
        sum = 0
        games_winned.each do |gw|
            final_round = Round.where(game_id: gw.game_id).order(created_at: :desc).first
            final_hands = Hand.where(round_id: final_round.id, user_id: @user.id)
            sum += final_hands.length
            final_hands.each do |h|
                dices = Dice.where(hand_id: h.id)
                last_hands.push(game: gw.game_id, dices: dices)
            end
        end
        final_dice_prom = sum / last_hands.length

        turns = Turn.where(user_id: @user.id)
        plays = turns.group(:suit_id, :quantity).count
        most_played = []
        if plays.length > 0
            if plays >= 5
                range = (1...5)
            end
        else
            range = (1...plays.length)
            range.each do |i|
                top = plays.max_by {|k, v| v}
                suit = Suit.find(top[0][1]).name
                most_played.push(suit: suit, quantity: top[0][0])
                plays.delete(top[0])
            end
        end

        player_special_turns = Turn.where(user_id: @user.id).where.not(rule_id: nil)
        player_average_special = player_special_turns / games

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
