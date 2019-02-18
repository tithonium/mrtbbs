require "./section"

module OldMenus
  class OldMenu

    getter :sections
    def initialize
      @sections = [] of OldMenus::Section
    end
    
    def <<(section)
      @sections << section
    end

    
    def as_text
      String.build do |s|
        sections.each do |section|
          s << section.as_text
        end
      end
    end
    
    def as_ansi
      
      cols = [
        [] of OldMenus::Section,
        [] of OldMenus::Section,
        [] of OldMenus::Section,
      ]
      if sections.size <= 3
        cols[0] << sections[0]
        cols[1] << sections[1] if sections.size >= 2
        cols[2] << sections[2] if sections.size == 3
      else
        total_length = sections.map(&.size).sum
        goal_size = total_length / 3
        idx = sections.size - 1
        colidx = 2
        while idx >= 0 && colidx > 0
          cols[colidx].unshift sections[idx]
          idx -= 1
          if idx >= 0 && (cols[colidx].map(&.size).sum + sections[idx].size) > goal_size
            colidx -= 1
          end
        end
        while idx >= 0
          cols[0].unshift sections[idx]
          idx -= 1
        end
      end
      puts cols.inspect
      
      col_width = 30
      cols = cols.map {|col| col.flat_map(&.as_ansi(col_width)) }
      puts cols.inspect
      
      max_rows = cols.map(&.size).max
      
      String.build do |s|
        s << Ansi.grey_fg << '\u250f'
        s << "\u2501" * (col_width + 2)
        s << '\u2533'
        s << "\u2501" * (col_width + 2)
        s << '\u2533'
        s << "\u2501" * (col_width + 2)
        s << '\u2513' << Ansi.reset << "\n"

        (0...max_rows).each do |idx|
          col0 = cols[0][idx]
          puts col0.inspect
          col1 = cols[1].size > idx ? cols[1][idx] : ""
          puts col1.inspect
          col2 = cols[2].size > idx ? cols[2][idx] : ""
          puts col2.inspect
          s << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << col0
          s << " " * (col_width - Ansi.size(col0))
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << col1
          s << " " * (col_width - Ansi.size(col1))
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << ' '
          s << col2
          s << " " * (col_width - Ansi.size(col2))
          s << ' ' << Ansi.grey_fg << '\u2503' << Ansi.reset << "\n"
        end
        
        s << Ansi.grey_fg << '\u2517'
        s << "\u2501" * (col_width + 2)
        s << '\u253B'
        s << "\u2501" * (col_width + 2)
        s << '\u253B'
        s << "\u2501" * (col_width + 2)
        s << '\u251B' << Ansi.reset << "\n"
      end

    end
    
    def as_html
      String.build do |s|
        s << "<div class=\"menu\">"
        sections.each do |section|
          s << "  <div class=\"section\">\n"
          s << "  <h1>" << section.name << "</h1>\n"
          section.entries.each do |entry|
            s << "    <button>" << entry.name << "</button>\n"
          end
          s << "  </div>\n"
        end
        s << "</div>"
      end
    end
    
  end
end
