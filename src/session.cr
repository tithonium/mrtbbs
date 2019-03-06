# TODO: Write documentation for Session
class Session
  property! user : User?

  getter current_function : Symbol
  getter current_board : ::MessageBoard?
  getter current_message : ::Message?
  
  def initialize
    @user = User.find!(1)
    @current_function = :main_menu
  end
  
  def shutdown
    # check permissions first
    BBS.shutdown!
  end
  
end
