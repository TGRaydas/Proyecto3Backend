class AddAcceptedToGameUser < ActiveRecord::Migration[5.2]
  def change
    add_column :game_users, :accepted, :boolean
  end
end
