class CreateUsers < Jennifer::Migration::Base
  def up
    create_table :users do |t|
      t.string :username, { :null => false }
      t.string :name, { :null => false }
      t.string :password_digest, { :null => false }
      t.short :level, { :null => false, :default => 1 }

      t.timestamps
    end
  end

  def down
    drop_table :users if table_exists? :users
  end
end
