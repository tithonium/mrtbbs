module Views
  class Root < Base
    
    def entries : Array(Row)
      if @items.size > 0
        @items
      else
        @items += [
          heading("Message Boards"),
          entry('N', "Next Unread Message", "read_next_unread_message"),
          # entry('N', "New Messages, All Subs", ""),
          # entry('P', "Post a Message", ""),
          # entry('S', "Scan Current Msg Base", ""),
          # entry('#', "Enter NUmber of Sub", ""),
          entry('*', "List Message Boards", "messages_list_boards"),
          # entry(']', "Advance 1 Sub", ""),
          # entry('[', "Retreat 1 Sub", ""),
          # entry('>', "Advance 1 Conference", ""),
          # entry('<', "Retreat 1 Conference", ""),
          # entry('H', "Hop to Another Sub", ""),
          
          heading("Miscellaneous"),
          # entry('B', "BBS List", "bbs_list"),
          # entry('I', "System Information", ""),
          # entry('L', "Last Caller List", ""),
          entry('O', "Log Off", "logout"),
          entry('U', "User List", "list_users"),
          # entry('V', "Voting Booth", ""),
          # entry('Y', "Your Information", ""),
          
          # heading("System Features"),
          # entry('T', "Transfer Section", ""),
          # entry('G', "Read General Files", ""),
          # entry('M', "Message of the Day", ""),
        ]
        if current_level >= User::Levels::Admin
          @items += [
            heading("Sysop Functions"),
            entry('$', "Sysop Menu", "mode_sysop"),
            # entry('X', "System Configuration", ""),
            # entry('Z', "Info and Stats", ""),
            # entry('E', "User Editor", ""),
            entry('@', "Session List", "list_sessions"),
          ]
          @items << entry('!', "Halt System", "shutdown") if current_level >= User::Levels::Super
        end
        @items
      end
    end
    
  end
end
