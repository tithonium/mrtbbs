module Views
  class MessageBoard < Base
    
    def board : ::MessageBoard
      self.session.current_board.as(::MessageBoard)
    end
    
    def entries
      if @items.size > 0
        @items
      else
        @items += [
          heading("[#{board.name}]"),
          entry('N', "Next Unread Message", "read_next_unread_message"),
          entry('P', "Post a Message", ""),
          entry('*', "List Message Boards", "messages_list_boards"),
          
          heading("Miscellaneous"),
          entry('M', "Main Menu", "main_menu"),
          entry('O', "Log Off", "logout"),
          entry('U', "User List", "list_users"),
        ]
      end
    end
    
  end
end
