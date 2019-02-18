require "./telnet"
require "./session"

# TODO: Write documentation for TelnetSession
class TelnetSession < Session

  def self.handle(socket : TCPSocket)
    self.new(socket).handle
  end
  
  getter :client
  
  def initialize(@socket : TCPSocket)
    puts "New TelnetSession connected to #{@socket.inspect}"
    @client = Telnet.new(socket: @socket)
  end
  
  def handle
    client.set_line_mode!
    
    puts "starting..."
    
    if menu = Menu.find(1)
      # puts menu.as_ansi.inspect
      loop do
        if BBS.shutdown?
          client.puts "System is shutting down."
          break
        end
        # client.print Ansi.clear
        client.puts menu.as_ansi
        client.print "> "
        option = client.read_char
        if entry = menu.match_key(option)
          client.puts(entry.key || option)
          break if entry.function == "logout"
          execute_function(entry.function)
        else
          client.puts
          # client.puts "I don't know #{option.inspect}."
        end
      end
    end
    client.puts "Bye!"
    
    puts "Finished with client"
  rescue ex
    puts ex.to_s
    puts ex.backtrace.inspect
  ensure
    if client
      client.close
      puts "Closed client"
    end
  end
  
end
