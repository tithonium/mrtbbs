require "crypto/bcrypt/password"

class User < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    username: String,
    name: String,
    password_digest: String,
    level: Int16,
    created_at: Time?,
    updated_at: Time?,
  )

  module Levels
    Disabled = 0_i16
    Standard = 100_i16
    Elevated = 20000_i16
    Admin    = 30000_i16
    Super    = Int16::MAX
  end
  
  
  has_many :message_board_subscriptions, MessageBoardSubscription
  
  def self.authenticate(username, password) : self?
    user = self.where { _username == username }.first
    return nil if user.nil?
    return user if Crypto::Bcrypt::Password.new(user.password_digest) == password
    nil
  end

  def next_unread_message(board : MessageBoard?) : Message?
    if board
      if sub = self.message_board_subscriptions_query.where { _message_board_id == board.id }.first
        if message = board.next_since(sub.last_read_index)
          return message
        end
      end
    else
      self.message_board_subscriptions_query.order(message_board_id: :asc).each do |sub|
        board = sub.message_board.as(MessageBoard)
        if message = board.next_since(sub.last_read_index)
          return message
        end
      end
    end
    nil
  end
  
  def to_s
    "#{self.username} (##{id})"
  end

  def inspect
    "User(#{@id.inspect}: #{@username.inspect} / #{@name.inspect})"
  end
  
end
