# Barebones version of PIF class to maintain save compatibility with KIF
class PIFSprite
  attr_accessor :type
  attr_accessor :head_id
  attr_accessor :body_id
  attr_accessor :alt_letter
  attr_accessor :local_path

  #types:
  # :AUTOGEN, :CUSTOM, :BASE
  def initialize(type, head_id, body_id, alt_letter = "")
    @type = type
    @head_id = head_id
    @body_id = body_id
    @alt_letter = alt_letter
    @local_path = nil
  end
end

def pif_sprite_from_spritename(spritename, autogen = false)
  spritename = spritename.split(".png")[0] #remove the extension
  if spritename =~ /^(\d+)\.(\d+)([a-zA-Z]*)$/ # Two numbers with optional letters
    type = :CUSTOM
    head_id = $1.to_i # Head (e.g., "1" in "1.2.png")
    body_id = $2.to_i # Body (e.g., "2" in "1.2.png")
    alt_letter = $3 # Optional trailing letter (e.g., "a" in "1.2a.png")

  elsif spritename =~ /^(\d+)([a-zA-Z]*)$/ # One number with optional letters
    type = :BASE
    head_id = $1.to_i # Head (e.g., "1" in "1.png")
    alt_letter = $2 # Optional trailing letter (e.g., "a" in "1a.png")
  else
    echoln "Invalid sprite format: #{spritename}"
    return nil
  end
  type = :AUTOGEN if autogen

  pif_sprite = PIFSprite.new(type, head_id, body_id, alt_letter)
  pif_sprite.local_path = check_for_local_sprite(pif_sprite)
  
  return pif_sprite
end

def check_for_local_sprite(pif_sprite)
  return pif_sprite.local_path if pif_sprite.local_path
  if pif_sprite.type == :BASE
    sprite_path = "#{Settings::CUSTOM_BASE_SPRITES_FOLDER}#{pif_sprite.head_id}#{pif_sprite.alt_letter}.png"
  else
    sprite_path = "#{Settings::CUSTOM_BATTLERS_FOLDER_INDEXED}#{pif_sprite.head_id}/#{pif_sprite.head_id}.#{pif_sprite.body_id}#{pif_sprite.alt_letter}.png"
  end
  return pbResolveBitmap(sprite_path)
end
