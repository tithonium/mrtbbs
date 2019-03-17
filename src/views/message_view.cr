module Views
  class MessageView < Base
    
    def message : ::Message
      self.session.current_message.as(::Message)
    end
    
    def board : ::MessageBoard
      message.message_board!.as(::MessageBoard)
    end
    
    def entries
      if @items.size > 0
        @items
      else
        @items = [
          heading("Message #{message.message_index} of #{board.last_message_index} on #{board.name}"),
          text("Subject: #{message.subject}"),
          text("By: #{message.author}"),
          heading(""),
          text(message.body),
          text(""),
          hidden_entry('!', "Halt System", "shutdown"),
          hidden_entry('N', "Next Unread Message", "read_next_unread_message"),
        ]
      end
    end
    
    def as_text(width = 79, col_count = 2) : String
      super(width, 1)
    end
    
    def as_ansi(width = 100, col_count = 3) : String
      String.build do |s|
        left_col = 5 + 1 + 5
        gutter = 2 + 3 + 2
        col_width = width - (left_col + gutter)
        main_width = width - 4

        s << Ansi.grey_fg << '\u250f'
        s << "\u2501" * (left_col + 2)
        s << '\u2533'
        s << "\u2501" * (col_width + 2)
        s << '\u2513' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
        s << "%5.5d/%-5.5d" % [message.message_index, board.last_message_index]
        s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.red_bg << Ansi.white_fg
        s << "%*s" % [-col_width, self.board.name] << Ansi.reset
        s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2523'
        s << "\u2501" * (left_col + 2)
        s << '\u253B'
        s << "\u2501" * (col_width + 2)
        s << '\u252B' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.dblue_bg << Ansi.white_fg
        s << "Subject: %*s" % [-(main_width - 9), self.message.subject] << Ansi.reset
        s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.dblue_bg << Ansi.white_fg
        s << "From: %*s" % [-(main_width - 6), self.message.author.to_s] << Ansi.reset
        s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2523'
        s << "\u2501" * (width - 2)
        s << '\u252B' << Ansi.reset << "\n"

        re = /(.{1,#{main_width-1}}\S)(?=\s)/
        self.message.body.split(/\n/).each do |line|
          if line.size > main_width
            pos = 0
            while (line.size - pos) > main_width
              if m = re.match(line, pos)
                x = m[1]
                pos += x.size
                s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.white_fg
                s << "%*s" % [-main_width, x.strip]
                s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"
              end
            end
            if pos < line.size
              s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.white_fg
              s << "%*s" % [-main_width, line[pos..-1].strip]
              s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"
            end
          else
            s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' << Ansi.white_fg
            s << "%*s" % [-main_width, line.strip]
            s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"
          end
        end

        # rows << "#{Ansi.blue_bg}#{Ansi.white_fg}#{" " * left_padding}#{row.name}#{" " * right_padding}#{Ansi.reset}"
        #
        # s << Ansi.grey_fg << '\u2517'
        # (0...cols.size).each do |idx|
        #   s << '\u253B' if idx > 0
        #   s << "\u2501" * (col_width + 2)
        # end
        # s << '\u251B' << Ansi.reset << "\n"
        
        
        if width < 86
          s << Ansi.grey_fg << '\u2523'
          s << "\u2501" * 8  << '\u2533'
          s << "\u2501" * 17 << '\u2533'
          s << "\u2501" * 15 << '\u2533'
          s << "\u2501" * 10 << '\u2533'
          s << "\u2501" * (width - 56) if width > 56
          s << '\u252B' << Ansi.reset << "\n"
          
          s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << Ansi.dblue_bg << Ansi.white_fg << "Board:" << Ansi.reset
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}P#{Ansi.red_fg} : #{Ansi.white_fg}Prev Msg#{Ansi.reset}   "
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}N#{Ansi.red_fg} : #{Ansi.white_fg}Next Msg#{Ansi.reset} "
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}L#{Ansi.red_fg} : #{Ansi.white_fg}List#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset
          s << (" " * (width - 56)) << Ansi.grey_fg << '\u2503' << Ansi.reset if width > 56
          s << "\n"
          s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << Ansi.dblue_bg << Ansi.white_fg << "Other:" << Ansi.reset
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}U#{Ansi.red_fg} : #{Ansi.white_fg}Next Unread#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}M#{Ansi.red_fg} : #{Ansi.white_fg}Main Menu#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "          " << Ansi.grey_fg << '\u2503' << Ansi.reset
          s << (" " * (width - 56)) << Ansi.grey_fg << '\u2503' << Ansi.reset if width > 56
          s << "\n"
          
          s << Ansi.grey_fg << '\u2517'
          s << "\u2501" * 8  << '\u253B'
          s << "\u2501" * 17 << '\u253B'
          s << "\u2501" * 15 << '\u253B'
          s << "\u2501" * 10 << '\u253B'
          s << "\u2501" * (width - 56) if width > 56
          s << '\u251B' << Ansi.reset << "\n"
        else
          s << Ansi.grey_fg << '\u2523'
          s << "\u2501" * 8  << '\u2533'
          s << "\u2501" * 10 << '\u2533'
          s << "\u2501" * 10 << '\u2533'
          s << "\u2501" * 10 << '\u2533'
          s << "\u2501" * (width - 87) << '\u2533' if width > 87
          s << "\u2501" * 8  << '\u2533'
          s << "\u2501" * 17 << '\u2533'
          s << "\u2501" * 15
          s << '\u252B' << Ansi.reset << "\n"
          
          s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << Ansi.dblue_bg << Ansi.white_fg << "Board:" << Ansi.reset
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}P#{Ansi.red_fg} : #{Ansi.white_fg}Prev#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}N#{Ansi.red_fg} : #{Ansi.white_fg}Next#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}L#{Ansi.red_fg} : #{Ansi.white_fg}List#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset
          s << (" " * (width - 87)) << Ansi.grey_fg << '\u2503' << Ansi.reset << ' ' if width > 87
          s << Ansi.dblue_bg << Ansi.white_fg << "Other:" << Ansi.reset
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}U#{Ansi.red_fg} : #{Ansi.white_fg}Next Unread#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << "#{Ansi.blue_fg}M#{Ansi.red_fg} : #{Ansi.white_fg}Main Menu#{Ansi.reset}"
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset
          s << "\n"
          
          s << Ansi.grey_fg << '\u2517'
          s << "\u2501" * 8  << '\u253B'
          s << "\u2501" * 10 << '\u253B'
          s << "\u2501" * 10 << '\u253B'
          s << "\u2501" * 10 << '\u253B'
          s << "\u2501" * (width - 87) << '\u253B' if width > 87
          s << "\u2501" * 8  << '\u253B'
          s << "\u2501" * 17 << '\u251B'
          s << "\u2501" * 15
          s << '\u251B' << Ansi.reset << "\n"
        end
        
      end
    end
    
  end
end
