module Views
  abstract class Base
    
    record Heading, name : String
    macro heading(name)
      Heading.new(name: {{name}})
    end
    
    record Entry, name : String, key : Char?, function : String, hidden : Bool
    macro entry(key, name, function)
      Entry.new(key: {{key}}, name: {{name}}, function: {{function}}, hidden: false)
    end
    
    macro hidden_entry(key, name, function)
      Entry.new(key: {{key}}, name: {{name}}, function: {{function}}, hidden: true)
    end

    record Text, name : String
    macro text(name)
      Text.new(name: {{name}})
    end
    
    alias Row = Heading | Entry | Text
    
    @items : Array(Row)
    getter session : ::Session
    def initialize(@session : ::Session)
      @items = [] of Row
    end

    abstract def entries : Array(Row)
    
    def keys : Array(Char)
      entries.map {|row| row.key if row.is_a?(Entry) }.compact
    end
    
    def current_level
      session.current_user.level
    end
    
    def sections : Array(Array(Row))
      result = [] of Array(Row)
      self.entries.each do |row|
        result << [] of Row if row.is_a?(Heading)
        result[-1] << row unless row.is_a?(Entry) && row.hidden
      end
      result
    end
    
    def match_key(option : Char?) : Entry?
      return nil if option.nil?
      self.entries.each do |entry|
        return entry if entry.is_a?(Entry) && entry.key && entry.key == option
      end
      option = if option.uppercase?
        option.downcase
      else
        option.upcase
      end
      self.entries.each do |entry|
        return entry if entry.is_a?(Entry) && entry.key && entry.key == option
      end
    end
    
    def execute_function(name : String) : Bool
      false
    end
    
    private def text_mode_columns(col_count = 3) : Array(Array(Array(Row)))
      menu_sections = self.sections
      
      if menu_sections.size <= col_count
        return menu_sections.map{|e| [e] }
      end
      
      cols = [] of Array(Array(Row))
      col_count.times {
        cols << [] of Array(Row)
      }

      total_length = menu_sections.map(&.size).sum
      goal_size = total_length / col_count
      idx = menu_sections.size - 1
      colidx = col_count - 1

      while idx >= 0 && colidx > 0
        cols[colidx].unshift menu_sections[idx]
        idx -= 1
        if idx >= 0 && (cols[colidx].map(&.size).sum + menu_sections[idx].size) > goal_size
          colidx -= 1
        end
      end
      while idx >= 0
        cols[0].unshift menu_sections[idx]
        idx -= 1
      end
      
      while cols.last.empty?
        cols.pop
      end
      
      cols
    end
    
    def as_text(width = 79, col_count = 2) : String
      cols = self.text_mode_columns(col_count)
      col_count = cols.size
      
      gutter_width = ((col_count - 1) * 2)
      col_width = [(width - gutter_width) / col_count, 50].min
      
      cols = cols.map do |col|
        rows = [] of String
        col.each do |section|
          section.each do |row|
            case row
            when Heading
              padding = col_width - row.name.size
              left_padding = padding / 2
              right_padding = padding - left_padding
              rows << "#{"=" * (left_padding - 1)} #{row.name} #{"=" * (right_padding - 1)}"
            when Entry
              if row.key
                rows << "#{row.key} : #{row.name}"
              else
                rows << "    #{row.name}"
              end
            end
          end
          rows << ""
        end
        rows.pop
        rows
      end
      # puts cols.inspect
      
      max_rows = cols.map(&.size).max
      
      String.build do |s|
        # s << '+'
        # (0...cols.size).each do |idx|
        #   s << '+' if idx > 0
        #   s << "-" * (col_width + 2)
        # end
        # s << '+' << "\n"
      
        (0...max_rows).each do |idx|
          col0 = cols[0].size > idx ? cols[0][idx] : ""

          # s << '|' << ' '

          s << col0
          s << " " * (col_width - col0.size) unless col_width < col0.size

          if cols.size > 1
            col1 = cols[1].size > idx ? cols[1][idx] : ""
            # s << ' ' << '|' << ' '
            s << "  "
            s << col1
            s << " " * (col_width - col1.size) unless col_width < col1.size
          end

          if cols.size > 2
            col2 = cols[2].size > idx ? cols[2][idx] : ""
            # s << ' ' << '|' << ' '
            s << "  "
            s << col2
            s << " " * (col_width - col2.size) unless col_width < col2.size
          end

          # s << ' ' << '|'
          s << "\n"
        end
      
        # s << '+'
        # (0...cols.size).each do |idx|
        #   s << '+' if idx > 0
        #   s << "-" * (col_width + 2)
        # end
        # s << '+' << "\n"
      end
    end

    def as_ansi(width = 100, col_count = 3) : String
      cols = self.text_mode_columns(col_count)
      col_count = cols.size
      
      gutter_width = 4 + ((col_count - 1) * 3)
      col_width = [(width - gutter_width) / col_count, 50].min
      
      cols = cols.map do |col|
        rows = [] of String
        col.each do |section|
          section.each do |row|
            case row
            when Heading
              padding = col_width - row.name.size
              left_padding = padding / 2
              right_padding = padding - left_padding
              rows << "#{Ansi.blue_bg}#{Ansi.white_fg}#{" " * left_padding}#{row.name}#{" " * right_padding}#{Ansi.reset}"
            when Entry
              rows << "#{Ansi.blue_fg}#{row.key}#{Ansi.red_fg} : #{Ansi.white_fg}#{row.name}#{Ansi.reset}"
            end
          end
          rows << ""
        end
        rows.pop
        rows
      end
      # puts cols.inspect
      
      max_rows = cols.map(&.size).max
      
      String.build do |s|
        s << Ansi.grey_fg << '\u250f'
        (0...cols.size).each do |idx|
          s << '\u2533' if idx > 0
          s << "\u2501" * (col_width + 2)
        end
        s << '\u2513' << Ansi.reset << "\n"
      
        (0...max_rows).each do |idx|
          col0 = cols[0].size > idx ? cols[0][idx] : ""

          s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '

          s << col0
          s << " " * (col_width - Ansi.size(col0))

          if cols.size > 1
            col1 = cols[1].size > idx ? cols[1][idx] : ""
            s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
            s << col1
            s << " " * (col_width - Ansi.size(col1))
          end

          if cols.size > 2
            col2 = cols[2].size > idx ? cols[2][idx] : ""
            s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
            s << col2
            s << " " * (col_width - Ansi.size(col2))
          end

          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"
        end
      
        s << Ansi.grey_fg << '\u2517'
        (0...cols.size).each do |idx|
          s << '\u253B' if idx > 0
          s << "\u2501" * (col_width + 2)
        end
        s << '\u251B' << Ansi.reset << "\n"
      end
    
    end
    
    def as_html
      # String.build do |s|
      #   s << "<div class=\"menu\">"
      #   menu_sections.each do |section|
      #     s << "  <div class=\"section\">\n"
      #     s << "  <h1>" << section.name << "</h1>\n"
      #     section.entries.each do |entry|
      #       s << "    <button>" << entry.name << "</button>\n"
      #     end
      #     s << "  </div>\n"
      #   end
      #   s << "</div>"
      # end
    end
    
  end
end
