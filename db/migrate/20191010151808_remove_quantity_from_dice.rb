class RemoveQuantityFromDice < ActiveRecord::Migration[5.2]
  def change
    remove_column :dices, :quantity, :integer
  end
end
