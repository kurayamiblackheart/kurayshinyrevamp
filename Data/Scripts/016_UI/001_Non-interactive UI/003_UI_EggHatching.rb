#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatch_Scene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @nicknamed=false
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    # Create background image
    addBackgroundOrColoredPlane(@sprites,"background","hatchbg",
       Color.new(248,248,248),@viewport)
    # Create egg sprite/Pokémon sprite
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Bottom)
    @sprites["pokemon"].x = Graphics.width/2
    @sprites["pokemon"].y = 264+56   # 56 to offset the egg sprite
    @sprites["pokemon"].setSpeciesBitmap(@pokemon.species, @pokemon.gender,
                                         @pokemon.form, @pokemon.shiny?,
                                         false, false, true)   # Egg sprite
    # Load egg cracks bitmap
    crackfilename = sprintf("Graphics/Battlers/Eggs/%s_cracks", @pokemon.species)
    crackfilename = sprintf("Graphics/Battlers/Eggs/000_cracks") if !pbResolveBitmap(crackfilename)
    crackfilename=pbResolveBitmap(crackfilename)
    @hatchSheet=AnimatedBitmap.new(crackfilename)
    # Create egg cracks sprite
    @sprites["hatch"]=SpriteWrapper.new(@viewport)
    @sprites["hatch"].x = @sprites["pokemon"].x
    @sprites["hatch"].y = @sprites["pokemon"].y
    @sprites["hatch"].ox = @sprites["pokemon"].ox
    @sprites["hatch"].oy = @sprites["pokemon"].oy
    @sprites["hatch"].bitmap = @hatchSheet.bitmap
    @sprites["hatch"].src_rect = Rect.new(0,0,@hatchSheet.width/5,@hatchSheet.height)
    @sprites["hatch"].visible = false
    # Create flash overlay
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    # Start up scene
    pbFadeInAndShow(@sprites)
  end

  #KurayX sent hatched to PC asking
  def pbMain(eggindex)
    nb_eggs_hatched = pbGet(VAR_NB_EGGS_HATCHED)
    pbSet(VAR_NB_EGGS_HATCHED,nb_eggs_hatched+1)
    pbBGMPlay("Evolution")
    # Egg animation
    updateScene(Graphics.frame_rate*15/10)
    pbPositionHatchMask(0)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(Graphics.frame_rate*2/10)
    pbPositionHatchMask(1)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(Graphics.frame_rate*4/10)
    pbPositionHatchMask(2)
    pbSEPlay("Battle ball shake")
    swingEgg(8,2)
    updateScene(Graphics.frame_rate*4/10)
    pbPositionHatchMask(3)
    pbSEPlay("Battle ball shake")
    swingEgg(16,4)
    updateScene(Graphics.frame_rate*2/10)
    pbPositionHatchMask(4)
    pbSEPlay("Battle recall")
    # Fade and change the sprite
    fadeTime = Graphics.frame_rate*4/10
    toneDiff = (255.0/fadeTime).ceil
    for i in 1..fadeTime
      @sprites["pokemon"].tone=Tone.new(i*toneDiff,i*toneDiff,i*toneDiff)
      @sprites["overlay"].opacity=i*toneDiff
      updateScene
    end
    updateScene(Graphics.frame_rate*3/4)
    @sprites["pokemon"].setPokemonBitmap(@pokemon) # Pokémon sprite
    @sprites["pokemon"].x = Graphics.width/2
    @sprites["pokemon"].y = 264
    @sprites["pokemon"].zoom_x=Settings::FRONTSPRITE_SCALE
    @sprites["pokemon"].zoom_y=Settings::FRONTSPRITE_SCALE

    @pokemon.species_data.apply_metrics_to_sprite(@sprites["pokemon"], 1)
    @sprites["hatch"].visible=false
    for i in 1..fadeTime
      @sprites["pokemon"].tone=Tone.new(255-i*toneDiff,255-i*toneDiff,255-i*toneDiff)
      @sprites["overlay"].opacity=255-i*toneDiff
      updateScene
    end
    @sprites["pokemon"].tone=Tone.new(0,0,0)
    @sprites["overlay"].opacity=0
    # Finish scene
    frames = GameData::Species.cry_length(@pokemon)
    @pokemon.play_cry
    updateScene(frames)
    pbBGMStop()
    pbMEPlay("Evolution success")
    @pokemon.name = nil
    pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]", @pokemon.name)) { update }
    if pbConfirmMessage(
        _INTL("Would you like to nickname the newly hatched {1}?", @pokemon.name)) { update }
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", @pokemon.name),
                                  0, Pokemon::MAX_NAME_SIZE, "", @pokemon, true)
      @pokemon.name = nickname
      @nicknamed = true
    end
    #KurayX sent hatched to PC asking
    if pbConfirmMessage(
      _INTL("Do you wish to send {1} to the PC?", @pokemon.name)) { update }
      $PokemonStorage.pbStoreCaught(@pokemon)
      $Trainer.party[eggindex] = nil
      $Trainer.party.compact!
      pbMessage(_INTL("{1} was sent to the PC.", @pokemon.name)) { update }
    end
    if !$Trainer.pokedex.owned?(@pokemon.species)
      $Trainer.pokedex.register(@pokemon)
      $Trainer.pokedex.set_owned(@pokemon.species)
      pbMessage(_INTL("{1}'s data was added to the Pokédex", @pokemon.name))
      pbShowPokedex(@pokemon.species)
    end
    $Trainer.pokedex.register_unfused_pkmn(@pokemon)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update } if !@nicknamed
    pbDisposeSpriteHash(@sprites)
    @hatchSheet.dispose
    @viewport.dispose
  end

  def pbPositionHatchMask(index)
    @sprites["hatch"].src_rect.x = index*@sprites["hatch"].src_rect.width
  end

  def swingEgg(speed,swingTimes=1)
    @sprites["hatch"].visible = true
    speed = speed.to_f*20/Graphics.frame_rate
    amplitude = 8
    targets = []
    swingTimes.times do
      targets.push(@sprites["pokemon"].x+amplitude)
      targets.push(@sprites["pokemon"].x-amplitude)
    end
    targets.push(@sprites["pokemon"].x)
    targets.each_with_index do |target,i|
      loop do
        break if i%2==0 && @sprites["pokemon"].x>=target
        break if i%2==1 && @sprites["pokemon"].x<=target
        @sprites["pokemon"].x += speed
        @sprites["hatch"].x    = @sprites["pokemon"].x
        updateScene
      end
      speed *= -1
    end
    @sprites["pokemon"].x = targets[targets.length-1]
    @sprites["hatch"].x   = @sprites["pokemon"].x
  end

  def updateScene(frames=1)   # Can be used for "wait" effect
    frames.times do
      Graphics.update
      Input.update
      self.update
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonEggHatchScreen
  def initialize(scene)
    @scene=scene
  end

  #KurayX sent hatched to PC asking
  def pbStartScreen(pokemon, eggindex)
    @scene.pbStartScene(pokemon)
    @scene.pbMain(eggindex)
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
#KurayX sent hatched to PC asking
def pbHatchAnimation(pokemon, eggindex)
  pbMessage(_INTL("Huh?\1"))
  pbFadeOutInWithMusic {
    scene=PokemonEggHatch_Scene.new
    screen=PokemonEggHatchScreen.new(scene)
    #KurayX sent hatched to PC asking
    screen.pbStartScreen(pokemon, eggindex)
  }
  return true
