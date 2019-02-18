class CreateMenus < Jennifer::Migration::Base
  def up
    create_table :menus do |t|
      t.string :name, { :null => false }

      t.timestamps
    end
  end

  def down
    drop_table :menus if table_exists? :menus
  end
end
