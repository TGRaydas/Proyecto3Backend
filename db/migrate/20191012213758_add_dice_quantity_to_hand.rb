class AddDiceQuantityToHand < ActiveRecord::Migration[5.2]
  def change
    add_column :hands, :dice_quantity, :integer
  end
end
