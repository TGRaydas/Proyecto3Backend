class AddDescriptionToRule < ActiveRecord::Migration[5.2]
  def change
    add_column :rules, :description, :text
  end
end
