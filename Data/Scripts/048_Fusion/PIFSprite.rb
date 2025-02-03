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