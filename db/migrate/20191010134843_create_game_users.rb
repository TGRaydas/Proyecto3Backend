class CreateGameUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :game_users do |t|
      t.references :user, foreign_key: true
      t.references :game, foreign_key: true
      t.integer :position
      t.integer :final_place

      t.timestamps
    end
  end
end
