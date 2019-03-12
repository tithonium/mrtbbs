class CreateMessageBoards < Jennifer::Migration::Base
  def up
    create_table :message_boards do |t|
      t.string  :name,               { :null => false }
      t.integer :last_message_index, { :null => false, :default => 0 }
      t.bool    :public,             { :null => false, :default => true }
      t.short   :required_level,     { :null => true, :default => nil }

      t.timestamps
    end
  end

  def down
    drop_table :message_boards if table_exists? :message_boards
  end
end
