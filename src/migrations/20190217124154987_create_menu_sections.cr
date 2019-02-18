class CreateMenuSections < Jennifer::Migration::Base
  def up
    create_table :menu_sections do |t|
      t.string :name, { :null => false }

      t.reference :menu

      t.timestamps
    end
  end

  def down
    drop_foreign_key :menu_sections, :menus if foreign_key_exists? :menu_sections, :menus
    drop_table :menu_sections if table_exists? :menu_sections
  end
end
