require "sam"
require "./env"
require "crypto/bcrypt/password"

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
      user = User.create(username: "tithonium", name: "Martin Tithonium", level: User::Levels::Super,    password_digest: Crypto::Bcrypt::Password.create("drowssap", cost: 10).to_s)
             User.create(username: "admin",     name: "Generic Admin",    level: User::Levels::Admin,    password_digest: Crypto::Bcrypt::Password.create("drowssap", cost: 10).to_s)
             User.create(username: "martian",   name: "Martin Tithonium", level: User::Levels::Standard, password_digest: Crypto::Bcrypt::Password.create("drowssap", cost: 10).to_s)
      
      board = MessageBoard.create(name: "General Discussion")
      message = Message.create(subject: "Howdy", body: "Nothing to see here.\nPellentesque consectetur est et nunc ultrices imperdiet.\n\nDuis semper, ante viverra viverra fermentum, ipsum est ultricies odio, scelerisque fermentum nibh nibh et justo. Cras tristique felis porttitor mauris aliquet, vitae facili-sis dui-vene-natis. Nulla malesuada interdum elit condimentum vestibulum. Nullam pellentesque orci in nisl semper rutrum. Sed eleifend tellus leo, eget pretium justo lobortis nec. In posuere id neque et imperdiet. Etiam ut sollicitudin felis. Nullam ultricies pretium nisi, sit amet elementum velit imperdiet non. Praesent sit amet ex odio. Vivamus vitae accumsan ante, ultricies accumsan lectus. Nam-volutpat-convallis-fe-lis-lacinia-rutrum.", message_board_id: board.id, message_index: 1, author_id: user.id)
      board.update(last_message_index: message.message_index)
      MessageBoardSubscription.create(last_read_index: 0, message_board_id: board.id, user_id: user.id)
      
      board = MessageBoard.create(name: "For Sale")
      message = Message.create(subject: "Stuff", body: "Stuff for sale.", message_board_id: board.id, message_index: 1, author_id: user.id)
      message = Message.create(subject: "Things", body: "Things for sale.", message_board_id: board.id, message_index: 2, author_id: user.id)
      board.update(last_message_index: message.message_index)
      MessageBoardSubscription.create(last_read_index: 0, message_board_id: board.id, user_id: user.id)
      
      board = MessageBoard.create(name: "Administrivia", required_level: 30000_i16)
      message = Message.create(subject: "Yo", body: "Don't make me regret this.", message_board_id: board.id, message_index: 1, author_id: user.id)
      board.update(last_message_index: message.message_index)
      MessageBoardSubscription.create(last_read_index: 0, message_board_id: board.id, user_id: user.id)

      board = MessageBoard.create(name: "Sekrits", public: false)
      message = Message.create(subject: "Sshhhh", body: "Don't tell nobody.", message_board_id: board.id, message_index: 1, author_id: user.id)
      board.update(last_message_index: message.message_index)
      MessageBoardSubscription.create(last_read_index: 0, message_board_id: board.id, user_id: user.id)

      MessageBoard.create(name: "Junk1", public: true)
      MessageBoard.create(name: "Junk2", public: true)
      MessageBoard.create(name: "Junk3", public: true)
      MessageBoard.create(name: "Junk4", public: true)
      MessageBoard.create(name: "Junk5", public: true)
      MessageBoard.create(name: "Junk6", public: true)
      MessageBoard.create(name: "Junk7", public: true)
      MessageBoard.create(name: "Junk8", public: true)
      MessageBoard.create(name: "Junk9", public: true)
      MessageBoard.create(name: "Junk10", public: true)
      MessageBoard.create(name: "Junk11", public: true)
      MessageBoard.create(name: "Junk12", public: true)
      MessageBoard.create(name: "Junk13", public: true)
      MessageBoard.create(name: "Junk14", public: true)
      MessageBoard.create(name: "Junk15", public: true)
      MessageBoard.create(name: "Junk16", public: true)
      MessageBoard.create(name: "Junk17", public: true)
      MessageBoard.create(name: "Junk18", public: true)
      MessageBoard.create(name: "Junk19", public: true)
      MessageBoard.create(name: "Junk20", public: true)
      MessageBoard.create(name: "Junk21", public: true)
      MessageBoard.create(name: "Junk22", public: true)
    end
    
  end
end
Sam.help
