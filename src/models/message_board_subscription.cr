class MessageBoardSubscription < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    last_read_index: Int32,
    message_board_id: Int32,
    user_id: Int32,
    created_at: Time?,
    updated_at: Time?,
  )

  belongs_to :message_board, MessageBoard
  belongs_to :user, User
end
