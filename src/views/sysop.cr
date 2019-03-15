module Views
  class Sysop < Base
    
    def entries : Array(Row)
      if current_level < User::Levels::Admin
        [] of Row
      elsif @items.size > 0
        @items
      else
        @items += [
          heading("Sysop Functions"),
          entry('U', "User List", "list_users"),
          entry('@', "Session List", "list_sessions"),
          # entry('X', "System Configuration", ""),
          # entry('Z', "Info and Stats", ""),
          # entry('E', "User Editor", ""),
        ]
        @items << entry('!', "Halt System", "shutdown") if current_level >= User::Levels::Super
        @items << entry('M', "Main Menu", "main_menu")
        @items
      end
    end
    
  end
end
