module Ansi

  ESC = '\e'
  FG_COLOR = "38;"
  BG_COLOR = "48;"

  def self.clear
    "#{ESC}[2J"
  end
  
  def self.reset
    "#{ESC}[0m"
  end

  def self.blue_fg
    "#{ESC}[1;94m"
  end

  def self.red_fg
    "#{ESC}[1;91m"
  end

  def self.blue_bg
    "#{ESC}[104m"
  end

  def self.white_fg
    "#{ESC}[1;97m"
  end
  
  def self.grey_fg
    "#{ESC}[37m"
  end

  def self.strip(string)
    string.gsub(/#{ESC}\[(\s*\d+\s*;)*\d+\s*m/, "")
  end
  
  def self.size(string)
    self.strip(string).size
  end
  
end
