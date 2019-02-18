module OldMenus
  class Main < OldMenu
    
    def initialize
      super
      
      sections << (s = OldMenus::Section.new name: "Message Center")
      s << OldMenus::Entry.new key: 'N', name: "New Messages, All Subs"
      s << OldMenus::Entry.new key: 'P', name: "Post a Message"
      s << OldMenus::Entry.new key: 'S', name: "Scan Current Msg Base"
      s << OldMenus::Entry.new key: '#', name: "Enter NUmber of Sub"
      s << OldMenus::Entry.new key: '*', name: "List Subs Available"
      s << OldMenus::Entry.new key: ']', name: "Advance 1 Sub"
      s << OldMenus::Entry.new key: '[', name: "Retreat 1 Sub"
      s << OldMenus::Entry.new key: '>', name: "Advance 1 Conference"
      s << OldMenus::Entry.new key: '<', name: "Retreat 1 Conference"
      s << OldMenus::Entry.new key: 'H', name: "Hop to Another Sub"

      sections << (s = OldMenus::Section.new name: "Miscellaneous")
      s << OldMenus::Entry.new key: 'B', name: "BBS List"
      s << OldMenus::Entry.new key: 'I', name: "System Information"
      s << OldMenus::Entry.new key: 'L', name: "Last Caller List"
      s << OldMenus::Entry.new key: 'O', name: "Log Off"
      s << OldMenus::Entry.new key: 'U', name: "User List"
      s << OldMenus::Entry.new key: 'V', name: "Voting Booth"
      s << OldMenus::Entry.new key: 'Y', name: "Your Information"
      
      sections << (s = OldMenus::Section.new name: "System Features")
      s << OldMenus::Entry.new key: 'T', name: "Transfer Section"
      s << OldMenus::Entry.new key: 'G', name: "Read General Files"
      s << OldMenus::Entry.new key: 'M', name: "Message of the Day"

      sections << (s = OldMenus::Section.new name: "Sysop Functions")
      s << OldMenus::Entry.new key: 'X', name: "System Configuration"
      s << OldMenus::Entry.new key: 'Z', name: "Info and Stats"
      s << OldMenus::Entry.new key: 'E', name: "User Editor"
    end
    
  end
end
