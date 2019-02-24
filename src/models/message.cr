class Message < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    message_index: Int32,
    subject: String,
    body: String,
    message_board_id: Int32,
    author_id: Int32,
    created_at: Time?,
    updated_at: Time?,
  )

  belongs_to :message_board, MessageBoard
  belongs_to :author, User, nil, :author_id
end
