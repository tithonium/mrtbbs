require "./entry"

module OldMenus
  class Section
    
    getter :name, :entries
    def initialize(@name : String)
      @entries = [] of OldMenus::Entry
    end
    
    def <<(entry)
      @entries << entry
    end
    
    def size
      @entries.size
    end
    
    def as_text
      String.build do |s|
        s << "== " << name << " ==\n"
        entries.each do |entry|
          s << entry.key << "> " << entry.name << "\n"
        end
        s << "\n"
      end
    end

    def as_ansi(width = 40)
      padding = width - name.size
      left_padding = padding / 2
      right_padding = padding - left_padding
      puts [left_padding, right_padding].inspect
      s = [ "#{Ansi.blue_bg}#{Ansi.white_fg}#{" " * left_padding}#{name}#{" " * right_padding}#{Ansi.reset}" ]
      entries.each do |entry|
        s << "#{Ansi.blue_fg}#{entry.key}#{Ansi.red_fg} : #{Ansi.white_fg}#{entry.name}#{Ansi.reset}"
      end
      s
    end
    
  end
end
