class AddStartableToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :startable, :boolean
  end
end
