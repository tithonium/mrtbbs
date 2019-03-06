# https://tools.ietf.org/html/rfc854
# https://tools.ietf.org/html/rfc857
# https://tools.ietf.org/html/rfc858
# https://tools.ietf.org/html/rfc859
# https://tools.ietf.org/html/rfc885

class Telnet
  class Commands

    COMMANDS = {
      "IAC"   => 255_u8, # interpret as command
      "DONT"  => 254_u8, # you are not to use option
      "DO"    => 253_u8, # please, you use option
      "WONT"  => 252_u8, # I won"t use option
      "WILL"  => 251_u8, # I will use option
      "SB"    => 250_u8, # interpret as subnegotiation
      "GA"    => 249_u8, # you may reverse the line
      "EL"    => 248_u8, # erase the current line
      "EC"    => 247_u8, # erase the current character
      "AYT"   => 246_u8, # are you there
      "AO"    => 245_u8, # abort output--but let prog finish
      "IP"    => 244_u8, # interrupt process--permanently
      "BREAK" => 243_u8, # break
      "DM"    => 242_u8, # data mark--for connect. cleaning
      "SYNCH" => 242_u8, # for telfunc calls
      "NOP"   => 241_u8, # nop
      "SE"    => 240_u8, # end sub negotiation
      "EOR"   => 239_u8, # end of record (transparent mode)
      "ABORT" => 238_u8, # Abort process
      "SUSP"  => 237_u8, # Suspend process
      "EOF"   => 236_u8, # End of file
    }
    
    {% for cmd in COMMANDS %}
    {{cmd.upcase.id}} = COMMANDS[{{cmd}}]
    {% end %}
    
    OPTIONS = {
      "BINARY"         =>   0_u8, # Binary Transmission
      "ECHO"           =>   1_u8, # Echo
      "RCP"            =>   2_u8, # Reconnection
      "SGA"            =>   3_u8, # Suppress Go Ahead
      "NAMS"           =>   4_u8, # Approx Message Size Negotiation
      "STATUS"         =>   5_u8, # Status
      "TM"             =>   6_u8, # Timing Mark
      "RCTE"           =>   7_u8, # Remote Controlled Trans and Echo
      "NAOL"           =>   8_u8, # Output Line Width
      "NAOP"           =>   9_u8, # Output Page Size
      "NAOCRD"         =>  10_u8, # Output Carriage-Return Disposition
      "NAOHTS"         =>  11_u8, # Output Horizontal Tab Stops
      "NAOHTD"         =>  12_u8, # Output Horizontal Tab Disposition
      "NAOFFD"         =>  13_u8, # Output Formfeed Disposition
      "NAOVTS"         =>  14_u8, # Output Vertical Tabstops
      "NAOVTD"         =>  15_u8, # Output Vertical Tab Disposition
      "NAOLFD"         =>  16_u8, # Output Linefeed Disposition
      "XASCII"         =>  17_u8, # Extended ASCII
      "LOGOUT"         =>  18_u8, # Logout
      "BM"             =>  19_u8, # Byte Macro
      "DET"            =>  20_u8, # Data Entry Terminal
      "SUPDUP"         =>  21_u8, # SUPDUP
      "SUPDUPOUTPUT"   =>  22_u8, # SUPDUP Output
      "SNDLOC"         =>  23_u8, # Send Location
      "TTYPE"          =>  24_u8, # Terminal Type
      "EOR"            =>  25_u8, # End of Record
      "TUID"           =>  26_u8, # TACACS User Identification
      "OUTMRK"         =>  27_u8, # Output Marking
      "TTYLOC"         =>  28_u8, # Terminal Location Number
      "REGIME3270"     =>  29_u8, # Telnet 3270 Regime
      "X3PAD"          =>  30_u8, # X.3 PAD
      "NAWS"           =>  31_u8, # Negotiate About Window Size
      "TSPEED"         =>  32_u8, # Terminal Speed
      "LFLOW"          =>  33_u8, # Remote Flow Control
      "LINEMODE"       =>  34_u8, # Linemode
      "XDISPLOC"       =>  35_u8, # X Display Location
      "OLD_ENVIRON"    =>  36_u8, # Environment Option
      "AUTHENTICATION" =>  37_u8, # Authentication Option
      "ENCRYPT"        =>  38_u8, # Encryption Option
      "NEW_ENVIRON"    =>  39_u8, # New Environment Option
      "EXOPL"          => 255_u8, # Extended-Options-List
    }
    
    {% for opt in OPTIONS %}
    OPT_{{opt.upcase.id}} = OPTIONS[{{opt}}]
    {% end %}
    
    def self.parse(socket)
      request_byte = socket.read_byte.as(UInt8)
      case request_byte
      when IAC
        # STDERR.puts "# Got escaped IAC"
        request_byte
      when DONT, DO, WONT, WILL
        option_byte = socket.read_byte.as(UInt8)
        if option_byte
          Telnet::Request.new(request_byte, option_byte)
        end
      when SB
        # STDERR.puts "# Got SB"
        bytes = [] of UInt8
        while (c = socket.read_byte) != SE
          next if c == IAC || c.nil?
          bytes << c
        end
        Telnet::Subnegotiation.new(bytes)
      when AYT
        STDERR.puts "# Got AYT"
        Telnet::Ayt.new
      # when GA
      # when EL
      # when EC
      # when AO
      # when IP
      # when BREAK
      # when DM
      # when NOP
      # when SE
      # when EOR
      # when ABORT
      # when SUSP
      # when EOF
      # when SYNCH
      else
        Telnet::Command.new(request_byte)
      end
    end


    # {% for cmd in %w[do dont will wont] %}
    {% for cmd in COMMANDS %}
    def self.{{cmd.downcase.id}}(*args)
      Telnet::Command.{{cmd.downcase.id}}(*args)
    end
    {% end %}


  end
  
  class Command
    getter command : UInt8
    
    IAC      = Telnet::Commands::IAC
    COMMANDS = Telnet::Commands::COMMANDS
    OPTIONS  = Telnet::Commands::OPTIONS
    
    {% for cmd in Telnet::Commands::COMMANDS %}
    def self.{{cmd.downcase.id}}(*args)
      Telnet::{% if %w[DO DONT WILL WONT].includes?(cmd) %}Request{% else %}Command{% end %}.new(COMMANDS[{{cmd}}], *args)
    end
    
    def {{cmd.downcase.id}}?
      command == COMMANDS[{{cmd}}]
    end
    {% end %}

    def initialize(@command : UInt8) ; end
    
    def to_a : Array(UInt8)
      [ IAC, command ]
    end
    
    def to_bytes
      array = to_a
      bytes = Bytes.new(array.size)
      array.each_with_index do |byte, idx|
        bytes[idx] = byte if byte
      end
      bytes
    end
    
    def inspect
      "IAC #{command_name}"
    end
    
    def command_name
      COMMANDS.invert.fetch(command, "????")
    end
    
    def ==(other)
      other.is_a?(Telnet::Command) && other.to_a == self.to_a
    end
  end

  class Request < Command
    getter option : UInt8?
    
    def initialize(@command : UInt8, @option : UInt8) ; end
    def initialize(@command : UInt8) ; end

    def initialize(command_name : String, option_name : String)
      initialize(COMMANDS[command_name], OPTIONS[option_name.sub(/\AOPT_/, "")])
    end
    def initialize(command_name : String, option : UInt8)
      initialize(COMMANDS[command_name], option)
    end
    def initialize(command_name : String)
      initialize(COMMANDS[command_name])
    end

    {% for opt in Telnet::Commands::OPTIONS %}
    def {{opt.downcase.id}}
      raise "Option already set!" if @option
      @option = OPTIONS[{{opt}}]
      self
    end
    
    def {{opt.downcase.id}}?
      option == OPTIONS[{{opt}}]
    end
    {% end %}

    def to_a : Array(UInt8)
      [ IAC, command, option ].compact
    end
    
    def inspect
      "IAC #{command_name} #{option_name}"
    end
    
    def option_name
      OPTIONS.invert.fetch(option, "????")
    end
    
  end
  
  class Ayt < Command
    def initialize
      @command = COMMANDS["AYT"]
    end
  end
  
  class Subnegotiation < Command
    SB           = COMMANDS["SB"]
    OPT_LINEMODE = OPTIONS["OPT_LINEMODE"]
    
    SB_LINEMODE_MODE        =   1_u8
    SB_LINEMODE_FORWARDMASK =   2_u8
    SB_LINEMODE_SLC         =   3_u8

    SB_LINEMODE_MODE_NONE     =   0_u8
    SB_LINEMODE_MODE_EDIT     =   1_u8
    SB_LINEMODE_MODE_TRAPSIG  =   2_u8
    SB_LINEMODE_MODE_MODE_ACK =   4_u8
    SB_LINEMODE_MODE_SOFT_TAB =   8_u8
    SB_LINEMODE_MODE_LIT_ECHO =  16_u8

    @option_class = 0_u8
    @options = [] of UInt8

    getter :option_class, :options
    def initialize(options : Array(UInt8))
      @command = SB
      @option_class = options[0]
      @options = options[1..-1]
    end

    def initialize(*args)
      initialize(args)
    end

    def to_a : Array(UInt8)
      [
        IAC,
        SB,
        option_class,
        options,
        IAC,
        SE
      ].flatten
    end

    def inspect
      String.build do |s|
        s << "IAC SB "
        case option_class
        when OPTIONS["OPT_LINEMODE"]
          s << "LINEMODE "
          case options.first
          when SB_LINEMODE_MODE
            s << "MODE "
            mask = options[1]
            optionset = [] of String
            optionset << "EDIT" if mask & SB_LINEMODE_MODE_EDIT > 0
            optionset << "TRAPSIG" if mask & SB_LINEMODE_MODE_TRAPSIG > 0
            optionset << "MODE_ACK" if mask & SB_LINEMODE_MODE_MODE_ACK > 0
            optionset << "SOFT_TAB" if mask & SB_LINEMODE_MODE_SOFT_TAB > 0
            optionset << "LIT_ECHO" if mask & SB_LINEMODE_MODE_LIT_ECHO > 0
            optionset << "[NONE]" if optionset.empty?
            s << optionset.join('|')
          when SB_LINEMODE_FORWARDMASK
            s << "FORWARDMASK "
            s << options[1..-1].inspect
          when SB_LINEMODE_SLC
            s << "SLC "
            s << options[1..-1].inspect
          else
            s << "UNKNOWN["
            s << options[1..-1].inspect
            s << "] "
          end
        else
          s << "UNKNOWN["
          s << option_class.inspect
          s << "] "
          s << options.inspect
        end
        s << " IAC SE"
      end
    end
  end

end
