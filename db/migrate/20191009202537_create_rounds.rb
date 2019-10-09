class CreateRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :rounds do |t|
      t.references :game, foreign_key: true
      t.references :user_action
      t.boolean :action
      t.boolean :success

      t.timestamps
    end
    add_foreign_key :rounds, :users, column: :user_action_id, primary_key: :id
  end
end
