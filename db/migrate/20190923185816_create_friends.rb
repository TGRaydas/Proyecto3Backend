class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.references :user_sender
      t.references :user_receiver
      t.integer :state
      t.timestamps
    end
    add_foreign_key :friends, :users, column: :user_sender_id, primary_key: :id
    add_foreign_key :friends, :users, column: :user_receiver_id, primary_key: :id
  end
end