end

#KurayX sent hatched to PC asking
def pbHatch(pokemon, eggindex)
  speciesname = pokemon.speciesName
  pokemon.name           = nil
  pokemon.owner          = Pokemon::Owner.new_from_trainer($Trainer)
  pokemon.happiness      = 120
  pokemon.timeEggHatched = pbGetTimeNow
  pokemon.obtain_method  = 1   # hatched from egg
  pokemon.hatched_map    = $game_map.map_id
  if player_on_hidden_ability_map
    chosenAbility = pokemon.getAbilityList.sample #format: [[:ABILITY, index],...]
    # pokemon.ability = chosenAbility[0]
    pokemon.ability_index = chosenAbility[1]
  end


  pokemon.record_first_moves
  #KurayX sent hatched to PC asking
  if !pbHatchAnimation(pokemon, eggindex)
    pbMessage(_INTL("Huh?\1"))
    pbMessage(_INTL("...\1"))
    pbMessage(_INTL("... .... .....\1"))
    pbMessage(_INTL("{1} hatched from the Egg!", speciesname))
    if pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?", speciesname))
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname),
                                    0, Pokemon::MAX_NAME_SIZE, "", pokemon)
      pokemon.name = nickname
    end
    #KurayX sent hatched to PC asking
    if pbConfirmMessage(
      _INTL("Do you wish to send {1} to the PC?", pokemon.name))
      $PokemonStorage.pbStoreCaught(pokemon)
      $Trainer.party[eggindex] = nil
      $Trainer.party.compact!
      pbMessage(_INTL("{1} was sent to the PC.", pokemon.name))
    end
  end
end

#KurayX sent hatched to PC asking
Events.onStepTaken += proc { |_sender,_e|
  egglocation = -1
  for egg in $Trainer.party
    egglocation += 1
    next if egg.steps_to_hatch <= 0
    egg.steps_to_hatch -= 1
    egg.steps_to_hatch -= 1 if isWearingClothes(CLOTHES_BREEDER)
    for i in $Trainer.pokemon_party
      next if !i.hasAbility?(:FLAMEBODY) && !i.hasAbility?(:MAGMAARMOR)
      egg.steps_to_hatch -= 1
      break
    end
    if egg.steps_to_hatch <= 0
      egg.steps_to_hatch = 0
      pbHatch(egg, egglocation)
    end
  end
}
