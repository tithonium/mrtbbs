require "./env"
require "./telnet_session"

# TODO: Write documentation for BBS
class BBSClass
  VERSION = "0.1.0"
  
  ##################################################
  
  def list_users
    ["You"]
  end
  
  def bbs_list
    ["* I don't know of any BBSes, sorry."]
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
  end
  
  def handle_tcp_clients
    while !shutdown? && (client_socket = @telnet_server.accept?)
      puts "Accepted client #{client_socket.inspect}"
      spawn TelnetSession.handle(client_socket)
    end
  end
  
  def go
    spawn handle_tcp_clients
    while !shutdown?
      sleep 1
    end
    puts "Shutting down application."
  end
  
end

BBS = BBSClass.new
