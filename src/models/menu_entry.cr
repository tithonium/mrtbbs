class MenuEntry < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    name: String,
    key: String?,
    function: String,
    menu_section_id: Int32?,
    created_at: Time?,
    updated_at: Time?,
  )

  belongs_to :menu_section, MenuSection

  def match_key(option : String) : Bool
    key == option
  end
  
end
