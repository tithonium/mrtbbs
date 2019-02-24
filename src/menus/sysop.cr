module Menus
  class Sysop < Base
    
    def entries : Array(Heading | Entry)
      [
        heading("Sysop Functions"),
        entry('U', "User List", "list_users"),
        entry('@', "Session List", "list_sessions"),
        # entry('X', "System Configuration", ""),
        # entry('Z', "Info and Stats", ""),
        # entry('E', "User Editor", ""),
        entry('!', "Halt System", "shutdown"),
        entry('[', "Main Menu", "main_menu"),
      ]
    end
    
  end
end
