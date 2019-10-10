class GameRulesController < ApplicationController
  before_action :set_game_rule, only: [:show, :update, :destroy]

  # GET /game_rules
  def index
    @game_rules = GameRule.all

    render json: @game_rules
  end

  # GET /game_rules/1
  def show
    render json: @game_rule
  end

  # POST /game_rules
  def create
    @game_rule = GameRule.new(game_rule_params)

    if @game_rule.save
      render json: @game_rule, status: :created, location: @game_rule
    else
      render json: @game_rule.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /game_rules/1
  def update
    if @game_rule.update(game_rule_params)
      render json: @game_rule
    else
      render json: @game_rule.errors, status: :unprocessable_entity
    end
  end

  # DELETE /game_rules/1
  def destroy
    @game_rule.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_rule
      @game_rule = GameRule.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_rule_params
      params.require(:game_rule).permit(:game_id, :rule_id)
    end
end
