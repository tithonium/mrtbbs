# https://en.wikipedia.org/wiki/ANSI_escape_code

# CSI 6n DSR – Device Status Report Reports the cursor position (CPR) to the application as (as though typed at the keyboard) ESC[n;mR, where n is the row and m is the column.)


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

  def self.dblue_bg
    "#{ESC}[44m"
  end

  def self.blue_bg
    "#{ESC}[104m"
  end

  def self.red_bg
    "#{ESC}[41m"
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
