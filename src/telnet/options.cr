class Telnet
  class Options

    # :stopdoc:
    IAC   = 255_u8 # interpret as command
    DONT  = 254_u8 # you are not to use option
    DO    = 253_u8 # please, you use option
    WONT  = 252_u8 # I won"t use option
    WILL  = 251_u8 # I will use option
    SB    = 250_u8 # interpret as subnegotiation
    GA    = 249_u8 # you may reverse the line
    EL    = 248_u8 # erase the current line
    EC    = 247_u8 # erase the current character
    AYT   = 246_u8 # are you there
    AO    = 245_u8 # abort output--but let prog finish
    IP    = 244_u8 # interrupt process--permanently
    BREAK = 243_u8 # break
    DM    = 242_u8 # data mark--for connect. cleaning
    NOP   = 241_u8 # nop
    SE    = 240_u8 # end sub negotiation
    EOR   = 239_u8 # end of record (transparent mode)
    ABORT = 238_u8 # Abort process
    SUSP  = 237_u8 # Suspend process
    EOF   = 236_u8 # End of file
    SYNCH = 242_u8 # for telfunc calls

    OPT_BINARY         =   0_u8 # Binary Transmission
    OPT_ECHO           =   1_u8 # Echo
    OPT_RCP            =   2_u8 # Reconnection
    OPT_SGA            =   3_u8 # Suppress Go Ahead
    OPT_NAMS           =   4_u8 # Approx Message Size Negotiation
    OPT_STATUS         =   5_u8 # Status
    OPT_TM             =   6_u8 # Timing Mark
    OPT_RCTE           =   7_u8 # Remote Controlled Trans and Echo
    OPT_NAOL           =   8_u8 # Output Line Width
    OPT_NAOP           =   9_u8 # Output Page Size
    OPT_NAOCRD         =  10_u8 # Output Carriage-Return Disposition
    OPT_NAOHTS         =  11_u8 # Output Horizontal Tab Stops
    OPT_NAOHTD         =  12_u8 # Output Horizontal Tab Disposition
    OPT_NAOFFD         =  13_u8 # Output Formfeed Disposition
    OPT_NAOVTS         =  14_u8 # Output Vertical Tabstops
    OPT_NAOVTD         =  15_u8 # Output Vertical Tab Disposition
    OPT_NAOLFD         =  16_u8 # Output Linefeed Disposition
    OPT_XASCII         =  17_u8 # Extended ASCII
    OPT_LOGOUT         =  18_u8 # Logout
    OPT_BM             =  19_u8 # Byte Macro
    OPT_DET            =  20_u8 # Data Entry Terminal
    OPT_SUPDUP         =  21_u8 # SUPDUP
    OPT_SUPDUPOUTPUT   =  22_u8 # SUPDUP Output
    OPT_SNDLOC         =  23_u8 # Send Location
    OPT_TTYPE          =  24_u8 # Terminal Type
    OPT_EOR            =  25_u8 # End of Record
    OPT_TUID           =  26_u8 # TACACS User Identification
    OPT_OUTMRK         =  27_u8 # Output Marking
    OPT_TTYLOC         =  28_u8 # Terminal Location Number
    OPT_3270REGIME     =  29_u8 # Telnet 3270 Regime
    OPT_X3PAD          =  30_u8 # X.3 PAD
    OPT_NAWS           =  31_u8 # Negotiate About Window Size
    OPT_TSPEED         =  32_u8 # Terminal Speed
    OPT_LFLOW          =  33_u8 # Remote Flow Control
    OPT_LINEMODE       =  34_u8 # Linemode
    OPT_XDISPLOC       =  35_u8 # X Display Location
    OPT_OLD_ENVIRON    =  36_u8 # Environment Option
    OPT_AUTHENTICATION =  37_u8 # Authentication Option
    OPT_ENCRYPT        =  38_u8 # Encryption Option
    OPT_NEW_ENVIRON    =  39_u8 # New Environment Option
    OPT_EXOPL          = 255_u8 # Extended-Options-List

    NULL = 0_u8
    CR   = 13_u8
    LF   = 10_u8

    COMMANDS = {
      255_u8 => "IAC",
      254_u8 => "DONT",
      253_u8 => "DO",
      252_u8 => "WONT",
      251_u8 => "WILL",
      250_u8 => "SB",
      249_u8 => "GA",
      248_u8 => "EL",
      247_u8 => "EC",
      246_u8 => "AYT",
      245_u8 => "AO",
      244_u8 => "IP",
      243_u8 => "BREAK",
      242_u8 => "DM",
      241_u8 => "NOP",
      240_u8 => "SE",
      239_u8 => "EOR",
      238_u8 => "ABORT",
      237_u8 => "SUSP",
      236_u8 => "EOF",
      242_u8 => "SYNCH",
    }
    OPTIONS = {
        0_u8 => "OPT_BINARY",
        1_u8 => "OPT_ECHO",
        2_u8 => "OPT_RCP",
        3_u8 => "OPT_SGA",
        4_u8 => "OPT_NAMS",
        5_u8 => "OPT_STATUS",
        6_u8 => "OPT_TM",
        7_u8 => "OPT_RCTE",
        8_u8 => "OPT_NAOL",
        9_u8 => "OPT_NAOP",
       10_u8 => "OPT_NAOCRD",
       11_u8 => "OPT_NAOHTS",
       12_u8 => "OPT_NAOHTD",
       13_u8 => "OPT_NAOFFD",
       14_u8 => "OPT_NAOVTS",
       15_u8 => "OPT_NAOVTD",
       16_u8 => "OPT_NAOLFD",
       17_u8 => "OPT_XASCII",
       18_u8 => "OPT_LOGOUT",
       19_u8 => "OPT_BM",
       20_u8 => "OPT_DET",
       21_u8 => "OPT_SUPDUP",
       22_u8 => "OPT_SUPDUPOUTPUT",
       23_u8 => "OPT_SNDLOC",
       24_u8 => "OPT_TTYPE",
       25_u8 => "OPT_EOR",
       26_u8 => "OPT_TUID",
       27_u8 => "OPT_OUTMRK",
       28_u8 => "OPT_TTYLOC",
       29_u8 => "OPT_3270REGIME",
       30_u8 => "OPT_X3PAD",
       31_u8 => "OPT_NAWS",
       32_u8 => "OPT_TSPEED",
       33_u8 => "OPT_LFLOW",
       34_u8 => "OPT_LINEMODE",
       35_u8 => "OPT_XDISPLOC",
       36_u8 => "OPT_OLD_ENVIRON",
       37_u8 => "OPT_AUTHENTICATION",
       38_u8 => "OPT_ENCRYPT",
       39_u8 => "OPT_NEW_ENVIRON",
      255_u8 => "OPT_EXOPL",
    }

    abstract class Base
      def self.build(*args)
        new(*args)
      end

      def sent_to(client)
        client.send_bytes(self.as_bytes)
      end
    end

    abstract class Request < Base
      getter :option
      def initialize(@option : UInt8) ; end
      
      def option_name
        OPTIONS[option].sub(/\AOPT_/, "")
      end
    end

    class Do < Request
      def as_bytes
        [ IAC, DO, option ]
      end
      def inspect ; "IAC DO #{option_name}" ; end
      # case third_char
      # when OPT_BINARY
      #   @telnet_option["BINARY"] = true
      #   self.send_bytes(IAC, WILL, OPT_BINARY)
      # else
      #   self.send_bytes(IAC, WONT, third_char)
      # end
    end
    class Dont < Request
      def as_bytes
        [ IAC, DONT, option ]
      end
      def inspect ; "IAC DONT #{option_name}" ; end
      # self.send_bytes(IAC, WONT, third_char)
    end
    class Will < Request
      def as_bytes
        [ IAC, WILL, option ]
      end
      def inspect ; "IAC WILL #{option_name}" ; end
      # case third_char
      # when OPT_BINARY
      #   self.send_bytes(IAC, DO, OPT_BINARY)
      # when OPT_ECHO
      #   self.send_bytes(IAC, DO, OPT_ECHO)
      # when OPT_SGA
      #   @telnet_option["SGA"] = true
      #   self.send_bytes(IAC, DO, OPT_SGA)
      # else
      #   self.send_bytes(IAC, DONT, third_char)
      # end
    end
    class Wont < Request
      def as_bytes
        [ IAC, WONT, option ]
      end
      def inspect ; "IAC WONT #{option_name}" ; end
      # case third_char
      # when OPT_ECHO
      #   self.send_bytes(IAC, DONT, OPT_ECHO)
      # when OPT_SGA
      #   @telnet_option["SGA"] = false
      #   self.send_bytes(IAC, DONT, OPT_SGA)
      # else
      #   self.send_bytes(IAC, DONT, third_char)
      # end
    end

    class Ayt < Base
      def as_bytes
        [ IAC, AYT ]
      end

      def inspect ; "IAC AYT" ; end
      # self.puts("nobody here but us aliens")
    end

    class Subnegotiation < Base
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
        @option_class = options[0]
        @options = options[1..-1]
      end

      def initialize(*args)
        initialize(args)
      end

      def as_bytes
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
          when OPT_LINEMODE
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

    def self.parse(socket)
      request_byte = socket.read_byte
      case request_byte
      when IAC
        # STDERR.puts "# Got escaped IAC"
        request_byte
      when DONT, DO, WONT, WILL
        option_byte = socket.read_byte
        if option_byte
          case request_byte
          when DONT
            # STDERR.puts "# Got DONT"
            Telnet::Options::Dont.build(option_byte)
          when DO
            # STDERR.puts "# Got DO"
            Telnet::Options::Do.build(option_byte)
          when WONT
            # STDERR.puts "# Got WONT"
            Telnet::Options::Wont.build(option_byte)
          when WILL
            # STDERR.puts "# Got WILL"
            Telnet::Options::Will.build(option_byte)
          end
        end
      when SB
        # STDERR.puts "# Got SB"
        bytes = [] of UInt8
        while (c = socket.read_byte) != SE
          next if c == IAC || c.nil?
          bytes << c
        end
        Telnet::Options::Subnegotiation.build(bytes)
      when GA
      when EL
      when EC
      when AYT
        STDERR.puts "# Got AYT"
        Telnet::Options::Ayt.build
      when AO
      when IP
      when BREAK
      when DM
      when NOP
      when SE
      when EOR
      when ABORT
      when SUSP
      when EOF
      when SYNCH
      end
    end

  end
end
