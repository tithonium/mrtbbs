module Menus
  class MessageView < Base
    
    getter message : ::Message
    getter board : ::MessageBoard
    def initialize(@message : ::Message)
      @board = @message.message_board!
      STDERR.puts @message.inspect
      STDERR.puts @board.inspect
    end
    
    def entries
      [
        heading("[#{board.name}]"),
        text(""),
        text(message.subject),
        heading(""),
        text(message.body),
        text(""),
        entry('!', "Halt System", "shutdown"),
        entry('N', "Next Unread Message", "read_next_unread_message"),
      ]
    end

    def as_text(width = 79) : String
      "oops"
    end

    def as_ansi(width = 100, col_count = nil) : String
      String.build do |s|
        left_col = 5
        gutter = 2 + 3 + 2
        col_width = width - (left_col + gutter)
        main_width = width - 4

        s << Ansi.grey_fg << '\u250f'
        s << "\u2501" * (left_col + 2)
        s << '\u2533'
        s << "\u2501" * (col_width + 2)
        s << '\u2513' << Ansi.reset << "\n"

        s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
        s << "%5.5d" % self.message.message_index
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
        STDERR.puts re.inspect
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

        s << Ansi.grey_fg << '\u2517'
        s << "\u2501" * (width - 2)
        s << '\u251B' << Ansi.reset << "\n"
      end
    end
    
  end
end
