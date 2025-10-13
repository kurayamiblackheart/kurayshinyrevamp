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

    one_shiny = false
    if poke1.shiny? || poke2.shiny?
      one_shiny = true
    end
    use1shinyValue = poke1.shinyValue?
    use1shinyR = poke1.shinyR?
    use1shinyG = poke1.shinyG?
    use1shinyB = poke1.shinyB?
    use1shinyKRS = poke1.shinyKRS?
    use1shinyOmega = poke1.shinyOmega?
    if $PokemonSystem.shinyfusedye == 1 && poke2.shiny?
      use1shinyValue = poke2.shinyValue?
      use1shinyR = poke2.shinyR?
      use1shinyG = poke2.shinyG?
      use1shinyB = poke2.shinyB?
      use1shinyKRS = poke2.shinyKRS?
      use1shinyOmega = poke2.shinyOmega?
    end

    @picture1 = draw_window(fusion_left,new_level,20,30,one_shiny,use1shinyValue,use1shinyR,use1shinyG,use1shinyB,use1shinyKRS,use1shinyOmega)
    @picture2 = draw_window(fusion_right,new_level,270,30,one_shiny,poke2.shinyValue?,poke2.shinyR?,poke2.shinyG?,poke2.shinyB?,poke2.shinyKRS?,poke2.shinyOmega?)

    @sprites["picture1"] = @picture1
    @sprites["picture2"] = @picture2

  end

  def getBackgroundPicture
    super
  end
end