require "./env"
require "./menus"
require "./telnet_session"

# TODO: Write documentation for BBS
class BBSClass
  VERSION = "0.1.0"
  
  ##################################################

  def list_sessions
    @sessions.map(&.inspect)
  end
  
  def list_users
    @sessions.map(&.user).compact.map(&.to_s)
  end
  
  def bbs_list
    ["* I don't know of any BBSes, sorry."]
  end

  def messages_list_boards
    MessageBoard.available(nil).to_a.map do |board|
      "* #{board.id} - #{board.name}"
    end
  end

  def shutdown!
    @shutdown = true
  end

  def shutdown?
    !!@shutdown
  end
  
  ##################################################
  
  def initialize
    @telnet_server = TCPServer.new("localhost", 1234)
    @shutdown = false
    @sessions = Set(Session).new(10)
  end
  
  def accept_telnet_clients
    while !shutdown? && (client_socket = @telnet_server.accept?)
      puts "Accepted telnet client #{client_socket.inspect}"
      @sessions << (session = TelnetSession.new(client_socket))
      spawn do
        session.handle
        @sessions.delete session
      end
    end
  end

  def accept_http_clients
    # while !shutdown? && (client_socket = @http_server.accept?)
    #   puts "Accepted http client #{client_socket.inspect}"
    #   spawn HTTPSession.handle(client_socket)
    # end
  end
  
  def go
    spawn accept_telnet_clients
    spawn accept_http_clients
    while !shutdown?
      sleep 1
    end
    puts "Shutting down application."
  end
  
end

BBS = BBSClass.new
