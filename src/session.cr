require "./telnet"

class Session
  property! user : User?

  getter current_function : Symbol
  getter current_board : ::MessageBoard?
  getter current_message : ::Message?
  
  def self.handle(socket : TCPSocket)
    self.new(socket).handle
  end
  
  getter client : Telnet
  
  def initialize(@socket : TCPSocket)
    @current_function = :main_menu
    puts "New Session connected to #{@socket.inspect}"
    @client = Telnet.new(socket: @socket)
    puts "New Telnet client initialized: #{@client.inspect}"
  end
  
  def inspect
    "Session(user=#{@user.inspect} f=#{@current_function.inspect}, b=#{@current_board.inspect})"
  end
  
  def handle
    client.set_line_mode!
    
    puts "starting..."

    return unless do_login_or_signup

    loop do
      break if shutdown?
      # client.print Ansi.clear
      if client.ansi?
        client.puts current_menu.as_ansi(@client.screen_width)
      else
        client.puts current_menu.as_text
      end
      client.print "> "
      option = client.read_char(current_menu.keys)
      if option && (entry = current_menu.match_key(option))
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
  
  def do_login_or_signup
    @user = User.find(1);return true
    client.print "(L)ogin or (S)ignup?"
    option = client.read_char("LS", true)
    client.puts " #{option}"
    case option
    when 'L'
      handle_login
    when 'S'
      handle_signup
    else
      client.puts "Bye!"
      false
    end
  end
  
  def handle_login
    client.print "Neat! "
    loop do
      return if shutdown?
      client.print "What's your username? "
      username = client.gets.chomp
      client.print "And your password? "
      client.disable_client_echo!
      password = client.gets.chomp
      client.enable_client_echo!
      client.puts
      if user = User.authenticate(username, password)
        client.puts "Howdy, #{user.name}."
        client.puts
        @user = user
        return true
      else
        client.puts "Nope."
        client.print "Let's try again. "
      end
    end
    false
  end
  
  def handle_signup
    client.puts "Not yet, sorry."
    false
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
      if self.current_board.nil?
        Views::MessageBoardList.new(self)
      else
        Views::MessageBoard.new(self)
      end
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
    if message = self.user.next_unread_message(@current_board)
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
    @current_function = :board
    @current_board = nil
    @current_message = nil
    @current_menu = nil
  end

  def current_user
    user.as(User)
  end
  
  def current_user?
    !!@user
  end
  
  def shutdown
    # check permissions first
    BBS.shutdown!
  end
  
  def shutdown?
    if BBS.shutdown?
      client.puts "System is shutting down."
      return true
    end
    false
  end

end
