class CreateMessages < Jennifer::Migration::Base
  def up
    create_table :messages do |t|
      t.integer :message_index, { :null => false }
      t.string :subject, { :null => false }
      t.text :body, { :null => false }

      # t.reference :message_board # doesn't support not-null
      # t.reference :author, :users

      t.integer :message_board_id, { :type => :integer, :null => false }
      t.foreign_key :message_boards, :message_board_id
      t.integer :author_id, { :type => :integer, :null => false }
      t.foreign_key :users, :author_id

      t.timestamps
    end
  end

  def down
    drop_foreign_key :messages, :message_boards if foreign_key_exists? :messages, :message_boards
    drop_foreign_key :messages, :authors if foreign_key_exists? :messages, :authors
    drop_table :messages if table_exists? :messages
  end
end
