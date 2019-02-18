class MenuSection < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    name: String,
    menu_id: Int32?,
    created_at: Time?,
    updated_at: Time?,
  )

  belongs_to :menu, Menu
  has_many :menu_entries, MenuEntry

  def match_key(option : String) : MenuEntry?
    menu_entries.each do |entry|
      return entry if entry.match_key(option)
    end
  end

  def size
    menu_entries.size
  end
  
  def as_text
    String.build do |s|
      s << "== " << name << " ==\n"
      menu_entries.each do |entry|
        s << entry.key << "> " << entry.name << "\n"
      end
      s << "\n"
    end
  end

  def as_ansi(width = 40)
    padding = width - name.size
    left_padding = padding / 2
    right_padding = padding - left_padding
    # puts [left_padding, right_padding].inspect
    s = [ "#{Ansi.blue_bg}#{Ansi.white_fg}#{" " * left_padding}#{name}#{" " * right_padding}#{Ansi.reset}" ]
    menu_entries.each do |entry|
      s << "#{Ansi.blue_fg}#{entry.key}#{Ansi.red_fg} : #{Ansi.white_fg}#{entry.name}#{Ansi.reset}"
    end
    s
  end

end
