# TODO: Write documentation for Session
class Session
  property! user : User?
  
  def initialize
    @user = User.find!(1)
  end
  
  def shutdown
    # check permissions first
    BBS.shutdown!
  end
  
end
