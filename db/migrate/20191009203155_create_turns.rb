class CreateTurns < ActiveRecord::Migration[5.2]
  def change
    create_table :turns do |t|
      t.references :suit, foreign_key: true
      t.references :rule, foreign_key: true
      t.references :round, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
