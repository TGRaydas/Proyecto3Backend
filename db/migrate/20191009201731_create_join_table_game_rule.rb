class CreateJoinTableGameRule < ActiveRecord::Migration[5.2]
  def change
    create_join_table :games, :rules do |t|
      t.index :game_id
      t.index :rule_id
    end
  end
end
