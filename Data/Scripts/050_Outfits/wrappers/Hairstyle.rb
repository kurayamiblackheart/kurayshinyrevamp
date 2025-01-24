class Hairstyle < Outfit
  attr_accessor :type
  def initialize(id, name, description = '',price=0, tags = [])
    super
    @type = :HAIR
  end

  def trainer_sprite_path()
    return getTrainerSpriteHairFilename(self.id)
  end

end