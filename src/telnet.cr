# = net/telnet.rc - Simple Telnet processing library
#
# Author:: Martin Tithonium <martian@midgard.org>
#
# Derived from https://github.com/ruby/net-telnet
# Original Author:: Wakou Aoyama <wakou@ruby-lang.org>

# https://tools.ietf.org/html/rfc1116
# https://github.com/MBoldyrev/telnet2uart/blob/36d90c688b260c68fc799dc9b4fd577e3afe1a6a/telnetd.c#L28
# https://github.com/beardedfoo/faketelnetd/blob/bb47117ce1c0860ec05ac73dbb018e6915ce84ab/TelnetServerSocket.cpp#L233

require "./telnet/commands"

class Telnet

  IAC = 255_u8
  ESC = 27_u8

  NULL = 0_u8
  CR   = 13_u8
  LF   = 10_u8

  getter :sock

  alias Dimension = Tuple(Int32, Int32)
  getter screen_size : Dimension?

  def initialize(@socket : TCPSocket)
    @ansi       = false
    @to_binary  = false
    @to_echo    = nil
    @to_sga     = nil
    @screen_size = nil

    @buffer = [] of UInt8
    @readchan = Channel::Buffered(UInt8).new(64)
    @cmdchan = Channel::Buffered(Telnet::Command | Ansi::Command).new(5)
    
    spawn process_incoming
    self.send Telnet::Command.dont.linemode
    detect_ansi!
    Fiber.yield
  end

  def ansi?
    @ansi
  end

  def open?
    !BBS.shutdown? && !@socket.closed? && !@readchan.closed? && !@cmdchan.closed?
  end
  
  def binary?
    @to_binary
  end
  
  def sga?
    @to_sga
  end
  
  def screen_width : Int32
    if screen_size.nil?
      100
    else
      screen_size.as(Dimension)[1]
    end
  end
  
  def process_incoming
    while open?
      begin
        if byte_read = @socket.read_byte
          # STDERR.puts "< #{byte_read.inspect} | #{byte_read.unsafe_chr.inspect}"
          if byte_read == IAC
            case parsed_result = Telnet::Commands.parse(@socket)
            when Telnet::Command
              @cmdchan.send parsed_result
            when UInt8
              @readchan.send parsed_result
            end
          elsif byte_read == ESC
            case parsed_result = Ansi::Command.parse(@socket)
            when Ansi::Command
              STDERR.puts parsed_result.inspect
              @cmdchan.send parsed_result
            when UInt8
              @readchan.send byte_read
              @readchan.send parsed_result
            end
          else
            @readchan.send byte_read
          end
        end
      rescue
      end
    end
  end

  # Turn newline conversion on (+mode+ == false) or off (+mode+ == true),
  # or return the current value (+mode+ is not specified).
  def binmode(mode = nil)
    case mode
    when nil
      @to_binary
    when true, false
      @to_binary = mode
    else
      raise ArgumentError, "argument must be true or false"
    end
  end

  # Turn newline conversion on (false) or off (true).
  def binmode=(mode)
    if (true == mode || false == mode)
      @to_binary = mode
    else
      raise ArgumentError, "argument must be true or false"
    end
  end

  def detect_ansi!
    set_character_mode!
    disable_client_echo!
    self.send(Ansi::Command.get_pos)
    Fiber.yield
    sleep 0.05
    Fiber.yield
    enable_client_echo!
    set_line_mode!
  end

  def set_line_mode!
    return if @to_sga == false
    @to_sga = nil
    self.send Telnet::Command.wont.sga
  end

  def set_character_mode!
    return if @to_sga == true
    @to_sga = nil
    self.send Telnet::Command.will.sga
  end

  def disable_client_echo!
    return if @to_echo == true
    @to_echo = nil
    self.send Telnet::Command.will.echo
  end
  
  def enable_client_echo!
    return if @to_echo == false
    @to_echo = nil
    self.send Telnet::Command.wont.echo
  end

  def process_commands!
    while !@cmdchan.empty?
      next_command = @cmdchan.receive
      STDERR.puts "Processing command #{next_command.inspect}"
      case next_command
      when Telnet::Request
        next_command = next_command.as(Telnet::Request)
        option = next_command.option.as(UInt8)
        case next_command
        when .do?
          if next_command.sga? && @to_sga.nil?
            @to_sga = true
          elsif next_command.echo? && @to_echo.nil?
            @to_echo = true
          else
            self.send(Telnet::Command.wont(option))
          end
        when .dont?
          if next_command.sga? && @to_sga.nil?
            @to_sga = false
          elsif next_command.echo? && @to_echo.nil?
            @to_echo = false
          # else
          #   self.send(Telnet::Command.wont(option))
          end
        when .will?
          self.send(Telnet::Command.dont(option))
        when .wont?
        end
      when Ansi::Command
        STDERR.puts "it's an ansi command"
        unless ansi?
          STDERR.puts "we weren't in ansi mode"
          @ansi = true
          sleep 0.5
          disable_client_echo!
          original_position = Tuple(Int32, Int32).from(next_command.arguments) if next_command.cursor_position?
          self.send(Ansi::Command.get_screensize)
          self.send(Ansi::Command.set_pos(*original_position)) if original_position
          enable_client_echo!
        end
        if @screen_size.nil? && next_command.cursor_position?
          STDERR.puts "it's a position report!"
          @screen_size = Tuple(Int32, Int32).from(next_command.arguments)
          STDERR.puts "screen size is #{@screen_size.inspect}"
        end
      when .ayt?
        self.puts("nobody here but us aliens")
      end
      Fiber.yield
    end
  end

  def next_byte
    byte = nil
    while open? && byte.nil?
      Fiber.yield
      if @buffer.size > 0
        byte = @buffer.shift
      elsif !@readchan.empty?
        byte = @readchan.receive
      end
    end
    byte ||= 0_u8
    return byte
  end

  def next_char
    Fiber.yield
    process_commands!
    char = next_byte
    if char == CR
      # STDERR.puts "next_char got CR!"
      second_char = next_byte
      if second_char == LF
        return second_char.unsafe_chr
      elsif second_char != NULL
        @buffer.unshift second_char
      end
      return char.unsafe_chr
    elsif char == NULL
      # STDERR.puts "next_char got NULL!"
      next_char
    else
      # STDERR.puts "next_char got #{char.inspect} : #{char.unsafe_chr.inspect}!"
      return char.unsafe_chr
    end
  end

  def peek_byte
    c = next_byte
    @buffer.unshift c
    c
  end

  def gets
    String.build do |s|
      loop do
        s << (c = self.next_char)
        # STDERR.puts "gets got char #{c.inspect}, have #{s.inspect} | #{(c == '\n').inspect} || #{(c == '\r').inspect} = #{(c == '\n' || c == '\r').inspect}"
        break if c == '\n' || c == '\r'
      end
    end
  end
  
  def read_char
    set_character_mode!
    disable_client_echo!
    c = next_char
    enable_client_echo!
    set_line_mode!
    c
  end

  def send(command : Telnet::Command)
    STDERR.puts "Sending telnet command #{command.inspect}"
    send_bytes(command.to_a)
    sleep 0.01
    Fiber.yield
    process_commands!
  end

  def send(command : Ansi::Command)
    STDERR.puts "Sending ansi command #{command.inspect}"
    send_bytes(command.to_a)
    sleep 0.01
    Fiber.yield
    process_commands!
  end

  def send_bytes(bytes : Array(UInt8))
    return if @socket.closed?
    bytes.each do |byte|
      # STDERR.puts "> #{byte.inspect} | #{byte.unsafe_chr.inspect}"
      @socket.write_byte(byte)
    end
    flush
  end

  # def send_bytes(*bytes)
  #    send_bytes(bytes.to_a)
  # end

  def flush
    @socket.flush
  end

  # Write +string+ to the host.
  #
  # Does not perform any conversions on +string+.  Will log +string+ to the
  # dumplog, if the Dump_log option is set.
  def write(string : String)
    send_bytes(string.bytes)
  end
  
  def write(bytes : Array(UInt8))
    send_bytes(bytes)
  end

  # Sends a string to the host.
  #
  # This does _not_ automatically append a newline to the string.  Embedded
  # newlines may be converted and telnet command sequences escaped
  # depending upon the values of telnetmode, binmode, and telnet options
  # set by the host.
  def print(string)
    string = string.gsub(/#{IAC}/, IAC + IAC)

    string = if @to_binary
      string
    else
      if binary? && sga?
        # IAC WILL SGA IAC DO BIN send EOL --> CR
        string.gsub(/\n/, "\r")
      elsif sga?
        # IAC WILL SGA send EOL --> CR+NULL
        string.gsub(/\n/, "\r\0")
      else
        # NONE send EOL --> CR+LF
        string.gsub(/\n/, "\r\n")
      end
    end
    self.write(string)
  end

  # Sends a string to the host.
  #
  # Same as #print(), but appends a newline to the string.
  def puts(string)
    self.print(string + "\n")
  end

  def puts
    self.puts("")
  end

  # Closes the connection
  def close
    @socket.close
  end

end  # class Telnet
