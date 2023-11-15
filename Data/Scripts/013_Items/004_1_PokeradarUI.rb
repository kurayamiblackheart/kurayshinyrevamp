class PokeRadar_UI
  attr_reader :sprites
  attr_reader :disposed

  ICON_START_X = 50
  ICON_START_Y = 5

  ICON_MARGIN_X = 50
  ICON_MARGIN_Y = 50

  ICON_LINE_END = 450


  def initialize(seenPokemon = [], unseenPokemon = [], rarePokemon = [])
    @seen_pokemon = seenPokemon
    @unseen_pokemon = unseenPokemon
    @rare_pokemon = rarePokemon

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokeradar/banner")
    @sprites["background"].zoom_x = 2
    @sprites["background"].zoom_y = 2

    @sprites["background"].visible = true

    @current_x = 50
    @current_y = 0
    displaySeen()
    displayUnseen()
    displayRare()
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose if @viewport != nil
  end

  #display rare with a (circle?) under the sprite to highlight it
  # blacken if not seen
  def displayRare()
    @rare_pokemon.each { |pokemon|
      blackened = !$Trainer.seen?(pokemon)
      addPokemonIcon(pokemon,blackened,true)
    }
  end

  def displaySeen()
    @seen_pokemon.each { |pokemonId|
      addPokemonIcon(pokemonId, false )
    }
  end

  def displayUnseen()
    @unseen_pokemon.each { |pokemonId|
      addPokemonIcon(pokemonId, true)
    }
  end

  def addPokemonIcon(species, blackened = false, rare=false)
    pokemonId=dexNum(species)
    iconId = _INTL("{1}", species)

    pokemonBitmap = pbCheckPokemonIconFiles(species)

    if rare
      outlineSprite = IconSprite.new(@current_x, @current_y)
      outlineSprite.setBitmap("Graphics/Pictures/Pokeradar/highlight")
      outlineSprite.visible=true
      @sprites[iconId + "_outline"] = outlineSprite
    end

    if pokemonId > NB_POKEMON
      iconSprite = createFusionIcon(pokemonId,@current_x,@current_y)
    else
      iconSprite = IconSprite.new(@current_x, @current_y)
      iconSprite.setBitmap(pokemonBitmap)
    end

    @sprites[iconId] = iconSprite
    @sprites[iconId].src_rect.width /= 2


    if blackened
        @sprites[iconId].setColor(0,0,0,200)
    end
    @sprites[iconId].visible = true
    @sprites[iconId].x = @current_x
    @sprites[iconId].y = @current_y
    @sprites[iconId].z = 100

    @current_x += ICON_MARGIN_X
    if @current_x >= ICON_LINE_END
      @current_x = ICON_START_X
      @current_y +=ICON_MARGIN_Y
      @sprites["background"].zoom_y += 1
    end

  end



  #KurayX Custom icons
  def customIcons(dex_number)
    return nil if dex_number == nil
    if dex_number <= Settings::NB_POKEMON
      return get_notfusedicon_sprite_path(dex_number)
    else
      if dex_number >= Settings::ZAPMOLCUNO_NB
        specialPath = getSpecialIconName(dex_number)
        return pbResolveBitmap(specialPath)
        head_id=nil
      else
        body_id = getBodyID(dex_number)
        head_id = getHeadID(dex_number, body_id)
        return get_customicons_sprite_path(head_id,body_id)
        # folder = head_id.to_s
        # filename = sprintf("%s.%s.png", head_id, body_id)
      end
    end
  end

  #KurayX Custom icons
  def getSpecialIconName(dexNum)
    base_path = "Graphics/Battlers/special/"
    case dexNum
    when Settings::ZAPMOLCUNO_NB..Settings::ZAPMOLCUNO_NB + 1
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 2
      return sprintf(base_path + "243.244.245")
    when Settings::ZAPMOLCUNO_NB + 3
      return sprintf(base_path +"340.341.342")
    when Settings::ZAPMOLCUNO_NB + 4
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 5
      return sprintf(base_path +"349.350.351")
    when Settings::ZAPMOLCUNO_NB + 6
      return sprintf(base_path +"151.251.381")
    when Settings::ZAPMOLCUNO_NB + 11
      return sprintf(base_path +"150.348.380")
      #starters
    when Settings::ZAPMOLCUNO_NB + 7
      return sprintf(base_path +"3.6.9")
    when Settings::ZAPMOLCUNO_NB + 8
      return sprintf(base_path +"154.157.160")
    when Settings::ZAPMOLCUNO_NB + 9
      return sprintf(base_path +"278.281.284")
    when Settings::ZAPMOLCUNO_NB + 10
      return sprintf(base_path +"318.321.324")
      #starters prevos
    when Settings::ZAPMOLCUNO_NB + 12
      return sprintf(base_path +"1.4.7")
    when Settings::ZAPMOLCUNO_NB + 13
      return sprintf(base_path +"2.5.8")
    when Settings::ZAPMOLCUNO_NB + 14
      return sprintf(base_path +"152.155.158")
    when Settings::ZAPMOLCUNO_NB + 15
      return sprintf(base_path +"153.156.159")
    when Settings::ZAPMOLCUNO_NB + 16
      return sprintf(base_path +"276.279.282")
    when Settings::ZAPMOLCUNO_NB + 17
      return sprintf(base_path +"277.280.283")
    when Settings::ZAPMOLCUNO_NB + 18
      return sprintf(base_path +"316.319.322")
    when Settings::ZAPMOLCUNO_NB + 19
      return sprintf(base_path +"317.320.323")
    when Settings::ZAPMOLCUNO_NB + 20 #birdBoss Left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 21 #birdBoss middle
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 22 #birdBoss right
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 23 #sinnohboss left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 24 #sinnohboss middle
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 25 #sinnohboss right
      return sprintf(base_path +"invisible")
    else
      return sprintf(base_path + "000")
    end
  end

  #Just in case (KurayX) KurayX Custom icons
  def get_notfusedicon_sprite_path(dex_number)
    folder = dex_number.to_s
    filename = sprintf("%s_i.png", dex_number)
  
    if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(dex_number)
      return $PokemonGlobal.alt_sprite_substitutions[dex_number]
    end
  
    normal_path = Settings::BATTLERS_FOLDER + folder + "/" + filename
    lightmode_path = Settings::BATTLERS_FOLDER + filename
    return normal_path if pbResolveBitmap(normal_path)
    return lightmode_path
  end

  #Just in case (KurayX) KurayX Custom icons
  def get_customicons_sprite_path(head_id,body_id)
    #Swap path if alt is selected for this pokemon
    dex_num = getSpeciesIdForFusion(head_id,body_id)
    if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(dex_num)
      heredoing = $PokemonGlobal.alt_sprite_substitutions[dex_num]
      heredoing = heredoing[0..-5] + "_i.png"
      return heredoing if pbResolveBitmap(heredoing)
      return false
    end
  
    #Try local custom sprite
    filename = sprintf("%s.%s_i.png", head_id, body_id)
    local_custom_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" +filename
    return local_custom_path if pbResolveBitmap(local_custom_path)
    return false
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def createFusionIcon(pokemonId,x,y)
    bodyPoke_number = getBodyID(pokemonId)
    headPoke_number = getHeadID(pokemonId, bodyPoke_number)


    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    bitmap1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke))
    bitmap2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke))

    #KurayX Github
    directory_name = "Graphics/Pokemon/FusionIcons"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    # bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", pokemonId)
    dexNum = pokemonId
    #KurayX Custom icons
    if dexNum.is_a?(Symbol)
      dexNum = GameData::Species.get(dexNum).id_number
    end
    customiconname = customIcons(dexNum)
    if customiconname
      result_bitmap = AnimatedBitmap.new(customiconname)
    else
      bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
      headPokeFileName = GameData::Species.icon_filename(headPoke)
      bitmapPath = sprintf("%s.png", bitmapFileName)
      IO.copy_stream(headPokeFileName, bitmapPath)
      result_bitmap = AnimatedBitmap.new(bitmapPath)

      for i in 0..bitmap1.width-1
        for j in ((bitmap1.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)..bitmap1.height-1
          temp = bitmap2.bitmap.get_pixel(i, j)
          result_bitmap.bitmap.set_pixel(i, j, temp)
        end
      end
    end
    icon = IconSprite.new(x, y)
    icon.setBitmapDirectly(result_bitmap)
    return icon
  end

end



