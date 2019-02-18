require "sam"
require "./env"

load_dependencies "jennifer"

# here you should load your app configuration if
# it will be needed to perform tasks
Sam.namespace "db" do
  namespace "schema" do
    desc "Outputs smth: requires 2 named arguments"
    task "load" do |t, args|
      puts args["f1"]
      t.invoke("1")
      t.invoke("schema:1")
      t.invoke("db:migrate")
      t.invoke("db:db:migrate")
      t.invoke("db:ping")
      t.invoke("din:dong")
      puts "------"
      t.invoke("2", {"f2" => 1})
    end

    task "1" do
      puts "1"
    end

    task "2", ["1", "db:migrate"] do |t, args|
      puts args.named["f2"].as(Int32) + 3
    end
  end

  task "seed" do
    # Contact.create(name: "John", age: 18)
    
    Jennifer::Adapter.adapter.transaction do |tx|
      main_menu = Menu.create(name: "Main Menu")
      section = MenuSection.create(name: "Message Center", menu_id: main_menu.id)
      # MenuEntry.create(menu_section_id: section.id, key: "N", name: "New Messages, All Subs", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "P", name: "Post a Message", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "S", name: "Scan Current Msg Base", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "#", name: "Enter NUmber of Sub", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "*", name: "List Subs Available", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "]", name: "Advance 1 Sub", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "[", name: "Retreat 1 Sub", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: ">", name: "Advance 1 Conference", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "<", name: "Retreat 1 Conference", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "H", name: "Hop to Another Sub", function: "")
      
      section = MenuSection.create(name: "Miscellaneous", menu_id: main_menu.id)
      MenuEntry.create(menu_section_id: section.id, key: "B", name: "BBS List", function: "bbs_list")
      # MenuEntry.create(menu_section_id: section.id, key: "I", name: "System Information", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "L", name: "Last Caller List", function: "")
      MenuEntry.create(menu_section_id: section.id, key: "O", name: "Log Off", function: "logout")
      MenuEntry.create(menu_section_id: section.id, key: "U", name: "User List", function: "list_users")
      # MenuEntry.create(menu_section_id: section.id, key: "V", name: "Voting Booth", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "Y", name: "Your Information", function: "")
      
      section = MenuSection.create(name: "System Features", menu_id: main_menu.id)
      # MenuEntry.create(menu_section_id: section.id, key: "T", name: "Transfer Section", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "G", name: "Read General Files", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "M", name: "Message of the Day", function: "")
      
      section = MenuSection.create(name: "Sysop Functions", menu_id: main_menu.id)
      # MenuEntry.create(menu_section_id: section.id, key: "X", name: "System Configuration", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "Z", name: "Info and Stats", function: "")
      # MenuEntry.create(menu_section_id: section.id, key: "E", name: "User Editor", function: "")
      MenuEntry.create(menu_section_id: section.id, key: "!", name: "Halt System", function: "shutdown")
    end
    
  end
end
Sam.help
