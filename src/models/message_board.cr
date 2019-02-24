class MessageBoard < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    name: String,
    last_message_index: { type: Int32, default: 0 },
    public: { type: Bool, default: true },
    created_at: Time?,
    updated_at: Time?,
  )

  scope :available { |user| where { _public == true } }

  has_many :messages, Message
  has_many :message_board_subscriptions, MessageBoardSubscription

  def next_since(last_read_index : Int32) : Message?
    self.messages_query.order(message_index: :asc).where{ _message_index > last_read_index}.first
  end
  
  def subscription_for(user : User) : MessageBoardSubscription?
    self.message_board_subscriptions_query.where{ _user_id == user.id }.first
  end
  
end
