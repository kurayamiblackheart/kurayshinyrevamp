class FusionPreviewScreen < DoublePreviewScreen
  attr_reader :poke1
  attr_reader :poke2
  attr_reader :fusedPokemon

  attr_writer :draw_types
  attr_writer :draw_level

  BACKGROUND_PATH = "Graphics/Pictures/DNAbg"


  def initialize(poke1,poke2, usingSuperSplicers=false)
    super(poke1,poke2)
    @draw_types = true
    @draw_level = true
    @draw_sprite_info=true

    #@viewport = viewport
    @poke1 = poke1
    @poke2 = poke2
    @fusedPokemon=nil
    new_level = calculateFusedPokemonLevel(poke1.level, poke2.level, usingSuperSplicers)

    fusion_left = (poke1.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number
    fusion_right = (poke2.species_data.id_number) * NB_POKEMON + poke1.species_data.id_number

    @picture1 = draw_window(fusion_left,new_level,20,30,poke2.shiny?,poke2.shinyValue?,poke2.shinyR?,poke2.shinyG?,poke2.shinyB?,poke2.shinyKRS?)
    @picture2 = draw_window(fusion_right,new_level,270,30,poke1.shiny?,poke1.shinyValue?,poke1.shinyR?,poke1.shinyG?,poke1.shinyB?,poke1.shinyKRS?)

    @sprites["picture1"] = @picture1
    @sprites["picture2"] = @picture2

  end

  def getBackgroundPicture
    super
  end
end