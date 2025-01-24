class Outfit
  attr_accessor :id
  attr_accessor :name
  attr_accessor :description
  attr_accessor :tags
  attr_accessor :price

  def initialize(id, name, description = '',price=0, tags = [])
    @id = id
    @name = name
    @description = description
    @tags = tags
    @price = price
  end

  def trainer_sprite_path()
    return nil
  end
end