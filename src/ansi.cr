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

  class Command
    ESC = 27_u8
    CSI = 91_u8

    CUU = 'A'.bytes.first # – Cursor Up
    CUD = 'B'.bytes.first # – Cursor Down
    CUF = 'C'.bytes.first # – Cursor Forward
    CUB = 'D'.bytes.first # – Cursor Back
    CUP = 'H'.bytes.first # – Cursor Position
    ED  = 'J'.bytes.first # – Erase in Display
    EL  = 'K'.bytes.first # – Erase in Line
    SR  = 'R'.bytes.first # – Status Report (Reply to DSR)
    SU  = 'S'.bytes.first # – Scroll Up
    SD  = 'T'.bytes.first # – Scroll Down
    SGR = 'm'.bytes.first # – Select Graphic Rendition
    DSR = 'n'.bytes.first # – Device Status Report
    SCP = 's'.bytes.first # – Save Cursor Position
    RCP = 'u'.bytes.first # – Restore Cursor Position

    CSI_TERMINATORS = (65_u8..90_u8).to_a + (97_u8..122_u8).to_a

    def self.parse(socket)
      next_byte = socket.read_byte.as(UInt8)
      return next_byte unless next_byte == CSI
      bytes = [] of UInt8
      loop do
        next_byte = socket.read_byte.as(UInt8)
        bytes << next_byte
        break if CSI_TERMINATORS.includes?(next_byte)
      end
      x=new(bytes)
      STDERR.puts "ansi.parse got #{bytes.inspect} / #{x.inspect}"
      x
    end
    
    def self.get_pos
      new("6n")
    end
    
    def self.save_pos
      new("s")
    end
    
    def self.set_pos(row = 1, col = 1)
      new("#{row};#{col}H")
    end
    
    def self.restore_pos
      new("u")
    end
    
    def self.get_screensize
      save_pos + set_pos(9999, 9999) + get_pos + set_pos(1, 1) + restore_pos
    end
    
    getter byte_sequences : Array(Array(UInt8))
    def initialize(@byte_sequences : Array(Array(UInt8))) ; end
    
    def initialize(bytes : Array(UInt8))
      @byte_sequences = [bytes]
    end
    
    def initialize(str : String)
      @byte_sequences = [str.bytes]
    end
    
    def to_a
      @byte_sequences.flat_map {|bytes| [ESC, CSI] + bytes }
    end
    
    def +(other : Ansi::Command) : Ansi::Command
      Ansi::Command.new(byte_sequences + other.byte_sequences)
    end
    
    def inspect : String
      if command_value
        to_a.map(&.unsafe_chr).join.inspect + " | #{command_value}(#{arguments.join(", ")})"
      else
        to_a.map(&.unsafe_chr).join.inspect
      end# + " (@byte_sequences=#{@byte_sequences.inspect} command_value=#{command_value.inspect})"
    end
    
    def command_value
      return nil unless @byte_sequences.size == 1
      case @byte_sequences.first.last
      when CUU # – Cursor Up
        :cursor_up
      when CUD # – Cursor Down
        :cursor_down
      when CUF # – Cursor Forward
        :cursor_forward
      when CUB # – Cursor Back
        :cursor_back
      when CUP # – Cursor Position
        :move_cursor
      when ED  # – Erase in Display
        :clear_screen
      when EL  # – Erase in Line
        :clear_line
      when SR  # – Status Report (Reply to DSR)
        :cursor_position
      when SU  # – Scroll Up
        :scroll_up
      when SD  # – Scroll Down
        :scroll_down
      when SGR # – Select Graphic Rendition
        :set_render
      when DSR # – Device Status Report
        :report_position
      when SCP # – Save Cursor Position
        :save_position
      when RCP # – Restore Cursor Position
        :restore_position
      else
        :UNKNOWN
      end
    end
    
    def cursor_position?
      command_value == :cursor_position
    end
    
    def arguments
      return [] of Int32 unless @byte_sequences.size == 1 && @byte_sequences.first.size > 1
      @byte_sequences.first[0..-2].map(&.unsafe_chr).join.split(';').map(&.to_i32)
    end
  end
  
  class SGR < Command
    def initialize(str : String)
      @byte_sequences = str.bytes + 'm'.bytes
    end
  end
end
