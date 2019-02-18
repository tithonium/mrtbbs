# TODO: Write documentation for Session
class Session
  
  def execute_function(name : String)
    case name
    when "list_users"
      list_users
    when "bbs_list"
      bbs_list
    when "shutdown"
      shutdown
    when ""
      # undefined command, ignore it
    else
      client.puts "ok, sure, #{name.inspect}, right? Uhh....."
    end
  end
  
  ########################################
  
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

  def shutdown
    # check permissions first
    BBS.shutdown!
  end
  
end
