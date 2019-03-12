require "./env"
require "./views"
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

  def messages_list_boards(user)
    board_ids = MessageBoard.available(user && user.level).pluck(:id)
    board_ids |= user.message_board_subscriptions.map(&.message_board_id).compact if user
    MessageBoard.where { _id.in(board_ids) }.to_a.map do |board|
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
