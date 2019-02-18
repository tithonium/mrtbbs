# = net/telnet.rc - Simple Telnet processing library
#
# Author:: Martin Tithonium <martian@midgard.org>
#
# Derived from https://github.com/ruby/net-telnet
# Original Author:: Wakou Aoyama <wakou@ruby-lang.org>

# https://tools.ietf.org/html/rfc1116
# https://github.com/MBoldyrev/telnet2uart/blob/36d90c688b260c68fc799dc9b4fd577e3afe1a6a/telnetd.c#L28
# https://github.com/beardedfoo/faketelnetd/blob/bb47117ce1c0860ec05ac73dbb018e6915ce84ab/TelnetServerSocket.cpp#L233

require "./telnet/options"

class Telnet

  IAC = Telnet::Options::IAC

  NULL = 0_u8
  CR   = 13_u8
  LF   = 10_u8

  getter :sock

  def initialize(@socket : TCPSocket, @binmode = false, @telnetmode = true)
    @binmode    = false
    @telnetmod = true
    @telnet_option = { "SGA" => false, "BINARY" => false }

    @buffer = [] of UInt8
    @readchan = Channel::Buffered(UInt8).new(64)
    @cmdchan = Channel::Buffered(Telnet::Options::Base).new(5)
    
    initialize!
    spawn process_incoming
    Fiber.yield
  end

  def process_incoming
    while !BBS.shutdown? && !@socket.closed? && !@readchan.closed? && !@cmdchan.closed?
      begin
        if byte_read = @socket.read_byte
          # STDERR.puts "< #{byte_read.inspect} | #{byte_read.unsafe_chr.inspect}"
          if byte_read == IAC
            case parsed_option = Telnet::Options.parse(@socket)
            when Telnet::Options::Base
              @cmdchan.send parsed_option
            when UInt8
              @readchan.send parsed_option
            end
          else
            @readchan.send byte_read
          end
        end
      rescue
      end
    end
  end

  # Set telnet command interpretation on (+mode+ == true) or off
  # (+mode+ == false), or return the current value (+mode+ not
  # provided).  It should be on for true telnet sessions, off if
  # using Telnet to connect to a non-telnet service such
  # as SMTP.
  def telnetmode(mode = nil)
    case mode
    when nil
      @telnetmod
    when true, false
      @telnetmod = mode
    else
      raise ArgumentError, "argument must be true or false, or missing"
    end
  end

  # Turn telnet command interpretation on (true) or off (false).  It
  # should be on for true telnet sessions, off if using Telnet
  # to connect to a non-telnet service such as SMTP.
  def telnetmode=(mode)
    if (true == mode || false == mode)
      @telnetmod = mode
    else
      raise ArgumentError, "argument must be true or false"
    end
  end

  # Turn newline conversion on (+mode+ == false) or off (+mode+ == true),
  # or return the current value (+mode+ is not specified).
  def binmode(mode = nil)
    case mode
    when nil
      @binmode
    when true, false
      @binmode = mode
    else
      raise ArgumentError, "argument must be true or false"
    end
  end

  # Turn newline conversion on (false) or off (true).
  def binmode=(mode)
    if (true == mode || false == mode)
      @binmode = mode
    else
      raise ArgumentError, "argument must be true or false"
    end
  end

  macro t_opt(name)
    Telnet::Options::{{name}}
  end

  def initialize!
    self.send Telnet::Options::Dont.new(t_opt OPT_LINEMODE)
    # self.send Telnet::Options::Do.new(t_opt OPT_ECHO)
  end

  def set_line_mode!
    self.send Telnet::Options::Wont.new(t_opt OPT_SGA)
  end

  def set_character_mode!
    self.send Telnet::Options::Will.new(t_opt OPT_SGA)
  end

  def disable_echo!
    self.send Telnet::Options::Will.new(t_opt OPT_ECHO)
  end
  
  def enable_echo!
    self.send Telnet::Options::Wont.new(t_opt OPT_ECHO)
  end

  def process_commands!
    while !@cmdchan.empty?
      next_command = @cmdchan.receive
      # STDERR.puts "Processing command #{next_command.inspect}"
      Fiber.yield
    end
  end

  def next_byte
    byte = nil
    while byte.nil?
      if @buffer.size > 0
        byte = @buffer.shift
      elsif !@readchan.empty?
        byte = @readchan.receive
      end
      Fiber.yield
    end
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
    disable_echo!
    c = next_char
    enable_echo!
    set_line_mode!
    c
  end

  def send(command : Telnet::Options::Base)
    # STDERR.puts "Sending command #{command.inspect}"
    send_bytes(command.as_bytes)
    sleep 0.1
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

  def send_bytes(*bytes)
     send_bytes(bytes.to_a)
  end

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

  # Sends a string to the host.
  #
  # This does _not_ automatically append a newline to the string.  Embedded
  # newlines may be converted and telnet command sequences escaped
  # depending upon the values of telnetmode, binmode, and telnet options
  # set by the host.
  def print(string)
    string = string.gsub(/#{IAC}/, IAC + IAC) if @telnetmod

    if @binmode
      self.write(string)
    else
      if @telnet_option["BINARY"] && @telnet_option["SGA"]
        # IAC WILL SGA IAC DO BIN send EOL --> CR
        self.write(string.gsub(/\n/, "\r"))
      elsif @telnet_option["SGA"]
        # IAC WILL SGA send EOL --> CR+NULL
        self.write(string.gsub(/\n/, "\r\0"))
      else
        # NONE send EOL --> CR+LF
        self.write(string.gsub(/\n/, "\r\n"))
      end
    end
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
