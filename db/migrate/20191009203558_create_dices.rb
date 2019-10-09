class CreateDices < ActiveRecord::Migration[5.2]
  def change
    create_table :dices do |t|
      t.references :hand, foreign_key: true
      t.references :suit, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
