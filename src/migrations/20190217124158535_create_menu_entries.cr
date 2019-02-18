class CreateMenuEntries < Jennifer::Migration::Base
  def up
    create_table :menu_entries do |t|
      t.string :name, { :null => false }
      t.string :key, { :size => 1 }
      t.string :function, { :null => false }

      t.reference :menu_section

      t.timestamps
    end
  end

  def down
    drop_foreign_key :menu_entries, :menu_sections if foreign_key_exists? :menu_entries, :menu_sections
    drop_table :menu_entries if table_exists? :menu_entries
  end
end
