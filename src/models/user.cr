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
end
