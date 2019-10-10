class CreateGameRules < ActiveRecord::Migration[5.2]
  def change
    create_table :game_rules do |t|
      t.references :game, foreign_key: true
      t.references :rule, foreign_key: true

      t.timestamps
    end
  end
end
