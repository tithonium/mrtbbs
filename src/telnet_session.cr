require "./telnet"
require "./session"

# TODO: Write documentation for TelnetSession
class TelnetSession < Session

  def self.handle(socket : TCPSocket)
    self.new(socket).handle
  end
  
  getter client : Telnet
  
  def initialize(@socket : TCPSocket)
    super()
    puts "New TelnetSession connected to #{@socket.inspect}"
    @client = Telnet.new(socket: @socket)
    puts "New Telnet client initialized: #{@client.inspect}"
  end
  
  def inspect
    "TelnetSession(user=#{@user.inspect} f=#{@current_function.inspect}, b=#{@current_board.inspect})"
  end
  
  def handle
    client.set_line_mode!
    
    puts "starting..."

    loop do
      if BBS.shutdown?
        client.puts "System is shutting down."
        break
      end
      # client.print Ansi.clear
      if client.ansi?
        client.puts current_menu.as_ansi(@client.screen_width)
      else
        client.puts current_menu.as_text
      end
      client.print "> "
      option = client.read_char
      if entry = current_menu.match_key(option)
        client.puts(entry.key || option)
        break if entry.function == "logout"
        execute_function(entry.function)
      else
        client.puts
        # client.puts "I don't know #{option.inspect}."
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
  
  
  def current_menu
    @current_menu ||= case self.current_function
    when :main_menu
      STDERR.puts "#{__FILE__}:#{__LINE__}"
      Views::Root.new(self)
    when :sysop
      STDERR.puts "#{__FILE__}:#{__LINE__}"
      Views::Sysop.new(self)
    when :board
      STDERR.puts "#{__FILE__}:#{__LINE__}"
      raise "Oops" if self.current_board.nil?
      Views::MessageBoard.new(self)
    when :read_message
      STDERR.puts "#{__FILE__}:#{__LINE__}"
      raise "Oops" if self.current_message.nil?
      Views::MessageView.new(self)
    else
      STDERR.puts "#{__FILE__}:#{__LINE__}"
      raise "Oops"
    end
  end
  
  
  def execute_function(name : String)
    return if current_menu.execute_function(name)
    case name
    when "list_users"
      list_users
    when "list_sessions"
      list_sessions
    when "bbs_list"
      bbs_list
    when "messages_list_boards"
      messages_list_boards
    when "shutdown"
      shutdown
    when "main_menu"
      go_to_menu(:main_menu)
    when "mode_sysop"
      go_to_menu(:sysop)
    when "read_next_unread_message"
      read_next_unread_message
    when ""
      # undefined command, ignore it
    else
      client.puts "ok, sure, #{name.inspect}, right? Uhh....."
    end
  end
  
  ########################################
  
  def go_to_menu(function : Symbol)
    @current_function = function
    @current_board = nil
    @current_menu = nil
  end
  
  def go_to_board(board : MessageBoard, function : Symbol? = :board)
    @current_function = function
    @current_board = board
    @current_menu = nil
  end
  
  def read_next_unread_message
    if message = self.user.next_unread_message
      @current_function = :read_message
      @current_board = board = message.message_board.as(MessageBoard)
      @current_message = message
      @current_menu = nil
      if subscription = board.subscription_for(self.user)
        subscription.update(last_read_index: message.message_index) if message.message_index > subscription.last_read_index
      end
    else
      @current_message = message
      if @current_board
        @current_function = :board
      else
        @current_function = :main_menu
      end
      @current_menu = nil
    end
  end
  
  def list_sessions
    client.puts
    client.puts "================"
    client.puts "Current Sessions"
    client.puts "================"
    BBS.list_sessions.each_with_index do |user, idx|
      client.puts "#{idx + 1}) #{user}"
    end
    client.puts
  end
  
  def list_users
    client.puts
    client.puts "============="
    client.puts "Current Users"
    client.puts "============="
    BBS.list_users.each_with_index do |user, idx|
      client.puts "#{idx + 1}) #{user}"
    end
    client.puts
  end
  
  def bbs_list
    client.puts
    client.puts "========"
    client.puts "BBS List"
    client.puts "========"
    BBS.bbs_list.each_with_index do |bbs, idx|
      client.puts "#{idx + 1}) #{bbs}"
    end
    client.puts
  end

  def messages_list_boards
    client.puts
    client.puts "========"
    client.puts "Board List"
    client.puts "========"
    BBS.messages_list_boards(current_user).each do |board|
      client.puts board
    end
    client.puts
  end
  
end
