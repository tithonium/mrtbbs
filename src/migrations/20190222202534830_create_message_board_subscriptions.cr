class CreateMessageBoardSubscriptions < Jennifer::Migration::Base
  def up
    create_table :message_board_subscriptions do |t|
      t.integer :last_read_index, { :null => false }

      # t.reference :message_board
      # t.reference :user

      t.integer :message_board_id, { :type => :integer, :null => false }
      t.foreign_key :message_boards, :message_board_id
      t.integer :user_id, { :type => :integer, :null => false }
      t.foreign_key :users, :user_id

      t.timestamps
    end
  end

  def down
    drop_foreign_key :message_board_subscriptions, :message_boards if foreign_key_exists? :message_board_subscriptions, :message_boards
    drop_foreign_key :message_board_subscriptions, :users if foreign_key_exists? :message_board_subscriptions, :users
    drop_table :message_board_subscriptions if table_exists? :message_board_subscriptions
  end
end
