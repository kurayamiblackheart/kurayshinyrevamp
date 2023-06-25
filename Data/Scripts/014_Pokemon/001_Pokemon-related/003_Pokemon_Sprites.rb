#===============================================================================
# Pokémon sprite (used out of battle)
#===============================================================================
class PokemonSprite < SpriteWrapper
  def initialize(viewport = nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def clearBitmap
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil
  end

  def setOffset(offset = PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def filename
    return @bitmap
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::Center if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.bitmap.width / 2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.bitmap.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      self.oy = self.bitmap.height / 2
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.bitmap.height
    end
  end

  def setPokemonBitmap(pokemon, back = false)
    # File.open('LogColors.txt' + ".txt", 'a') { |f| f.write("SPRITE STARTED SETPOKEMONBITMAP\r") }
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    # File.open('LogColors.txt' + ".txt", 'a') { |f| f.write("SPRITE FINISHED SETPOKEMONBITMAP\r") }
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def setPokemonBitmapFromId(id, back = false, shiny=false, bodyShiny=false, headShiny=false, pokeHue = 0, pokeR = 0, pokeG = 1, pokeB = 2)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap_from_pokemon_id(id, back,shiny, bodyShiny,headShiny, pokeHue, pokeR, pokeG, pokeB)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

  def setPokemonBitmapSpecies(pokemon, species, back = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def getBitmap
    return @_iconbitmap
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
  end
end

#===============================================================================
# Pokémon icon (for defined Pokémon)
#===============================================================================
class PokemonIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon
  #Sylvi Big Icons
  attr_accessor :icon_offset_x
  attr_accessor :icon_offset_y

  def initialize(pokemon, viewport = nil)
    super(viewport)
    @selected = false
    @active = false
    @numFrames = 0
    @currentFrame = 0
    @counter = 0
    #self.pokemon = pokemon
    @logical_x = 0 # Actual x coordinate
    @logical_y = 0 # Actual y coordinate
    @adjusted_x = 0 # Offset due to "jumping" animation in party screen
    @adjusted_y = 0 # Offset due to "jumping" animation in party screen
    #Sylvi Big Icons
    @icon_offset_x = -16 # Offset to center big sprite icons (if enabled)
    @icon_offset_y = 0 # Offset to center big sprite icons (if enabled)
    self.pokemon = pokemon
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end

  def x
    return @logical_x;
  end

  def y
    return @logical_y;
  end

  def x=(value)
    @logical_x = value
    #Sylvi Big Icons
    ret = @logical_x + @adjusted_x
    if self.use_big_icon?
      if @pokemon && @pokemon.egg?
        ret += (@icon_offset_x / 2)
      else
        ret += @icon_offset_x
      end
    end
    super(ret)
  end

  def y=(value)
    @logical_y = value
    #Sylvi Big Icons
    ret = @logical_y + @adjusted_y
    if self.use_big_icon?
      if @pokemon && @pokemon.egg?
        ret += (@icon_offset_y / 2)
      else
        ret += @icon_offset_y
      end
    end
    super(ret)
  end

  def animBitmap=(value)
    @animBitmap = value
  end

  #Sylvi Big Icons
  def use_big_icon?
    return $PokemonSystem.kuraybigicons == 1 || $PokemonSystem.kuraybigicons == 2
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  #KuraIcon
  def pokemon=(value)
    @pokemon = value
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @currentFrame = 0
      @counter = 0
      return
    end

    if self.use_big_icon?
      #Sylvi Big Icons
      if $PokemonSystem.shiny_icons_kuray == 1
        if @pokemon.kuraycustomfile? == nil
          @animBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon)
        else
          if pbResolveBitmap(@pokemon.kuraycustomfile?) && !@pokemon.egg?
            filename = @pokemon.kuraycustomfile?
            @animBitmap = (filename) ? AnimatedBitmap.new(filename) : nil
          else
            @animBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon)
          end
        end
      else
        if @pokemon.kuraycustomfile? == nil
          @animBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon, false, nil, false)
        else
          if pbResolveBitmap(@pokemon.kuraycustomfile?) && !@pokemon.egg?
            filename = @pokemon.kuraycustomfile?
            @animBitmap = (filename) ? AnimatedBitmap.new(filename) : nil
          else
            @animBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon, false, nil, false)
          end
        end
      end
      if @pokemon.egg?
        @animBitmap.scale_bitmap(1.0/2.0)
      else
        @animBitmap.scale_bitmap(1.0/3.0)
      end
    elsif @pokemon.egg?
      @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(@pokemon))
    elsif useRegularIcon(@pokemon.species)
      # @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename(@pokemon.species, @pokemon.form, @pokemon.gender, @pokemon.shiny?))
      @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(@pokemon))
      if @pokemon.shiny? && $PokemonSystem.shiny_icons_kuray == 1 && $PokemonSystem.kuraynormalshiny != 1
        # @animBitmap.shiftColors(colorshifting)
        @animBitmap.pbGiveFinaleColor(@pokemon.shinyR?, @pokemon.shinyG?, @pokemon.shinyB?, @pokemon.shinyValue?)
      end
    else
      @animBitmap = createFusionIcon(@pokemon)
    end
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame >= @numFrames
    changeOrigin
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

  def useRegularIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return true if dexNum <= Settings::NB_POKEMON
    return false if $game_variables == nil
    return true if $game_variables[VAR_FUSION_ICON_STYLE] != 0
    bitmapFileName = sprintf("Graphics/Icons/icon%03d", dexNum)
    return true if pbResolveBitmap(bitmapFileName)
    return false
  end

  SPRITE_OFFSET = 10
  #KurayX - KURAYX_ABOUT_SHINIES
  #KuraIcon
  def createFusionIcon(pokemon)
    bodyPoke_number = getBodyID(pokemon.species)
    headPoke_number = getHeadID(pokemon.species, bodyPoke_number)


    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    icon1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke))
    icon2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke))

    #KurayX Github
    directory_name = "Graphics/Pokemon/FusionIcons"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    dexNum = getDexNumberForSpecies(@pokemon.species)
    #KurayX Custom icons
    if dexNum.is_a?(Symbol)
      dexNum = GameData::Species.get(dexNum).id_number
    end
    customiconname = customIcons(dexNum)
    if customiconname
      result_icon = AnimatedBitmap.new(customiconname)
    else
      bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
      headPokeFileName = GameData::Species.icon_filename(headPoke)
      bitmapPath = sprintf("%s.png", bitmapFileName)
      IO.copy_stream(headPokeFileName, bitmapPath)
      result_icon = AnimatedBitmap.new(bitmapPath)

      for i in 0..icon1.width-1
        for j in ((icon1.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)..icon1.height-1
          temp = icon2.bitmap.get_pixel(i, j)
          result_icon.bitmap.set_pixel(i, j, temp)
        end
      end
    end
    if @pokemon.shiny? && $PokemonSystem.shiny_icons_kuray == 1 && $PokemonSystem.kuraynormalshiny != 1
      # result_icon.shiftColors(colorshifting)
      result_icon.pbGiveFinaleColor(@pokemon.shinyR?, @pokemon.shinyG?, @pokemon.shinyB?, @pokemon.shinyValue?)
    end
    return result_icon
  end

  def setOffset(offset = PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TopLeft if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.src_rect.width / 2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height * 5 / 8
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.src_rect.height
    end
  end

  # How long to show each frame of the icon for
  def counterLimit
    return 0 if @pokemon.fainted? # Fainted - no animation
    # ret is initially the time a whole animation cycle lasts. It is divided by
    # the number of frames in that cycle at the end.
    ret = Graphics.frame_rate / 4 # Green HP - 0.25 seconds
    if @pokemon.hp <= @pokemon.totalhp / 4;
      ret *= 4 # Red HP - 1 second
    elsif @pokemon.hp <= @pokemon.totalhp / 2;
      ret *= 2 # Yellow HP - 0.5 seconds
    end
    ret /= @numFrames
    ret = 1 if ret < 1
    return ret
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    cl = self.counterLimit
    if cl == 0
      @currentFrame = 0
    else
      @counter += 1
      if @counter >= cl
        @currentFrame = (@currentFrame + 1) % @numFrames
        @counter = 0
      end
    end
    self.src_rect.x = self.src_rect.width * @currentFrame
    # Update "jumping" animation (used in party screen)
    if @selected
      @adjusted_x = 4
      @adjusted_y = (@currentFrame >= @numFrames / 2) ? -2 : 6
    else
      @adjusted_x = 0
      @adjusted_y = 0
    end
    self.x = self.x
    self.y = self.y
  end
end

#===============================================================================
# Pokémon icon (for species)
#===============================================================================
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :shiny

  def initialize(species, viewport = nil)
    super(viewport)
    @species = species
    @gender = 0
    @form = 0
    @shiny = 0
    @numFrames = 0
    @currentFrame = 0
    @counter = 0
    refresh
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end

  def species=(value)
    @species = value
    refresh
  end

  def gender=(value)
    @gender = value
    refresh
  end

  def form=(value)
    @form = value
    refresh
  end

  def shiny=(value)
    print "wut"
    @shiny = value
    refresh
  end

  def pbSetParams(species, gender, form, shiny = false)
    @species = species
    @gender = gender
    @form = form
    @shiny = shiny
    refresh
  end

  def setOffset(offset = PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TopLeft if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.src_rect.width / 2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height * 5 / 8
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.src_rect.height
    end
  end

  # How long to show each frame of the icon for
  def counterLimit
    # ret is initially the time a whole animation cycle lasts. It is divided by
    # the number of frames in that cycle at the end.
    ret = Graphics.frame_rate / 4 # 0.25 seconds
    ret /= @numFrames
    ret = 1 if ret < 1
    return ret
  end

  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame >= @numFrames
    changeOrigin
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    @counter += 1
    if @counter >= self.counterLimit
      @currentFrame = (@currentFrame + 1) % @numFrames
      @counter = 0
    end
    self.src_rect.x = self.src_rect.width * @currentFrame
  end
end
