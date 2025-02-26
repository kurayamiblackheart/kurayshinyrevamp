#===============================================================================
# Pokémon icons
#===============================================================================
class PokemonBoxIcon < IconSprite
  attr_accessor :heldox
  attr_accessor :heldoy
  attr_accessor :pokemon

  def initialize(pokemon, viewport = nil)
    #Sylvi Big Icons
    @logical_x = 0 # Actual x coordinate
    @logical_y = 0 # Actual y coordinate
    @icon_offset_x = 0 # Offset to center big sprite icons (if enabled)
    @icon_offset_y = 0 # Offset to center big sprite icons (if enabled)
    super(0, 0, viewport)
    @pokemon = pokemon
    @release = Interpolator.new
    @startRelease = false
    @heldox = 0
    @heldoy = 0
    refresh
  end
  
  #Sylvi Big Icons
  def x
    return @logical_x
  end

  #Sylvi Big Icons
  def y
    return @logical_y
  end

  #Sylvi Big Icons
  def x=(value)
    @logical_x = value
    super(@logical_x + @icon_offset_x)
  end

  #Sylvi Big Icons
  def y=(value)
    @logical_y = value
    super(@logical_y + @icon_offset_y)
  end

  #Sylvi Big Icons
  def use_big_icon?
    return $PokemonSystem && $PokemonSystem.kuraybigicons == 2
  end

  def releasing?
    return @release.tweening?
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

  def useTripleFusionIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return isTripleFusion?(dexNum)
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  #KuraIcon
  def createRBGableShiny(pokemon)
    # result_icon = AnimatedBitmap.new(GameData::Species.icon_filename(pokemon.species, pokemon.form, pokemon.gender, pokemon.shiny?))
    result_icon = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(pokemon))
    dexNum = getDexNumberForSpecies(pokemon.species)
    if pokemon.shiny? && $PokemonSystem.shiny_icons_kuray == 1 && $PokemonSystem.kuraynormalshiny != 1
      # result_icon.shiftColors(colorshifting)
      result_icon.pbGiveFinaleColor(pokemon.shinyR?, pokemon.shinyG?, pokemon.shinyB?, pokemon.shinyValue?, pokemon.shinyKRS?)
    end
    return result_icon
  end



  #KurayX Custom icons
  def customIcons(dex_number)
    return nil if dex_number == nil
    if dex_number <= Settings::NB_POKEMON
      return get_notfusedicon_sprite_path(dex_number)
    else
      if dex_number >= Settings::ZAPMOLCUNO_NB
        specialPath = getSpecialIconName(dex_number)
        if !pbResolveBitmap(specialPath)
          specialPath = sprintf("Graphics/Battlers/special/000")
        end
        # puts specialPath.inspect
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
    return kuray_global_triples(dexNum)
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
  #KuraIcon
  def createFusionIcon(species,spriteform_head=nil,spriteform_body=nil)
    bodyPoke_number = getBodyID(pokemon.species)
    headPoke_number = getHeadID(pokemon.species, bodyPoke_number)

    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    icon1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke,spriteform_head))
    icon2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke,spriteform_body))

    #KurayX Github
    directory_name = "Graphics/Pokemon/FusionIcons"
    checkDirectory(directory_name)
    dexNum = getDexNumberForSpecies(pokemon.species)
    #KurayX Custom icons
    if dexNum.is_a?(Symbol)
      dexNum = GameData::Species.get(dexNum).id_number
    end
    customiconname = customIcons(dexNum)
    if customiconname
      result_icon = AnimatedBitmap.new(customiconname)
    else
      bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
      headPokeFileName = GameData::Species.icon_filename(headPoke,spriteform_head)
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
      result_icon.pbGiveFinaleColor(@pokemon.shinyR?, @pokemon.shinyG?, @pokemon.shinyB?, @pokemon.shinyValue?, @pokemon.shinyKRS?)
    end
    return result_icon
  end

  def release
    self.ox = self.src_rect.width / 2 # 32
    self.oy = self.src_rect.height / 2 # 32
    self.x += self.src_rect.width / 2 # 32
    self.y += self.src_rect.height / 2 # 32
    @release.tween(self, [
      [Interpolator::ZOOM_X, 0],
      [Interpolator::ZOOM_Y, 0],
      [Interpolator::OPACITY, 0]
    ], 100)
    @startRelease = true
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def refresh(fusion_enabled = true)
    return if !@pokemon
    if self.use_big_icon?
      #Sylvi Big Icons
      if $PokemonSystem.shiny_icons_kuray == 1
        if @pokemon.kuraycustomfile? == nil
          tempBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon)
        else
          if pbResolveBitmap(@pokemon.kuraycustomfile?) && !@pokemon.egg? && (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
            filename = @pokemon.kuraycustomfile?
            tempBitmap = (filename) ? AnimatedBitmap.new(filename).recognizeDims() : nil
            if @pokemon.shiny?
              tempBitmap.pbGiveFinaleColor(@pokemon.shinyR?, @pokemon.shinyG?, @pokemon.shinyB?, @pokemon.shinyValue?, @pokemon.shinyKRS?)
            end
          else
            tempBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon)
          end
        end
      else
        if @pokemon.kuraycustomfile? == nil
          tempBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon, false, nil, false)
        else
          if pbResolveBitmap(@pokemon.kuraycustomfile?) && !@pokemon.egg? && (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
            filename = @pokemon.kuraycustomfile?
            tempBitmap = (filename) ? AnimatedBitmap.new(filename).recognizeDims() : nil
          else
            tempBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pokemon, false, nil, false)
          end
        end
      end
      if @pokemon.egg?
        tempBitmap.scale_bitmap(1.0/2.0)
        @icon_offset_x = -8
        @icon_offset_y = -8
      else
        tempBitmap.scale_bitmap(1.0/3.0)
        @icon_offset_x = -16
        @icon_offset_y = -16
      end
      self.setBitmapDirectly(tempBitmap)
    elsif @pokemon.egg?
      self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon))
    elsif useRegularIcon(@pokemon.species)
      self.setBitmapDirectly(createRBGableShiny(@pokemon))
      # if @pokemon.shiny?
        # self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon), GameData::Species.calculateShinyHueOffset(@pokemon.dexNum, @pokemon.bodyShiny?, @pokemon.headShiny?, @pokemon.shinyValue?))
      # end
      # self.visible = true
      ## if @pokemon.shiny?
        ## self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon), GameData::Species.calculateShinyHueOffset(@pokemon.dexNum, @pokemon.bodyShiny?, @pokemon.headShiny?, @pokemon.shinyValue?))
        ## self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon), GameData::Species.calculateShinyHueOffset(@pokemon.dexNum, @pokemon.bodyShiny?, @pokemon.headShiny?, @pokemon.shinyValue?))
      ## end
    elsif useTripleFusionIcon(@pokemon.species)
      self.setBitmap(pbResolveBitmap(sprintf("Graphics/Icons/iconDNA")))
    else
      self.setBitmapDirectly(createFusionIcon(@pokemon.species,@pokemon.spriteform_head, @pokemon.spriteform_body))
      if fusion_enabled
        self.visible = true
      else
        self.visible = false
      end
    end
    self.src_rect = Rect.new(0, 0, self.bitmap.height, self.bitmap.height)
  end

  def update
    super
    @release.update
    self.color = Color.new(0, 0, 0, 0)
    dispose if @startRelease && !releasing?
  end
end

#===============================================================================
# Pokémon sprite
#===============================================================================
class MosaicPokemonSprite < PokemonSprite
  attr_reader :mosaic

  def initialize(*args)
    super(*args)
    @mosaic = 0
    @inrefresh = false
    @mosaicbitmap = nil
    @mosaicbitmap2 = nil
    @oldbitmap = self.bitmap
  end

  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap = nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2 = nil
  end

  def bitmap=(value)
    super
    mosaicRefresh(value)
  end

  def mosaic=(value)
    @mosaic = value
    @mosaic = 0 if @mosaic < 0
    mosaicRefresh(@oldbitmap)
  end

  def mosaicRefresh(bitmap)
    return if @inrefresh
    @inrefresh = true
    @oldbitmap = bitmap
    if @mosaic <= 0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap = nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2 = nil
      self.bitmap = @oldbitmap
    else
      newWidth = [(@oldbitmap.width / @mosaic), 1].max
      newHeight = [(@oldbitmap.height / @mosaic), 1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap, newWidth, newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2, @oldbitmap.width, @oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @oldbitmap, @oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
        Rect.new(-@mosaic / 2 + 1, -@mosaic / 2 + 1,
                 @mosaicbitmap2.width, @mosaicbitmap2.height),
        @mosaicbitmap, Rect.new(0, 0, newWidth, newHeight))
      self.bitmap = @mosaicbitmap2
    end
    @inrefresh = false
  end
end

#===============================================================================
#
#===============================================================================
class AutoMosaicPokemonSprite < MosaicPokemonSprite
  def update
    super
    self.mosaic -= 1
  end
end

#===============================================================================
# Cursor
#===============================================================================
class PokemonBoxArrow < SpriteWrapper
  attr_accessor :cursormode

  def initialize(viewport = nil)
    super(viewport)
    @frame = 0
    @holding = false
    @updating = false
    @cursormode = "default"
    @grabbingState = 0
    @placingState = 0
    @heldpkmn = nil
    @handsprite = ChangelingSprite.new(0, 0, viewport)
    @handsprite.addBitmap("point1", "Graphics/Pictures/Storage/cursor_point_1")
    @handsprite.addBitmap("point2", "Graphics/Pictures/Storage/cursor_point_2")
    @handsprite.addBitmap("grab", "Graphics/Pictures/Storage/cursor_grab")
    @handsprite.addBitmap("fist", "Graphics/Pictures/Storage/cursor_fist")
    @handsprite.addBitmap("point1q", "Graphics/Pictures/Storage/cursor_point_1_q")
    @handsprite.addBitmap("point2q", "Graphics/Pictures/Storage/cursor_point_2_q")
    @handsprite.addBitmap("grabq", "Graphics/Pictures/Storage/cursor_grab_q")
    @handsprite.addBitmap("fistq", "Graphics/Pictures/Storage/cursor_fist_q")
    @handsprite.addBitmap("point1m", "Graphics/Pictures/Storage/cursor_point_1_m")
    @handsprite.addBitmap("point2m", "Graphics/Pictures/Storage/cursor_point_2_m")
    @handsprite.addBitmap("grabm", "Graphics/Pictures/Storage/cursor_grab_m")
    @handsprite.addBitmap("fistm", "Graphics/Pictures/Storage/cursor_fist_m")
    @handsprite.changeBitmap("fist")
    @spriteX = self.x
    @spriteY = self.y
    @splicerType = 0
    @multiheldpkmn = []
  end

  def dispose
    @handsprite.dispose
    @heldpkmn.dispose if @heldpkmn
    @multiheldpkmn.each { |pkmn| pkmn.dispose }
    super
  end

  def getSplicerIcon
    case @splicerType
    when 2
      return AnimatedBitmap.new("Graphics/Pictures/boxinfinitesplicer")
    when 1
      return AnimatedBitmap.new("Graphics/Pictures/boxsupersplicer")
    end
    return AnimatedBitmap.new("Graphics/Pictures/boxsplicer")
  end

  def setSplicerType(type)
    @splicerType = type
  end

  def setFusing(fusing)
    @fusing = fusing
  end

  def fusing?
    return @fusing
  end

  def heldPokemon
    @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
    @holding = false if !@heldpkmn && @multiheldpkmn.length == 0
    return @heldpkmn
  end

  def multiHeldPokemon
    @multiheldpkmn.delete_if { |pkmn| pkmn.disposed? }
    @holding = false if !@heldpkmn && @multiheldpkmn.length == 0
    return @multiheldpkmn
  end

  def visible=(value)
    super
    @handsprite.visible = value
    sprite = heldPokemon
    sprite.visible = value if sprite
    multiHeldPokemon.each { |pkmn| pkmn.visible = value }
  end

  def color=(value)
    super
    @handsprite.color = value
    sprite = heldPokemon
    sprite.color = value if sprite
    multiHeldPokemon.each { |pkmn| pkmn.color = value }
  end

  def holdingSingle?
    return self.heldPokemon && @holding
  end

  def holdingMulti?
    return @multiheldpkmn.length > 0 && @holding
  end

  def grabbing?
    return @grabbingState > 0
  end

  def placing?
    return @placingState > 0
  end

  def x=(value)
    super
    @handsprite.x = self.x
    @spriteX = x if !@updating
    heldPokemon.x = self.x if holdingSingle?
    multiHeldPokemon.each { |pkmn| pkmn.x = self.x + (pkmn.heldox * 48) } if holdingMulti?
  end

  def y=(value)
    super
    @handsprite.y = self.y
    @spriteY = y if !@updating
    heldPokemon.y = self.y + 16 if holdingSingle?
    multiHeldPokemon.each { |pkmn| pkmn.y = self.y + 16 + (pkmn.heldoy * 48) } if holdingMulti?
  end

  def z=(value)
    super
    @handsprite.z = value
  end

  def setSprite(sprite)
    if holdingSingle?
      @heldpkmn = sprite
      @heldpkmn.viewport = self.viewport if @heldpkmn
      @heldpkmn.z = 1 if @heldpkmn
      @holding = false if !@heldpkmn && @multiheldpkmn.length == 0
      self.z = 2
    end
  end

  def setSprites(sprites)
    if holdingMulti?
      @multiheldpkmn = sprites
      for pkmn in @multiheldpkmn
        pkmn.viewport = self.viewport
        pkmn.z = 1
      end
      @holding = false if !@heldpkmn && @multiheldpkmn.length == 0
      self.z = 2
    end
  end

  def deleteSprite
    @holding = false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn = nil
    end
    @multiheldpkmn.each { |pkmn| pkmn.dispose }
    @multiheldpkmn = []
  end

  def grab(sprite)
    @grabbingState = 1
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2
  end

  def grabImmediate(sprite)
    @grabbingState = 0
    @holding = true
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2

    self.x = @spriteX
    self.y = @spriteY
  end

  def grabMulti(sprites)
    @grabbingState = 1
    @multiheldpkmn = sprites
    for pkmn in @multiheldpkmn
      pkmn.viewport = self.viewport
      pkmn.z = 1
    end
    self.z = 2
  end

  def place
    @placingState = 1
  end

  def release
    @heldpkmn.release if @heldpkmn
  end

  def getModeSprites
    case @cursormode
    when "quickswap"
      return ["point1q", "point2q", "grabq", "fistq"]
    when "multiselect"
      return ["point1m", "point2m", "grabm", "fistm"]
    else
      return ["point1", "point2", "grab", "fist"]
    end
  end

  def update
    @updating = true
    super
    heldpkmn = heldPokemon
    heldpkmn.update if heldpkmn
    multiheldpkmn = multiHeldPokemon
    multiheldpkmn.each { |pkmn| pkmn.update }
    modeSprites = getModeSprites
    @handsprite.update
    @holding = false if !heldpkmn && multiheldpkmn.length == 0
    if @grabbingState > 0
      if @grabbingState <= 4 * Graphics.frame_rate / 20
        @handsprite.changeBitmap(modeSprites[2]) # grab
        self.y = @spriteY + 4.0 * @grabbingState * 20 / Graphics.frame_rate
        @grabbingState += 1
      elsif @grabbingState <= 8 * Graphics.frame_rate / 20
        @holding = true
        @handsprite.changeBitmap(modeSprites[3]) # fist
        self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @grabbingState) * 20 / Graphics.frame_rate
        @grabbingState += 1
      else
        @grabbingState = 0
      end
    elsif @placingState > 0
      if @placingState <= 4 * Graphics.frame_rate / 20
        @handsprite.changeBitmap(modeSprites[3]) # fist
        self.y = @spriteY + 4.0 * @placingState * 20 / Graphics.frame_rate
        @placingState += 1
      elsif @placingState <= 8 * Graphics.frame_rate / 20
        @holding = false
        @heldpkmn = nil
        @multiheldpkmn = []
        @handsprite.changeBitmap(modeSprites[2]) # grab
        self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @placingState) * 20 / Graphics.frame_rate
        @placingState += 1
      else
        @placingState = 0
      end
    elsif holdingSingle? || holdingMulti?
      @handsprite.changeBitmap(modeSprites[3]) # fist
    else
      self.x = @spriteX
      self.y = @spriteY
      if @frame < Graphics.frame_rate / 2
        @handsprite.changeBitmap(modeSprites[0]) # point1
      else
        @handsprite.changeBitmap(modeSprites[1]) # point2
      end
    end
    @frame += 1
    @frame = 0 if @frame >= Graphics.frame_rate
    @updating = false
  end
end

#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites

  def initialize(storage, boxnumber, viewport = nil, fusionsEnabled=true )
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @pokemonsprites = []
    for i in 0...PokemonBox::BOX_SIZE
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber, i]
      @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
    end
    @contents = BitmapWrapper.new(324, 296)
    self.bitmap = @contents
    self.x = 184
    self.y = 18

    @fusions_enabled = fusionsEnabled
    refresh
  end

  def disableFusions()
    @fusions_enabled = false
    refreshAllBoxSprites()
  end

  def enableFusions()
    @fusions_enabled = true
    refreshAllBoxSprites()
  end

  def isFusionEnabled
    return @fusions_enabled
  end

  def dispose
    if !disposed?
      for i in 0...PokemonBox::BOX_SIZE
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @boxbitmap.dispose
      @contents.dispose
      super
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...PokemonBox::BOX_SIZE
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg != @storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || (curbg.is_a?(String) && curbg.length == 0)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
      else
        if curbg.is_a?(String) && curbg[/^box(\d+)$/]
          curbg = $~[1].to_i
          @storage[@boxnumber].background = curbg
        end
        @bg = curbg
      end
      if !@storage.isAvailableWallpaper?(@bg)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
        @storage[@boxnumber].background = @bg
      end
      @boxbitmap.dispose if @boxbitmap
      if File.file?("Graphics/Pictures/Storage/box_#{@bg}.png")
        @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/box_#{@bg}")
      else
        @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/missing_box")
      end
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites[index].refresh
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      update
    end
  end

  def placePokemonMulti(index, sprites)
    arrowX = index % PokemonBox::BOX_WIDTH
    arrowY = (index / PokemonBox::BOX_WIDTH).floor
    for sprite in sprites
      spriteIndex = (sprite.heldox + arrowX) + (sprite.heldoy + arrowY) * PokemonBox::BOX_WIDTH
      @pokemonsprites[spriteIndex] = sprite
      @pokemonsprites[spriteIndex].refresh
    end
    if sprites.length > 0
      refresh
    end
  end

  def grabPokemonMulti(indexes, arrowIndex, arrow)
    grabbedSprites = []
    arrowX = arrowIndex % PokemonBox::BOX_WIDTH
    arrowY = (arrowIndex / PokemonBox::BOX_WIDTH).floor
    for index in indexes
      sprite = @pokemonsprites[index]
      if sprite && sprite.pokemon && !sprite.disposed?
        sprite.heldox = (index % PokemonBox::BOX_WIDTH) - arrowX
        sprite.heldoy = (index / PokemonBox::BOX_WIDTH).floor - arrowY
        grabbedSprites.push(sprite)
        @pokemonsprites[index] = nil
      end
    end
    if grabbedSprites.length > 0
      arrow.grabMulti(grabbedSprites)
      update
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    update
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 324, 296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      # Calculate the width of the "S" and "E" indicators
      indicator_width = 32 # 32 for "S" and 32 for "E"

      # Calculate the total width of the box name and the indicators
      total_width = widthval + indicator_width

      # Calculate the starting x-coordinate for the text
      xval = 162 - (total_width / 2)

      # Draw "S" in red if sortlock is true, green otherwise
      color = @storage[@boxnumber].sortlock? ? Color.new(200, 15, 15) : Color.new(0, 200, 0)
      pbDrawShadowText(@contents, xval, 8, 32, 32, "S", color, Color.new(40, 48, 48))
      xval += 16

      # Draw "E" in red if exportlock is true, green otherwise
      color = @storage[@boxnumber].exportlock? ? Color.new(200, 15, 15) : Color.new(0, 200, 0)
      pbDrawShadowText(@contents, xval, 8, 32, 32, "E", color, Color.new(40, 48, 48))
      xval += 16

      # Draw the box name
      pbDrawShadowText(@contents, xval, 8, widthval, 32, boxname, Color.new(248, 248, 248), Color.new(40, 48, 48))
      @refreshBox = false
    end
    yval = self.y + 30
    for j in 0...PokemonBox::BOX_HEIGHT
      xval = self.x + 10
      for k in 0...PokemonBox::BOX_WIDTH
        sprite = @pokemonsprites[j * PokemonBox::BOX_WIDTH + k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.x = xval
          sprite.y = yval
          sprite.z = 1
        end
        xval += 48
      end
      yval += 48
    end
  end

  def refreshAllBoxSprites
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].refresh(@fusions_enabled)
      end
    end
  end

  def update
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end

#===============================================================================
# Party pop-up panel
#===============================================================================
class PokemonBoxPartySprite < SpriteWrapper
  def initialize(party, viewport = nil)
    super(viewport)
    @party = party
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/overlay_party")
    @pokemonsprites = []
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
      end
    end
    @contents = BitmapWrapper.new(172, 352)
    self.bitmap = @contents
    self.x = 182
    self.y = Graphics.height - 352
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
    @boxbitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color, value)
      end
    end
  end

  def visible=(value)
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def placePokemonMulti(index, sprites)
    partyIndex = @pokemonsprites.count { |i| i && i.pokemon && !i.disposed? }
    for sprite in sprites
      @pokemonsprites[partyIndex] = sprite
      partyIndex += 1
    end
    if sprites.length > 0
      @pokemonsprites.compact!
      refresh
    end
  end

  def grabPokemonMulti(indexes, arrowIndex, arrow)
    grabbedSprites = []
    arrowX = arrowIndex % 2
    arrowY = (arrowIndex / 2).floor
    for index in indexes
      sprite = @pokemonsprites[index]
      if sprite && sprite.pokemon && !sprite.disposed?
        sprite.heldox = (index % 2) - arrowX
        sprite.heldoy = (index / 2).floor - arrowY
        grabbedSprites.push(sprite)
        @pokemonsprites[index] = nil
      end
    end
    if grabbedSprites.length > 0
      arrow.grabMulti(grabbedSprites)
      @pokemonsprites.compact!
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    @pokemonsprites.compact!
    refresh
  end

  #Sylvi Big Icons
  def hidePokemon
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].visible = false if @pokemonsprites[i]
    end
  end

  #Sylvi Big Icons
  def showPokemon
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].visible = true if @pokemonsprites[i]
    end
  end

  def refresh
    @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 172, 352))
    pbDrawTextPositions(self.bitmap, [
      [_INTL("Back"), 86, 240, 2, Color.new(248, 248, 248), Color.new(80, 80, 80), 1]
    ])
    xvalues = [] # [18, 90, 18, 90, 18, 90]
    yvalues = [] # [2, 18, 66, 82, 130, 146]
    for i in 0...Settings::MAX_PARTY_SIZE
      xvalues.push(18 + 72 * (i % 2))
      yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
    end
    for j in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...Settings::MAX_PARTY_SIZE
      sprite = @pokemonsprites[j]
      next if sprite.nil? || sprite.disposed?
      sprite.viewport = self.viewport
      sprite.x = self.x + xvalues[j]
      sprite.y = self.y + yvalues[j]
      sprite.z = 1
    end
  end

  def update
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
    end
  end
end

#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
  attr_reader :cursormode
  attr_reader :screen
  attr_accessor :sprites

  def initialize
    @command = 1
  end

  def pbReleaseInstant(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box == -1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.dispose
    end
  end

  def pbStartBox(screen, command)
    @screen = screen
    @storage = screen.storage
    @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @bgviewport.z = 99999
    @boxviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxviewport.z = 99999
    @boxsidesviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxsidesviewport.z = 99999
    @arrowviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @arrowviewport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @selection = 0
    @cursormode = "default"
    @sprites = {}
    @choseFromParty = false
    @command = command
    addBackgroundPlane(@sprites, "background", "Storage/bg", @bgviewport)
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport)
    @sprites["boxsides"] = IconSprite.new(0, 0, @boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/overlay_main")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 90
    @sprites["pokemon"].y = 134
    @sprites["pokemon"].zoom_y = Settings::FRONTSPRITE_SCALE
    @sprites["pokemon"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport)
    if command != 2 # Drop down tab only on Deposit
      @sprites["boxparty"].x = 182
      @sprites["boxparty"].y = Graphics.height
      @sprites["boxparty"].hidePokemon #Sylvi Big Icons
    end
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/markings")
    @sprites["markingbg"] = IconSprite.new(292, 68, @boxsidesviewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Storage/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["selectionrect"] = BitmapSprite.new(Graphics.width, Graphics.height, @arrowviewport)
    @sprites["selectionrect"].visible = false
    @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z += 1
    if command != 2
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
      pbSetMosaic(@selection)
    end
    pbSEPlay("PC access")
    pbFadeInAndShow(@sprites)
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @markingbitmap.dispose if @markingbitmap
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  def pbDisplay(message)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        break
      end
      msgwindow.update
      self.update
    end
    msgwindow.dispose
    Input.update
  end

  def pbShowCommands(message, commands, index = 0)
    ret = -1
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.text = message
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    pbBottomRight(cmdwindow)
    cmdwindow.y -= msgwindow.height
    cmdwindow.index = index
    loop do
      Graphics.update
      Input.update
      msgwindow.update
      cmdwindow.update
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        break
      end
      self.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbSetArrow(arrow, selection)
    case selection
    when -1, -4, -5 # Box name, move left, move right
      arrow.x = 157 * 2
      arrow.y = -12 * 2
    when -2 # Party Pokémon
      arrow.x = 119 * 2
      arrow.y = 139 * 2
    when -3 # Close Box
      arrow.x = 207 * 2
      arrow.y = 139 * 2
    else
      arrow.x = (97 + 24 * (selection % PokemonBox::BOX_WIDTH)) * 2
      arrow.y = (8 + 24 * (selection / PokemonBox::BOX_WIDTH)) * 2
    end
  end

  def pbChangeSelection(key, selection)
    case key
    when Input::UP
      if @screen.multiSelectRange
        selection -= PokemonBox::BOX_WIDTH
        selection += PokemonBox::BOX_SIZE if selection < 0
      elsif selection == -1 # Box name
        selection = -2
      elsif selection == -2 # Party
        selection = PokemonBox::BOX_SIZE - 1 - PokemonBox::BOX_WIDTH * 2 / 3 # 25
      elsif selection == -3 # Close Box
        selection = PokemonBox::BOX_SIZE - PokemonBox::BOX_WIDTH / 3 # 28
      else
        selection -= PokemonBox::BOX_WIDTH
        selection = -1 if selection < 0
      end
    when Input::DOWN
      if @screen.multiSelectRange
        selection += PokemonBox::BOX_WIDTH
        selection -= PokemonBox::BOX_SIZE if selection >= PokemonBox::BOX_SIZE
      elsif selection == -1 # Box name
        selection = PokemonBox::BOX_WIDTH / 3 # 2
      elsif selection == -2 # Party
        selection = -1
      elsif selection == -3 # Close Box
        selection = -1
      else
        selection += PokemonBox::BOX_WIDTH
        if selection >= PokemonBox::BOX_SIZE
          if selection < PokemonBox::BOX_SIZE + PokemonBox::BOX_WIDTH / 2
            selection = -2 # Party
          else
            selection = -3 # Close Box
          end
        end
      end
    when Input::LEFT
      if @screen.multiSelectRange
        if (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
          selection += PokemonBox::BOX_WIDTH - 1
        else
          selection -= 1
        end
      elsif selection == -1 # Box name
        selection = -4 # Move to previous box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
        selection += PokemonBox::BOX_WIDTH - 1
      else
        selection -= 1
      end
    when Input::RIGHT
      if @screen.multiSelectRange
        if (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
          selection -= PokemonBox::BOX_WIDTH - 1
        else
          selection += 1
        end
      elsif selection == -1 # Box name
        selection = -5 # Move to next box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
        selection -= PokemonBox::BOX_WIDTH - 1
      else
        selection += 1
      end
    end
    return selection
  end

  def pbPartySetArrow(arrow, selection)
    return if selection < 0
    xvalues = [] # [200, 272, 200, 272, 200, 272, 236]
    yvalues = [] # [2, 18, 66, 82, 130, 146, 220]
    for i in 0...Settings::MAX_PARTY_SIZE
      xvalues.push(200 + 72 * (i % 2))
      yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
    end
    xvalues.push(236)
    yvalues.push(220)
    arrow.angle = 0
    arrow.mirror = false
    arrow.ox = 0
    arrow.oy = 0
    arrow.x = xvalues[selection]
    arrow.y = yvalues[selection]
  end

  def pbPartyChangeSelection(key, selection)
    maxIndex = @screen.multiSelectRange ? Settings::MAX_PARTY_SIZE - 1 : Settings::MAX_PARTY_SIZE
    case key
    when Input::LEFT
      selection -= 1
      selection = maxIndex if selection < 0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection > maxIndex
    when Input::UP
      if selection == Settings::MAX_PARTY_SIZE
        selection = Settings::MAX_PARTY_SIZE - 1
      else
        selection -= 2
        selection = selection % Settings::MAX_PARTY_SIZE if @screen.multiSelectRange
        selection = maxIndex if selection < 0
      end
    when Input::DOWN
      if selection == Settings::MAX_PARTY_SIZE
        selection = 0
      else
        selection += 2
        selection = selection % Settings::MAX_PARTY_SIZE if @screen.multiSelectRange
        selection = maxIndex if selection > maxIndex
      end
    end
    return selection
  end

  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        if selection == -4
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection == -5
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection == -4 || selection == -5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(@storage.currentBox, selection)
        end
      end
      self.update
      if Input.trigger?(Input::JUMPUP)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::JUMPDOWN)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::SPECIAL) # Jump to box name
        if selection != -1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbNextCursorMode
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == -1 # Box name
          return [-4, -1]
        elsif selection == -2 # Party Pokémon
          return [-2, -1]
        elsif selection == -3 # Close Box
          return [-3, -1]
        end
      end
    end
  end

  def pbSelectBox(party)
    return pbSelectBoxInternal(party) if @command == 1 # Withdraw
    ret = nil
    loop do
      if !@choseFromParty
        ret = pbSelectBoxInternal(party)
      end
      if @choseFromParty || (ret && ret[0] == -2) # Party Pokémon
        if !@choseFromParty
          pbShowPartyTab
          @selection = 0
        end
        ret = pbSelectPartyInternal(party, false)
        if ret < 0
          pbHidePartyTab
          @selection = 0
          @choseFromParty = false
        else
          @choseFromParty = true
          return [-1, ret]
        end
      else
        @choseFromParty = false
        return ret
      end
    end
  end

  def pbSelectPartyInternal(party, depositing)
    selection = @selection
    pbPartySetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection, party)
    pbSetMosaic(selection)
    lastsel = 1
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE
        newselection = pbPartyChangeSelection(key, selection)
        if newselection == -1
          return -1 if !depositing
        elsif newselection == -2
          selection = lastsel
        else
          selection = newselection
        end
        pbPartySetArrow(@sprites["arrow"], selection)
        lastsel = selection if selection > 0
        pbUpdateOverlay(selection, party)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(-1, selection)
        end
      end
      self.update
      if Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbNextCursorMode
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return -1
      elsif Input.trigger?(Input::USE)
        if selection >= 0 && selection < Settings::MAX_PARTY_SIZE
          @selection = selection
          return selection
        elsif selection == Settings::MAX_PARTY_SIZE # Close Box
          @selection = selection
          return (depositing) ? -3 : -1
        end
      end
    end
  end

  def pbSelectParty(party)
    return pbSelectPartyInternal(party, true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites = false
    alpha = 0
    Graphics.update
    self.update
    timeTaken = Graphics.frame_rate * 4 / 10
    alphaDiff = (255.0 / timeTaken).ceil
    timeTaken.times do
      alpha += alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
    @sprites["box"].refreshBox = true
    @storage[@storage.currentBox].background = wp
    (Graphics.frame_rate / 10).times do
      Graphics.update
      Input.update
      self.update
    end
    timeTaken.times do
      alpha -= alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
    @sprites["box"].refreshSprites = true
  end

  def pbSwitchBoxToRight(newbox)
    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport,@sprites["box"].isFusionEnabled)
    newbox.x = 520
    Graphics.frame_reset
    distancePerFrame = 64 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x -= distancePerFrame
      newbox.x -= distancePerFrame
      self.update
      break if newbox.x <= 184
    end
    diff = newbox.x - 184
    newbox.x = 184
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
    newbox.refreshAllBoxSprites
  end

  def pbSwitchBoxToLeft(newbox)
    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport,@sprites["box"].isFusionEnabled)
    newbox.x = -152
    Graphics.frame_reset
    distancePerFrame = 64 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x += distancePerFrame
      newbox.x += distancePerFrame
      self.update
      break if newbox.x >= 184
    end
    diff = newbox.x - 184
    newbox.x = 184
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
    newbox.refreshAllBoxSprites
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox != newbox
      if newbox > @storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox = newbox
    end
  end

  def pbSetMosaic(selection)
    if !@screen.pbHolding?
      if @boxForMosaic != @storage.currentBox || @selectionForMosaic != selection
        @sprites["pokemon"].mosaic = Graphics.frame_rate / 4
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selection
      end
    end
  end

  def pbNextCursorMode()
    case @cursormode
    when "default"
      pbSetCursorMode("quickswap")
    when "quickswap"
      pbSetCursorMode((@screen.pbHolding?) ? "default" : "multiselect")
    when "multiselect"
      pbSetCursorMode("default") if !@screen.pbHolding?
    end
  end

  def pbSetCursorMode(value)
    @cursormode = value
    @sprites["arrow"].cursormode = value
    if @screen.multiSelectRange
      @screen.multiSelectRange = nil
      pbUpdateSelectionRect(@choseFromParty ? -1 : @storage.currentBox, 0)
    end
  end

  def pbShowPartyTab
    pbSEPlay("GUI storage show party panel")
    @sprites["boxparty"].showPokemon #Sylvi Big Icons
    distancePerFrame = 48 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y -= distancePerFrame
      self.update
      break if @sprites["boxparty"].y <= Graphics.height - 352
    end
    @sprites["boxparty"].y = Graphics.height - 352
  end

  def pbHidePartyTab
    pbSEPlay("GUI storage hide party panel")
    distancePerFrame = 48 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y += distancePerFrame
      self.update
      break if @sprites["boxparty"].y >= Graphics.height
    end
    @sprites["boxparty"].y = Graphics.height
    @sprites["boxparty"].hidePokemon #Sylvi Big Icons
  end

  def pbHold(selected)
    pbSEPlay("GUI storage pick up")
    if selected[0] == -1
      @sprites["boxparty"].grabPokemon(selected[1], @sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1], @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSetHeldPokemon(pokemon)
    pokesprite = PokemonBoxIcon.new(pokemon, @arrowviewport)
    @sprites["arrow"].grabImmediate(pokesprite)
  end

  def pbSwap(selected, _heldpoke)
    pbSEPlay("GUI storage pick up")
    heldpokesprite = @sprites["arrow"].heldPokemon
    boxpokesprite = nil
    if selected[0] == -1
      boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite = @sprites["box"].getPokemon(selected[1])
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    @sprites["pokemon"].mosaic = 10
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbPlace(selected, _heldpoke)
    pbSEPlay("GUI storage put down")
    heldpokesprite = @sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbWithdraw(selected, heldpoke, partyindex)
    pbHold(selected) if !heldpoke
    pbShowPartyTab
    pbPartySetArrow(@sprites["arrow"], partyindex)
    pbPlace([-1, partyindex], heldpoke)
    pbHidePartyTab
  end

  def pbStore(selected, heldpoke, destbox, firstfree)
    if heldpoke
      if destbox == @storage.currentBox
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree, heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite = @sprites["boxparty"].getPokemon(selected[1])
      if destbox == @storage.currentBox
        @sprites["box"].setPokemon(firstfree, sprite)
        @sprites["boxparty"].setPokemon(selected[1], nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box == -1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        self.update
      end
    end
  end

  def pbHoldMulti(box, selected, selectedIndex)
    pbSEPlay("GUI storage pick up")
    if box == -1
      @sprites["boxparty"].grabPokemonMulti(selected, selectedIndex, @sprites["arrow"])
    else
      @sprites["box"].grabPokemonMulti(selected, selectedIndex, @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbPlaceMulti(box, index)
    pbSEPlay("GUI storage put down")
    heldpokesprites = @sprites["arrow"].multiHeldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if box == -1
      @sprites["boxparty"].placePokemonMulti(index, heldpokesprites)
    else
      @sprites["box"].placePokemonMulti(index, heldpokesprites)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = index
  end

  def pbReleaseMulti(box, selected)
    releaseSprites = []
    for index in selected
      sprite = nil
      if box == -1
        sprite = @sprites["boxparty"].getPokemon(index)
      else
        sprite = @sprites["box"].getPokemon(index)
      end
      releaseSprites.push(sprite) if sprite
    end
    if releaseSprites.length > 0
      for sprite in releaseSprites
        sprite.release
      end
      while releaseSprites[0].releasing?
        Graphics.update
        for sprite in releaseSprites
          sprite.update
        end
        self.update
      end
    end
  end

  def pbChooseBox(msg)
    commands = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        commands.push(_INTL("{1} ({2}/{3})", box.name, box.nitems, box.length))
      end
    end
    return pbShowCommands(msg, commands, @storage.currentBox)
  end

  def pbToggleSortBox()
    @storage[@storage.currentBox].sortlock = !@storage[@storage.currentBox].sortlock?
    @sprites["box"].refreshBox = true
    pbRefresh
  end

  def pbToggleExportBox()
    @storage[@storage.currentBox].exportlock = !@storage[@storage.currentBox].exportlock?
    @sprites["box"].refreshBox = true
    pbRefresh
  end

  def pbBoxName(helptext, minchars, maxchars)
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = pbEnterBoxName(helptext, minchars, maxchars)
    if ret.length > 0
      @storage[@storage.currentBox].name = ret
    end
    @sprites["box"].refreshBox = true
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbChooseItem(bag)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).can_hold? })
    }
    return ret
  end

  def pbKurayAct(selected, heldpoke)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    commands = []
    cmdCancel = -1
    cmdImportJson = -1
    cmdExport = -1
    cmdExportAll = -1
    cmdShinyReroll = -1
    cmdShinyChoose = -1
    cmdEvoLock = -1
    cmdShinify = -1
    cmdToggleShiny = -1
    cmdCarpFill = -1
    cmdRerollSprite = -1
    cmdShininessSell = -1
    cmdBlacklist = -1
    cmdDefSprite = -1
    cmdOpenShinyFinder = -1
    cmdShowSprite = -1
    cmdDebug1 = -1
    canExportImport = true
    if $PokemonSystem.debugfeature
      if $PokemonSystem.debugfeature == 1
        canExportImport = false
      end
    end
    helptext = _INTL("{1} is selected.", pokemon.name)
    commands[cmdEvoLock = commands.length] = _INTL("Lock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && pokemon.kuray_no_evo? == 0)
    commands[cmdEvoLock = commands.length] = _INTL("Unlock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && pokemon.kuray_no_evo? == 1)
    commands[cmdShinify = commands.length] = _INTL("Gamble for Shiny") if !pokemon.shiny?
    commands[cmdShinify = commands.length] = _INTL("Gamble for new Color") if pokemon.shiny? && $PokemonSystem.kuraynormalshiny != 1
    commands[cmdShininessSell = commands.length] = _INTL("Sell Shininess") if pokemon.shiny?
    commands[cmdRerollSprite = commands.length] = _INTL("Re-roll Sprite") if (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
    commands[cmdDefSprite = commands.length] = _INTL("Use Default Sprite") if (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
    commands[cmdShowSprite = commands.length] = _INTL("Show Spritename") if (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
    commands[cmdBlacklist = commands.length] = _INTL("Blacklist Sprite") if (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
    commands[cmdOpenShinyFinder = commands.length] = _INTL("Start Shiny Finder") if (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
    # commands[cmdImportJson = commands.length] = _INTL("Import") if $DEBUG
    commands[cmdExport = commands.length] = _INTL("Export") if $DEBUG || canExportImport
    commands[cmdExportAll = commands.length] = _INTL("Export All Pokemons") if $DEBUG || canExportImport
    commands[cmdShinyReroll = commands.length] = _INTL("Re-roll Shiny Color") if $DEBUG
    commands[cmdShinyChoose = commands.length] = _INTL("Set Shiny Color") if $DEBUG
    if $DEBUG && File.file?(RTP.getSaveFolder + "\\Kurayami.krs")
      commands[cmdCarpFill = commands.length] = _INTL("CarpFill")
      commands[cmdToggleShiny = commands.length] = _INTL("Toggle Shiny")
      commands[cmdDebug1 = commands.length] = _INTL("Print EggGroups")
    end
    commands[cmdCancel = commands.length] = _INTL("Cancel")
    command = pbShowCommands(helptext, commands)
    if cmdEvoLock >= 0 && command == cmdEvoLock # EvoLock
      pbKurayNoEvo(selected, heldpoke)
    elsif cmdExport >= 0 && command == cmdExport # Export
      pbExport(selected, heldpoke, 0)
    elsif cmdExportAll >= 0 && command == cmdExportAll # Export ALL
      pbExportAll()
    # elsif cmdImportJson >= 0 && command == cmdImportJson # Import Json
    #   pbImportJson(selected, heldpoke)
    elsif cmdToggleShiny >= 0 && command == cmdToggleShiny # Toggle Shiny
      pbToggleShiny(selected, heldpoke)
    elsif cmdRerollSprite >= 0 && command == cmdRerollSprite # Reroll Sprite
      pbRerollSprite(selected, heldpoke)
    elsif cmdShininessSell >= 0 && command == cmdShininessSell # Sell Shininess
      pbShinySell(selected, heldpoke)
    elsif cmdCarpFill >= 0 && command == cmdCarpFill # Carp Fill
      pbCarpFill(selected, heldpoke)
    elsif cmdShinyReroll >= 0 && command == cmdShinyReroll # Re-roll Shiny Color
      pbRerollShiny(selected, heldpoke)
    elsif cmdShinyChoose >= 0 && command == cmdShinyChoose # Set Shiny Color
      pbDefineShinycolor(selected, heldpoke)
    elsif cmdShinify >= 0 && command == cmdShinify # Shinify
      pbKuraShinify(selected, heldpoke)
    elsif cmdBlacklist >= 0 && command == cmdBlacklist # Blacklist Sprite
      pbBlackList(selected, heldpoke)
    elsif cmdDefSprite >= 0 && command == cmdDefSprite # Blacklist Sprite
      pbDefaultSprite(selected, heldpoke)
    elsif cmdShowSprite >= 0 && command == cmdShowSprite # Show Sprite
      pbShowSprite(selected, heldpoke)
    elsif cmdOpenShinyFinder >= 0 && command == cmdOpenShinyFinder # Show Sprite
      pbShinyFinder(selected, heldpoke)
    elsif cmdDebug1 >= 0 && command == cmdDebug1 # Show Sprite
      pbDisplay(_INTL(pokemon.species_data.egg_groups.to_s))
    end
  end

  def pbRerollSprite(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    if selected[0] == -1
      overlayvar2 = @storage.party
    end
    while true
      pricenow = 5000
      pricenow = 0 if $PokemonSystem.kuraystreamerdream != 0
      if $Trainer.money < pricenow
        pbPlayBuzzerSE
        pbDisplay(_INTL("Not enough Money!"))
        break
      else
        kuraychoices = [
          _INTL("Re-roll Sprite (P" + pricenow.to_s + ")"),
          _INTL("Nevermind"),
        ]
        kuraychoice = pbShowCommands(
          _INTL("You have P" + $Trainer.money.to_s_formatted), kuraychoices)
        case kuraychoice
        when 0
          $Trainer.money -= pricenow
          pokemon = heldpoke
          if heldpoke
            pokemon = heldpoke
          elsif selected[0] == -1
            pokemon = @storage.party[selected[1]]
          else
            pokemon = @storage.boxes[selected[0]][selected[1]]
          end
          attempts = 10
          while attempts > 0
            attempts -= 1
            newfile = kurayGetCustomSprite(pokemon.dexNum)
            if newfile != pokemon.kuraycustomfile? && newfile != nil
              break
            end
          end
          if newfile != pokemon.kuraycustomfile? && newfile != nil
            pokemon.kuraycustomfile = newfile
            pbKurayRefresh(overlayvar1, overlayvar2)
            pbDisplay(_INTL("Oh! Its sprite changed!"))
            #Best option to refresh sprites so far \/
            break
          else
            pbDisplay(_INTL("Maybe it can't do that..."))
            $Trainer.money += pricenow
            #Best option to refresh sprites so far \/
            break
          end
        when 1
          break
        end
      end
    end
  end

  def pbDefaultSprite(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    if selected[0] == -1
      overlayvar2 = @storage.party
    end
    pricenow = 500
    pricenow = 0 if $PokemonSystem.kuraystreamerdream != 0
    if $Trainer.money < pricenow
      pbPlayBuzzerSE
      pbDisplay(_INTL("Not enough Money!"))
    else
      kuraychoices = [
        _INTL("Use Default Sprite (P" + pricenow.to_s + ")"),
        _INTL("Nevermind"),
      ]
      kuraychoice = pbShowCommands(
        _INTL("You have P" + $Trainer.money.to_s_formatted), kuraychoices)
      case kuraychoice
      when 0
        $Trainer.money -= pricenow
        pokemon = heldpoke
        if heldpoke
          pokemon = heldpoke
        elsif selected[0] == -1
          pokemon = @storage.party[selected[1]]
        else
          pokemon = @storage.boxes[selected[0]][selected[1]]
        end
        if pokemon.kuraycustomfile == nil
          pbPlayBuzzerSE
          pbDisplay(_INTL("No Custom Sprite!"))
        else
          pokemon.kuraycustomfile = "none"
          pbKurayRefresh(overlayvar1, overlayvar2)
          pbDisplay(_INTL("It now uses default sprite!"))
          # if isKurayDefaultSprite(pokemon.dexNum, pokemon.kuraycustomfile)
            # newfile = kurayGetCustomSprite(pokemon.dexNum, 1)
            # if newfile != pokemon.kuraycustomfile? && newfile != nil
            #   pokemon.kuraycustomfile = newfile
            #   pbHardRefresh
            #   pbDisplay(_INTL("Its sprite went back to default!"))
            # else
            #   pbDisplay(_INTL("Maybe it can't do that..."))
            #   $Trainer.money += pricenow
            # end
          # end
          # if pokemon.kuraycustomfiledefault?
          #   pbDisplay(_INTL("Already on default!"))
          #   $Trainer.money += pricenow
          # else
          #   pokemon.kuraycustomfile = "none"
          #   pbHardRefresh
          #   pbDisplay(_INTL("It now uses default sprite!"))
          # end
        end
      end
    end
  end

  def pbBlackList(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if pokemon.kuraycustomfile == nil
      pbPlayBuzzerSE
      pbDisplay(_INTL("No Custom Sprite!"))
    else
      kuraychoices = [
        _INTL("Blacklist"),
        _INTL("Nevermind"),
      ]
      kuraychoice = pbShowCommands(
        _INTL("Blacklisted sprites will never be used by any Pokemon ever again."), kuraychoices)
      case kuraychoice
      when 0
        if pbConfirmMessageSerious(_INTL("Are you sure?"))
          if isKurayDefaultSprite(pokemon.dexNum, pokemon.kuraycustomfile)
            pbDisplay(_INTL("Cannot blacklist default!"))
          else
            pokemon.kuraycustomfile = kurayPlayerBlackList(pokemon.dexNum, pokemon.kuraycustomfile)
            pbKurayRefresh(overlayvar1, overlayvar2)
            pbDisplay(_INTL("Sprite blacklisted!"))
          end
        end
      end
    end
  end

  def pbShowSprite(selected, heldpoke)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if pokemon.kuraycustomfile == nil
      pbPlayBuzzerSE
      pbDisplay(_INTL("No Custom Sprite!"))
    else
      krtempname = File.basename(pokemon.kuraycustomfile)
      pbDisplay(_INTL(krtempname))
    end
  end

  def pbShinyFinder(selected, heldpoke)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if pokemon.kuraycustomfile == nil
      pbPlayBuzzerSE
      pbDisplay(_INTL("No Custom Sprite!"))
    else
      if File.file?("Shiny Finder.exe")
        exe_path = 'Shiny Finder.exe'
        arguments = ' --pxd="' + pokemon.kuraycustomfile.to_s + '" --red=' + pokemon.shinyR.to_s + ' --green=' + pokemon.shinyG.to_s + ' --blue=' + pokemon.shinyB.to_s + ' --hue=' + (pokemon.shinyValue).to_s + ' --krs=' + (pokemon.shinyKRS).to_s
        system('start "ini" "' + exe_path.to_s + '" ' + arguments.to_s)
      else
        pbPlayBuzzerSE
        pbDisplay(_INTL("'Shiny Finder.exe' not found!"))
      end
    end
  end

  def pbShinySell(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if !pokemon.shiny?
      pbPlayBuzzerSE
      pbDisplay(_INTL("Not Shiny!"))
    else
      kuraychoices = [
        _INTL("Unshiny (+P1000)"),
        _INTL("Nevermind"),
      ]
      kuraychoice = pbShowCommands(
        _INTL("Are you sure to unshiny?"), kuraychoices)
      case kuraychoice
      when 0
        $Trainer.money += 1000
        # pokemon = heldpoke
        pokemon.shiny=false
        # newvalue = rand(0..360) - 180
        # pokemon.shinyValue=newvalue
        # pokemon.shinyR=kurayRNGforChannels
        # pokemon.shinyG=kurayRNGforChannels
        # pokemon.shinyB=kurayRNGforChannels
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Shiny, no more!"))
      end
    end
  end

  def pbKuraShinify(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    if selected[0] == -1
      overlayvar2 = @storage.party
    end
    pricenow = 1000
    pricenow = 0 if $PokemonSystem.kuraystreamerdream != 0
    while true
      if $Trainer.money < pricenow
        pbPlayBuzzerSE
        pbDisplay(_INTL("Not enough Money!"))
        break
      else
        pokemon = heldpoke
        if heldpoke
          pokemon = heldpoke
        elsif selected[0] == -1
          pokemon = @storage.party[selected[1]]
        else
          pokemon = @storage.boxes[selected[0]][selected[1]]
        end
        if pokemon.shiny? && $PokemonSystem.kuraynormalshiny == 1
          pbPlayBuzzerSE
          pbDisplay(_INTL("Pokemon already Shiny!"))
          break
        end
        gambletext="Gamble for Shiny (P" + pricenow.to_s + ")" if !pokemon.shiny?
        gambletext="Gamble for new Color (P" + pricenow.to_s + ")" if pokemon.shiny?
        kuraychoices = [
          _INTL(gambletext),
          _INTL("Nevermind"),
        ]
        kuraychoice = pbShowCommands(
          _INTL("You have P" + $Trainer.money.to_s_formatted), kuraychoices)
        case kuraychoice
        when 0
          $Trainer.money -= pricenow
          if $PokemonSystem.kuraygambleodds == nil || !$PokemonSystem.kuraygambleodds
            $PokemonSystem.kuraygambleodds = 100
          end
          if $PokemonSystem.kuraygambleodds == 0
            kurayshiny = 1
          else
            kurayshiny = $PokemonSystem.kuraygambleodds
          end
          becomeshiny = rand(kurayshiny)
          if becomeshiny == 0 || (pokemon.shiny? && becomeshiny == 1)
            if pokemon.shiny?
              newvalue = rand(0..360) - 180
              pokemon.shinyValue=newvalue
              pokemon.shinyR=kurayRNGforChannels
              pokemon.shinyG=kurayRNGforChannels
              pokemon.shinyB=kurayRNGforChannels
              pokemon.shinyKRS=kurayKRSmake
              pbKurayRefresh(overlayvar1, overlayvar2)
              pbDisplay(_INTL("Wait... Its shiny color changed!"))
            else
              pokemon.shiny=true
              pbKurayRefresh(overlayvar1, overlayvar2)
              pbDisplay(_INTL("Wait... It became shiny!"))
            end
            # break
          else
            pbDisplay(_INTL("Not this time :c Try again!"))
          end
        when 1
          break
        end
      end
    end
  end

  def pbKurayRefresh(selectid, useparty=nil)#This refresh the entire box storage (refresh the sprites in the box, and the displayed sprite on the left for the selected Pokemon as well)
    if useparty
      pbUpdateOverlay(selectid, useparty)
    else
      pbUpdateOverlay(selectid)
    end
    pbHardRefresh
  end

  def pbDefineShinycolor(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil

    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    qty = 360
    helptext = pbDisplay(_INTL("Hue (0-360)"))
    params = ChooseNumberParams.new
    params.setMaxDigits(3)
    params.setRange(0, 360)
    params.setDefaultValue(pokemon.shinyValue?+180)
    params.setInitialValue(pokemon.shinyValue?+180)
    params.setCancelValue(pokemon.shinyValue?+180)
    params.setNegativesAllowed(false)
    qty = @scene.pbChooseNumber(helptext,params)
    if qty < 361
      if qty > -1
        newvalue = qty - 180
        pokemon.shinyValue=newvalue
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed Shiny Hue!"))
      end
    end
    qty = 0
    helptext = pbDisplay(_INTL("RedChannel (0-25)"))
    params = ChooseNumberParams.new
    params.setMaxDigits(2)
    params.setRange(0, 25)
    #Before ChatGPT new
    # params.setRange(0, 2)
    params.setDefaultValue(pokemon.shinyR?)
    params.setInitialValue(pokemon.shinyR?)
    params.setCancelValue(pokemon.shinyR?)
    params.setNegativesAllowed(false)
    qty = @scene.pbChooseNumber(helptext,params)
    #Before ChatGPT new
    # if qty < 3
    if qty < 26
      if qty > -1
        pokemon.shinyR=qty
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed Red Channel!"))
      end
    end
    helptext = pbDisplay(_INTL("GreenChannel (0-25)"))
    params = ChooseNumberParams.new
    params.setMaxDigits(2)
    params.setRange(0, 25)
    #Before ChatGPT new
    # params.setRange(0, 2)
    params.setDefaultValue(pokemon.shinyG?)
    params.setInitialValue(pokemon.shinyG?)
    params.setCancelValue(pokemon.shinyG?)
    params.setNegativesAllowed(false)
    qty = @scene.pbChooseNumber(helptext,params)
    #Before ChatGPT new
    # if qty < 3
    if qty < 26
      if qty > -1
        pokemon.shinyG=qty
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed Green Channel!"))
      end
    end
    helptext = pbDisplay(_INTL("BlueChannel (0-25)"))
    params = ChooseNumberParams.new
    params.setMaxDigits(2)
    params.setRange(0, 25)
    #Before ChatGPT new
    # params.setRange(0, 2)
    params.setDefaultValue(pokemon.shinyB?)
    params.setInitialValue(pokemon.shinyB?)
    params.setCancelValue(pokemon.shinyB?)
    params.setNegativesAllowed(false)
    qty = @scene.pbChooseNumber(helptext,params)
    #Before ChatGPT new
    # if qty < 3
    if qty < 26
      if qty > -1
        pokemon.shinyB=qty
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed Blue Channel!"))
      end
    end

    # Increment
    iddoing = 0
    maxdoing = 400
    3.times do |iddoing|
      helptext = pbDisplay(_INTL("#{['R', 'G', 'B'][iddoing]} Increment (0-#{maxdoing})"))
      params = ChooseNumberParams.new
      params.setMaxDigits(3)
      params.setRange(0, maxdoing)
      params.setDefaultValue(pokemon.shinyKRS?[iddoing]+200)
      params.setInitialValue(pokemon.shinyKRS?[iddoing]+200)
      params.setCancelValue(pokemon.shinyKRS?[iddoing]+200)
      params.setNegativesAllowed(false)
      qty = @scene.pbChooseNumber(helptext, params)
      if qty < maxdoing + 1 && qty > -1
        pokemon.shinyKRS[iddoing] = qty-200
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed #{['R', 'G', 'B'][iddoing]} Increment!"))
      end
    end

    # Semi-Inverted
    iddoing = 0
    currslot = 2
    maxdoing = 4
    3.times do |iddoing|
      currslot += 1
      helptext = pbDisplay(_INTL("#{['R', 'G', 'B'][iddoing]} Semi-Inverted (0-#{maxdoing})"))
      params = ChooseNumberParams.new
      params.setMaxDigits(1)
      params.setRange(0, maxdoing)
      params.setDefaultValue(pokemon.shinyKRS?[currslot])
      params.setInitialValue(pokemon.shinyKRS?[currslot])
      params.setCancelValue(pokemon.shinyKRS?[currslot])
      params.setNegativesAllowed(false)
      qty = @scene.pbChooseNumber(helptext, params)
      if qty < maxdoing + 1 && qty > -1
        pokemon.shinyKRS[currslot] = qty
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed #{['R', 'G', 'B'][iddoing]} Semi-Inverted!"))
      end
    end

    # TimidBlack
    iddoing = 0
    currslot = 5
    maxdoing = 2
    3.times do |iddoing|
      currslot += 1
      helptext = pbDisplay(_INTL("#{['R', 'G', 'B'][iddoing]} Timid-Black (0-#{maxdoing})"))
      params = ChooseNumberParams.new
      params.setMaxDigits(1)
      params.setRange(0, maxdoing)
      params.setDefaultValue(pokemon.shinyKRS?[currslot])
      params.setInitialValue(pokemon.shinyKRS?[currslot])
      params.setCancelValue(pokemon.shinyKRS?[currslot])
      params.setNegativesAllowed(false)
      qty = @scene.pbChooseNumber(helptext, params)
      if qty < maxdoing + 1 && qty > -1
        pokemon.shinyKRS[currslot] = qty
        pbKurayRefresh(overlayvar1, overlayvar2)
        pbDisplay(_INTL("Changed #{['R', 'G', 'B'][iddoing]} Timid-Black!"))
      end
    end

  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbRerollShiny(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    newvalue = rand(0..360) - 180
    pokemon.shinyValue=newvalue
    pokemon.shinyR=kurayRNGforChannels
    pokemon.shinyG=kurayRNGforChannels
    pokemon.shinyB=kurayRNGforChannels
    pokemon.shinyKRS=kurayKRSmake
    pbKurayRefresh(overlayvar1, overlayvar2)
    pbDisplay(_INTL("Re-rolled into " + pokemon.shinyValue.to_s + ";" + pokemon.shinyR.to_s + ";" + pokemon.shinyG.to_s + ";" + pokemon.shinyB.to_s + "!"))
  end

  def pbKurayNoEvo(selected, heldpoke)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if pokemon.kuray_no_evo? == 0
      pokemon.kuray_no_evo=1
      pbDisplay(_INTL("Pokemon evolution locked!"))
    else
      pokemon.kuray_no_evo=0
      pbDisplay(_INTL("Pokemon evolution unlocked!"))
    end
  end

  #KurayX
  def pbExport(selected, heldpoke, dodelete=0)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    deletepkm = false
    if $PokemonSystem.exportdelete
      if $PokemonSystem.exportdelete == 1
        deletepkm = true
      end
    end
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    addincra = 0
    cleaned_name = pokemon.name.gsub(/[^a-zA-Z0-9]/, '_')
    importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.personalID.to_s + "-" + pokemon.gender.to_s + "-" + pokemon.level.to_s
    classyname = importname
    while File.file?(importname + ".json") || File.file?(importname + ".png")
      importname = classyname + "(" + addincra.to_s + ")"
      addincra += 1
      if addincra > 9999
        break
      end
    end
    # importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.gender + "-" + pokemon.shiny? + "-" + pokemon.totalhp + "-" + pokemon.level + ".pkm"
    
    giveback=false
    # Marshal not working anymore !
    # File.open(importname + ".pkm", 'wb') { |f| f.write(Marshal.dump(pokemon)) }
    if $PokemonSystem.nopngexport != nil && $PokemonSystem.nopngexport == 2 && pokemon.shiny?
      pokemon.shiny=false
      pokemon.fakeshiny=true
      giveback=true
    end
    File.open(importname + ".json", 'w') { |f| f.write(pokemon.to_json) }
    if $PokemonSystem.nopngexport != nil && $PokemonSystem.nopngexport == 2 && giveback
      # give shininess back after export
      pokemon.shiny=true
      pokemon.fakeshiny=false
    end
    logic_png(pokemon, importname)
    # File.open(importname + ".json3", 'w') { |f| f.write(pokemon.to_s) }
    # File.open(importname + ".json2", 'w') { |f| f.write(pokemon.self) }
    if dodelete == 1 || deletepkm
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(selected[0], selected[1])
      end
      pbKurayRefresh(overlayvar1, overlayvar2)
    end
    pbDisplay(_INTL("Pokemon Exported!"))
  end

  def logic_png(pokemon, importname)
    if $PokemonSystem.nopngexport
      if $PokemonSystem.nopngexport == 1
        return
      end
    end
    # logic for png exporting here
    defaultuse = false
    if pokemon.kuraycustomfile? == nil || ($PokemonSystem.kurayindividcustomsprite && $PokemonSystem.kurayindividcustomsprite == 1)
      # search default
      defaultuse = true
    else
      if !File.file?(pokemon.kuraycustomfile?)
        defaultuse = true
      end
    end
    if defaultuse
      # blabla
      getnum = pokemon.species
      getnum = GameData::Species.get(getnum).id_number
      copyfile = GameData::Species.sprite_filename(getnum)
    else
      copyfile = pokemon.kuraycustomfile?
    end
    begin
      if $PokemonSystem.nopngexport != nil && $PokemonSystem.nopngexport == 2 && pokemon.shiny?
        shinyPNGMake(pokemon, importname + ".png")
      else
        File.copy(copyfile, importname + ".png")
      end
    rescue => e
      return
    end
    return
  end

  def pbExportBox(box)
    deletepkm = false
    if $PokemonSystem.exportdelete
      if $PokemonSystem.exportdelete == 1
        deletepkm = true
      end
    end
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    if @storage[box].empty?
      pbPlayBuzzerSE
      pbDisplay(_INTL("Box is empty!"))
      return
    end
    for k in 0..29
      if @storage[box, k]
        pokemon = @storage[box, k]
        addincra = 0
        cleaned_name = pokemon.name.gsub(/[^a-zA-Z0-9]/, '_')
        importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.personalID.to_s + "-" + pokemon.gender.to_s + "-" + pokemon.level.to_s
        classyname = importname
        while File.file?(importname + ".json") || File.file?(importname + ".png")
          importname = classyname + "(" + addincra.to_s + ")"
          addincra += 1
          if addincra > 9999
            break
          end
        end
        File.open(importname + ".json", 'w') { |f| f.write(pokemon.to_json) }
        logic_png(pokemon, importname)
        if deletepkm
          @storage.pbDelete(box, k)
        end
      end
    end
    pbDisplay(_INTL("Pokemon(s) Exported!"))
  end

  #KurayX
  def pbExportAll()
    deletepkm = false
    if $PokemonSystem.exportdelete
      if $PokemonSystem.exportdelete == 1
        deletepkm = true
      end
    end
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    for j in 0...@storage.maxBoxes
      if @storage[j].empty?
        next
      end
      next if @storage[j].exportlock?
      for k in 0..29
        if @storage[j, k]
          pokemon = @storage[j, k]
          addincra = 0
          cleaned_name = pokemon.name.gsub(/[^a-zA-Z0-9]/, '_')
          importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.personalID.to_s + "-" + pokemon.gender.to_s + "-" + pokemon.level.to_s
          classyname = importname
          while File.file?(importname + ".json") || File.file?(importname + ".png")
            importname = classyname + "(" + addincra.to_s + ")"
            addincra += 1
            if addincra > 9999
              break
            end
          end
          File.open(importname + ".json", 'w') { |f| f.write(pokemon.to_json) }
          logic_png(pokemon, importname)
          if deletepkm
            @storage.pbDelete(j, k)
          end
        end
      end
    end
    for j in 0..5
      if @storage.party[j]
        pokemon = @storage.party[j]
        addincra = 0
        cleaned_name = pokemon.name.gsub(/[^a-zA-Z0-9]/, '_')
        importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.personalID.to_s + "-" + pokemon.gender.to_s + "-" + pokemon.level.to_s
        classyname = importname
        while File.file?(importname + ".json") || File.file?(importname + ".png")
          importname = classyname + "(" + addincra.to_s + ")"
          addincra += 1
          if addincra > 9999
            break
          end
        end
        File.open(importname + ".json", 'w') { |f| f.write(pokemon.to_json) }
        logic_png(pokemon, importname)
        if deletepkm
          @storage.pbDelete(j, k)
        end
      end
    end
    pbDisplay(_INTL("All Pokemons Exported!"))
  end

  #KurayX
  def pbToggleShiny(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
      overlayvar2 = @storage.party
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    if pokemon.shiny?
      pokemon.shiny=false
      pbKurayRefresh(overlayvar1, overlayvar2)
      pbDisplay(_INTL("Pokemon now Normal!"))
    else
      pokemon.shiny=true
      pbKurayRefresh(overlayvar1, overlayvar2)
      pbDisplay(_INTL("Pokemon now Shiny!"))
    end
  end

  #KurayX
  def pbCarpFill(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    if selected[0] == -1
      overlayvar2 = @storage.party
    end
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    importname = directory_name + "/" + "CarpFill.json"
    if File.file?(importname)
      importunevo = false
      importegg = false
      if $PokemonSystem.importegg && $PokemonSystem.importegg == 1
        importegg = true
      end
      importlevel = 0
      if $PokemonSystem.importlvl
        if $PokemonSystem.importlvl == 1
          importlevel = 1
        elsif $PokemonSystem.importlvl == 2
          importlevel = 5
        elsif $PokemonSystem.importlvl == 3
          importlevel = 50
        elsif $PokemonSystem.importlvl == 4
          importlevel = 100
        end
      end
      if $PokemonSystem.importdevolve
        if $PokemonSystem.importdevolve == 1
          importunevo = true
        end
      end
      pokemon = Pokemon.new(:BULBASAUR, 1)
      importdata = File.read(importname)
      pokemon.load_json(eval(importdata), importname)
      if importunevo
        pokemon.species = GameData::Species.get(pokemon.species).get_baby_species(false)
      end
      if importlevel != 0
        pokemon.level = importlevel
        # pokemon.calc_stats
      end
      if importegg
        pokemon.name           = _INTL("Egg")
        pokemon.steps_to_hatch = pokemon.species_data.hatch_steps
        pokemon.hatched_map    = 0
        pokemon.obtain_method  = 1
      end
      # pokemon.calc_stats
      relta = 0
      gelta = 0
      belta = 0
      for p in 0..1727
        if p > @storage.boxes.length-1
          @storage.boxes[@storage.boxes.length] = PokemonBox.new(_INTL("Box {1}",@storage.boxes.length+1),PokemonBox::BOX_SIZE)
        end
        curvalue = -180
        for i in 0..29
          #BoxFilling
          curvalue += 12
          doing = pokemon.clone
          doing.shinyValue=curvalue
          doing.shinyR=relta
          doing.shinyG=gelta
          doing.shinyB=belta
          # pokemon.@personalID = rand(2 ** 16) | rand(2 ** 16) << 16
          garvalue = p*(30)+(i+1)
          doing.name = garvalue.to_s
          @storage.pbImportKuray(p, i, doing)
        end
        relta += 1
        if relta > 25
          relta = 0
          gelta += 1
        end
        if gelta > 25
          relta = 0
          gelta = 0
          belta += 1
        end
        if belta > 25
          relta = 0
          gelta = 0
          belta = 0
        end
      end
      pbKurayRefresh(overlayvar1, overlayvar2)
      pbDisplay(_INTL("CarpFill done!"))
    else
      pbPlayBuzzerSE
      pbDisplay(_INTL("'CarpFill.json' not found!"))
    end
  end

  #KurayX
  def pbImportJson(selected, heldpoke)
    overlayvar1 = selected[1]
    overlayvar2 = nil
    if selected[0] == -1
      overlayvar2 = @storage.party
    end
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    importname = directory_name + "/" + "Exported.json"
    if File.file?(importname)
      importunevo = false
      importegg = false
      if $PokemonSystem.importegg && $PokemonSystem.importegg == 1
        importegg = true
      end
      importlevel = 0
      if $PokemonSystem.importlvl
        if $PokemonSystem.importlvl == 1
          importlevel = 1
        elsif $PokemonSystem.importlvl == 2
          importlevel = 5
        elsif $PokemonSystem.importlvl == 3
          importlevel = 50
        elsif $PokemonSystem.importlvl == 4
          importlevel = 100
        end
      end
      if $PokemonSystem.importdevolve
        if $PokemonSystem.importdevolve == 1
          importunevo = true
        end
      end
      if selected[0] == -1
        pokemon = @storage.party[selected[1]]
        importdata = File.read(importname)
        pokemon.load_json(eval(importdata), importname)
      else
        # pokemon = @storage.boxes[selected[0]][selected[1]]
        pokemon = Pokemon.new(:BULBASAUR, 1)
        importdata = File.read(importname)
        pokemon.load_json(eval(importdata), importname)
      end
      if importunevo
        pokemon.species = GameData::Species.get(pokemon.species).get_baby_species(false)
      end
      if importlevel != 0
        pokemon.level = importlevel
        # pokemon.calc_stats
      end
      if importegg
        pokemon.name           = _INTL("Egg")
        pokemon.steps_to_hatch = pokemon.species_data.hatch_steps
        pokemon.hatched_map    = 0
        pokemon.obtain_method  = 1
      end
      # pokemon.calc_stats
      @storage.pbImportKuray(selected[0], selected[1], pokemon)
      pbKurayRefresh(overlayvar1, overlayvar2)
      pbDisplay(_INTL("Pokemon Imported!"))
    else
      pbPlayBuzzerSE
      pbDisplay(_INTL("'Exported.json' not found!"))
    end
  end

  def pbSummary(selected, heldpoke)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke], 0)
    elsif selected[0] == -1
      @selection = screen.pbStartScreen(@storage.party, selected[1])
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
    else
      @selection = screen.pbStartScreen(@storage.boxes[selected[0]], selected[1])
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites, oldsprites)
    pbHardRefresh
  end

  def pbMarkingSetArrow(arrow, selection)
    if selection >= 0
      xvalues = [162, 191, 220, 162, 191, 220, 184, 184]
      yvalues = [24, 24, 24, 49, 49, 49, 77, 109]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection] * 2
      arrow.y = yvalues[selection] * 2
    end
  end

  def pbMarkingChangeSelection(key, selection)
    case key
    when Input::LEFT
      if selection < 6
        selection -= 1
        selection += 3 if selection % 3 == 2
      end
    when Input::RIGHT
      if selection < 6
        selection += 1
        selection -= 3 if selection % 3 == 0
      end
    when Input::UP
      if selection == 7;
        selection = 6
      elsif selection == 6;
        selection = 4
      elsif selection < 3;
        selection = 7
      else
        ; selection -= 3
      end
    when Input::DOWN
      if selection == 7;
        selection = 1
      elsif selection == 6;
        selection = 7
      elsif selection >= 3;
        selection = 6
      else
        ; selection += 3
      end
    end
    return selection
  end

  def pbMark(selected, heldpoke)
    @sprites["markingbg"].visible = true
    @sprites["markingoverlay"].visible = true
    msg = _INTL("Mark your Pokémon.")
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.text = msg
    msgwindow.resizeHeightToFit(msg, Graphics.width - 180)
    pbBottomRight(msgwindow)
    base = Color.new(248, 248, 248)
    shadow = Color.new(80, 80, 80)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    markings = pokemon.markings
    index = 0
    redraw = true
    markrect = Rect.new(0, 0, 16, 16)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        for i in 0...6
          markrect.x = i * 16
          markrect.y = (markings & (1 << i) != 0) ? 16 : 0
          @sprites["markingoverlay"].bitmap.blt(336 + 58 * (i % 3), 106 + 50 * (i / 3), @markingbitmap.bitmap, markrect)
        end
        textpos = [
          [_INTL("OK"), 402, 208, 2, base, shadow, 1],
          [_INTL("Cancel"), 402, 272, 2, base, shadow, 1]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
        pbMarkingSetArrow(@sprites["arrow"], index)
        redraw = false
      end
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        oldindex = index
        index = pbMarkingChangeSelection(key, index)
        pbPlayCursorSE if index != oldindex
        pbMarkingSetArrow(@sprites["arrow"], index)
      end
      self.update
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if index == 6 # OK
          pokemon.markings = markings
          break
        elsif index == 7 # Cancel
          break
        else
          mask = (1 << index)
          if (markings & mask) == 0
            markings |= mask
          else
            markings &= ~mask
          end
          redraw = true
        end
      end
    end
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"].visible = false
    msgwindow.dispose
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport)
    @sprites["boxparty"].dispose
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport)
    @sprites["boxparty"].y = oldPartyY
    #Sylvi Big Icons
    if @sprites["boxparty"].y >= Graphics.height
      @sprites["boxparty"].hidePokemon
    else
      @sprites["boxparty"].showPokemon
    end
  end

  def drawMarkings(bitmap, x, y, _width, _height, markings)
    markrect = Rect.new(0, 0, 16, 16)
    for i in 0...8
      markrect.x = i * 16
      markrect.y = (markings & (1 << i) != 0) ? 16 : 0
      bitmap.blt(x + i * 16, y, @markingbitmap.bitmap, markrect)
    end
  end

  def pbUpdateOverlay(selection, party = nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248, 248, 248)
    buttonshadow = Color.new(80, 80, 80)
    pbDrawTextPositions(overlay, [
      [_INTL("Party: {1}", (@storage.party.length rescue 0)), 270, 326, 2, buttonbase, buttonshadow, 1],
      [_INTL("Exit"), 446, 326, 2, buttonbase, buttonshadow, 1],
    ])
    pokemon = nil
    if @screen.pbHolding? && !@screen.fusionMode
      pokemon = @screen.pbHeldPokemon
    elsif selection >= 0
      pokemon = (party) ? party[selection] : @storage[@storage.currentBox, selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    nonbase = Color.new(208, 208, 208)
    nonshadow = Color.new(224, 224, 224)
    pokename = pokemon.name
    textstrings = [
      [pokename, 10, 2, false, base, shadow]
    ]
    if !pokemon.egg?
      imagepos = []
      #KurayNewSymbolGender
      kuraygender1t = "♂"
      kuraygender2t = "♀"
      # kuraygender3t = "♃"
      # kuraygender4t = "♄"
      kuraygender1r = [55, 148, 229]
      kuraygender1s = [68, 98, 125]
      kuraygender2r = [229, 55, 203]
      kuraygender2s = [137, 73, 127]
      # kuraygender3r = [55, 229, 81]
      # kuraygender3s = [68, 127, 76]
      # kuraygender4r = [229, 127, 55]
      # kuraygender4s = [135, 95, 69]
      if pokemon.pizza?
        imagepos.push(["Graphics/Pictures/Storage/gender4", 136, 9])
        # textstrings.push([_INTL(kuraygender4t), 148, 2, false, Color.new(kuraygender4r[0], kuraygender4r[1], kuraygender4r[2]), Color.new(kuraygender4s[0], kuraygender4s[1], kuraygender4s[2])])
      elsif pokemon.male?
        textstrings.push([_INTL(kuraygender1t), 148, 2, false, Color.new(kuraygender1r[0], kuraygender1r[1], kuraygender1r[2]), Color.new(kuraygender1s[0], kuraygender1s[1], kuraygender1s[2])])
      elsif pokemon.female?
        textstrings.push([_INTL(kuraygender2t), 148, 2, false, Color.new(kuraygender2r[0], kuraygender2r[1], kuraygender2r[2]), Color.new(kuraygender2s[0], kuraygender2s[1], kuraygender2s[2])])
      elsif pokemon.genderless?
        imagepos.push(["Graphics/Pictures/Storage/gender3", 136, 15])
        # textstrings.push([_INTL(kuraygender3t), 148, 2, false, Color.new(kuraygender3r[0], kuraygender3r[1], kuraygender3r[2]), Color.new(kuraygender3s[0], kuraygender3s[1], kuraygender3s[2])])
      end
      imagepos.push(["Graphics/Pictures/Storage/overlay_lv", 6, 246])
      textstrings.push([pokemon.level.to_s, 28, 228, false, base, shadow])
      if pokemon.ability
        textstrings.push([pokemon.ability.name, 86, 300, 2, base, shadow])
      else
        textstrings.push([_INTL("No ability"), 86, 300, 2, nonbase, nonshadow])
      end
      if pokemon.item
        textstrings.push([pokemon.item.name, 86, 336, 2, base, shadow])
      else
        textstrings.push([_INTL("No item"), 86, 336, 2, nonbase, nonshadow])
      end
      if pokemon.shiny? || pokemon.fakeshiny?
        #KurayX new ShinyStars
        addShinyStarsToGraphicsArray(imagepos,156,198,pokemon.bodyShiny?,pokemon.headShiny?,pokemon.debugShiny?,nil,nil,nil,nil,false,true,pokemon.fakeshiny?,[pokemon.shinyR?,pokemon.shinyG?,pokemon.shinyB?,pokemon.shinyKRS?])
        #imagepos.push(["Graphics/Pictures/shiny", 156, 198])
      end
      typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      type1_number = GameData::Type.get(pokemon.type1).id_number
      type2_number = GameData::Type.get(pokemon.type2).id_number
      type1rect = Rect.new(0, type1_number * 28, 64, 28)
      type2rect = Rect.new(0, type2_number * 28, 64, 28)
      if pokemon.type1 == pokemon.type2
        overlay.blt(52, 272, typebitmap.bitmap, type1rect)
      else
        overlay.blt(18, 272, typebitmap.bitmap, type1rect)
        overlay.blt(88, 272, typebitmap.bitmap, type2rect)
      end
      drawMarkings(overlay, 70, 240, 128, 20, pokemon.markings)
      pbDrawImagePositions(overlay, imagepos)
    end
    pbDrawTextPositions(overlay, textstrings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)

    if pokemon.egg?
      @sprites["pokemon"].zoom_x = Settings::EGGSPRITE_SCALE
      @sprites["pokemon"].zoom_y = Settings::EGGSPRITE_SCALE
    else
      @sprites["pokemon"].zoom_x = Settings::FRONTSPRITE_SCALE
      @sprites["pokemon"].zoom_y = Settings::FRONTSPRITE_SCALE
    end

  end

  def pbUpdateSelectionRect(box, selected)
    if !@screen.multiSelectRange
      @sprites["selectionrect"].visible = false
      return
    end

    displayRect = Rect.new(0, 0, 1, 1)

    if box == -1
      xvalues = [] # [18, 90, 18, 90, 18, 90]
      yvalues = [] # [2, 18, 66, 82, 130, 146]
      for i in 0...Settings::MAX_PARTY_SIZE
        xvalues.push(@sprites["boxparty"].x + 18 + 72 * (i % 2))
        yvalues.push(@sprites["boxparty"].y + 2 + 16 * (i % 2) + 64 * (i / 2))
      end
      indexes = @screen.getMultiSelection(box, selected)
      minx = xvalues[indexes[0]]
      miny = yvalues[indexes[0]] + 16
      maxx = xvalues[indexes[indexes.length-1]] + 72 - 8
      maxy = yvalues[indexes[indexes.length-1]] + 64
      displayRect.set(minx, miny, maxx-minx, maxy-miny)
    else
      indexRect = @screen.getSelectionRect(box, selected)
      displayRect.x = @sprites["box"].x + 10 + (48 * indexRect.x)
      displayRect.y = @sprites["box"].y + 30 + (48 * indexRect.y) + 16
      displayRect.width = indexRect.width * 48 + 16
      displayRect.height = indexRect.height * 48
    end

    @sprites["selectionrect"].bitmap.clear
    @sprites["selectionrect"].bitmap.fill_rect(displayRect.x, displayRect.y, displayRect.width, displayRect.height, Color.new(0, 255, 0, 100))
    @sprites["selectionrect"].visible = true
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def setFusing(fusing, item = 0)
    sprite = @sprites["arrow"].setFusing(fusing)
    if item == :INFINITESPLICERS
      @sprites["arrow"].setSplicerType(2)
    elsif item == :SUPERSPLICERS
      @sprites["arrow"].setSplicerType(1)
    else
      @sprites["arrow"].setSplicerType(0)
    end
    pbRefresh
  end

end

#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage
  attr_accessor :heldpkmn
  attr_accessor :multiheldpkmn
  attr_accessor :fusionMode
  attr_accessor :multiSelectRange

  def initialize(scene, storage)
    @scene = scene
    @storage = storage
    @pbHeldPokemon = nil
    @multiheldpkmn = []
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbChooseNumber(helptext,maximum,initnum=1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"],helptext,maximum,initnum) { pbUpdate }
  end

  #KurayX - KURAYX_ABOUT_SHINIES(except pc functionnalities that are in cmd calls)
  def pbStartScreen(command)
    @heldpkmn = nil
    @multiheldpkmn = []
    if command == 0 # Organise
      @scene.pbStartBox(self, command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected == nil
          if pbHolding?
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if @multiSelectRange
            pbPlayCancelSE
            @multiSelectRange = nil
            @scene.pbUpdateSelectionRect(0, 0)
            next
          end
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        elsif selected[0] == -3 # Close box
          if pbHolding?
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected[0] == -4 # Box name
          pbBoxCommands
        else
          pokemon = @storage[selected[0], selected[1]]
          heldpoke = pbHeldPokemon
          if @scene.cursormode == "multiselect"
            if pbMultiHeldPokemon.length > 0
              pbPlaceMulti(selected[0], selected[1])
            elsif !@multiSelectRange
              pbPlayDecisionSE
              @multiSelectRange = [selected[1], nil]
              @scene.pbUpdateSelectionRect(selected[0], selected[1])
              next
            elsif !@multiSelectRange[1]
              @multiSelectRange[1] = selected[1]

              pokemonCount = 0
              noneggCount = 0
              for index in getMultiSelection(selected[0], nil)
                pokemonCount += 1 if @storage[selected[0], index]
                if @storage[selected[0], index]
                  unless @storage[selected[0], index].egg?
                    noneggCount += 1
                  end
                end
              end

              if pokemonCount == 0
                pbPlayCancelSE
                @multiSelectRange = nil
                @scene.pbUpdateSelectionRect(selected[0], selected[1])
                next
              end

              commands = []
              cmdMove = -1
              cmdRelease = -1
              cmdCancel = -1
              cmdExport = -1
              cmdBattle = -1
              canExportImport = true
              if $PokemonSystem.debugfeature
                if $PokemonSystem.debugfeature == 1
                  canExportImport = false
                end
              end
              
              helptext = _INTL("Selected {1} Pokémon.", pokemonCount)

              commands[cmdMove = commands.length] = _INTL("Move")
              commands[cmdRelease = commands.length] = _INTL("Release")
              # WIP
              commands[cmdBattle = commands.length] = _INTL("Battle Selected") if noneggCount < 7 && noneggCount > 0
              commands[cmdExport = commands.length] = _INTL("Export") if $DEBUG || canExportImport
              commands[cmdCancel = commands.length] = _INTL("Cancel")

              command = pbShowCommands(helptext, commands)

              if command == cmdMove
                pbHoldMulti(selected[0], selected[1])
              elsif command == cmdRelease
                pbReleaseMulti(selected[0])
              elsif cmdExport >= 0 && command == cmdExport # Export
                pbExportSelected(selected[0])
              elsif cmdBattle >= 0 && command == cmdBattle # Battle
                while true
                  if $PokemonSystem.sb_loopbreaker
                    if $PokemonSystem.sb_loopbreaker == 1
                      $PokemonSystem.sb_loopbreaker = 0
                      break
                    end
                  end
                  pbBattleSelected(selected[0], true)
                end
              end

              @multiSelectRange = nil
              @scene.pbUpdateSelectionRect(selected[0], selected[1])
            end
          elsif !pokemon && !heldpoke
            next
          elsif @scene.cursormode == "quickswap"
            if @heldpkmn
              if pokemon
                pbSwap(selected)
              else
                pbPlace(selected)
                cancelFusion() if @fusionMode
              end
            else
              pbHold(selected)
            end
          else
            if @fusionMode
              pbFusionCommands(selected)
            else
              commands = []
              cmdMove = -1
              cmdSummary = -1
              cmdWithdraw = -1
              cmdItem = -1
              cmdFuse = -1
              cmdUnfuse = -1
              cmdReverse = -1
              cmdRelease = -1
              cmdDebug = -1
              cmdCancel = -1
              cmdNickname = -1
              # cmdImportJson = -1
              # cmdExport = -1
              # cmdExportAll = -1
              # cmdShinyReroll = -1
              # cmdShinyChoose = -1
              # cmdEvoLock = -1
              # cmdShinify = -1
              # cmdToggleShiny = -1
              # cmdCarpFill = -1
              cmdKurayAct = -1
              if heldpoke
                helptext = _INTL("{1} is selected.", heldpoke.name)
                commands[cmdMove = commands.length] = (pokemon) ? _INTL("Shift") : _INTL("Place")
              elsif pokemon
                helptext = _INTL("{1} is selected.", pokemon.name)
                commands[cmdMove = commands.length] = _INTL("Move")
              end
              commands[cmdSummary = commands.length] = _INTL("Summary")
              if pokemon != nil
                if dexNum(pokemon.species) > NB_POKEMON
                  commands[cmdUnfuse = commands.length] = _INTL("Unfuse")
                  commands[cmdReverse = commands.length] = _INTL("Reverse") if $PokemonBag.pbQuantity(:DNAREVERSER) > 0 || $PokemonBag.pbQuantity(:INFINITEREVERSERS) > 0
                else
                  commands[cmdFuse = commands.length] = _INTL("Fuse") if !@heldpkmn
                end
              end
              commands[cmdNickname = commands.length] = _INTL("Nickname") if !@heldpkmn
              commands[cmdWithdraw = commands.length] = (selected[0] == -1) ? _INTL("Store") : _INTL("Withdraw")
              commands[cmdItem = commands.length] = _INTL("Item")

              commands[cmdRelease = commands.length] = _INTL("Release")
              # if heldpoke
              #   commands[cmdEvoLock = commands.length] = _INTL("Lock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && heldpoke.kuray_no_evo? == 0)
              #   commands[cmdEvoLock = commands.length] = _INTL("Unlock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && heldpoke.kuray_no_evo? == 1)
                # commands[cmdShinify = commands.length] = _INTL("Gamble for Shiny (P1000)") if !heldpoke.shiny?
                # commands[cmdShinify = commands.length] = _INTL("Gamble for new Color (P1000)") if heldpoke.shiny?
              # elsif pokemon
              #   commands[cmdEvoLock = commands.length] = _INTL("Lock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && pokemon.kuray_no_evo? == 0)
              #   commands[cmdEvoLock = commands.length] = _INTL("Unlock Evolution") if ($PokemonSystem.kuray_no_evo == 1 && pokemon.kuray_no_evo? == 1)
                # commands[cmdShinify = commands.length] = _INTL("Gamble for Shiny (P1000)") if !pokemon.shiny?
                # commands[cmdShinify = commands.length] = _INTL("Gamble for new Color (P1000)") if pokemon.shiny?
              # end
              commands[cmdKurayAct = commands.length] = _INTL("Kuray Actions")
              # commands[cmdImportJson = commands.length] = _INTL("Import") if $DEBUG
              # commands[cmdExport = commands.length] = _INTL("Export") if $DEBUG
              # commands[cmdExportAll = commands.length] = _INTL("Export All Pokemons") if $DEBUG
              # commands[cmdShinyReroll = commands.length] = _INTL("Re-roll Shiny Color") if $DEBUG
              # commands[cmdShinyChoose = commands.length] = _INTL("Set Shiny Color") if $DEBUG
              # commands[cmdCarpFill = commands.length] = _INTL("CarpFill") if $DEBUG && File.exists?("Kurayami.krs")
              # commands[cmdToggleShiny = commands.length] = _INTL("Toggle Shiny") if $DEBUG && File.exists?("Kurayami.krs")
              commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG
              commands[cmdCancel = commands.length] = _INTL("Cancel")
              command = pbShowCommands(helptext, commands)
              if cmdMove >= 0 && command == cmdMove # Move/Shift/Place
                if @heldpkmn
                  (pokemon) ? pbSwap(selected) : pbPlace(selected)
                else
                  pbHold(selected)
                end
              elsif cmdSummary >= 0 && command == cmdSummary # Summary
                pbSummary(selected, @heldpkmn)
              # elsif cmdEvoLock >= 0 && command == cmdEvoLock # EvoLock
              #   pbKurayNoEvo(selected, @heldpkmn)
              # elsif cmdExport >= 0 && command == cmdExport # Export
              #   pbExport(selected, @heldpkmn, 0)
              # elsif cmdExportAll >= 0 && command == cmdExportAll # Export ALL
              #   pbExportAll(selected, @heldpkmn, 0)
              # elsif cmdImportJson >= 0 && command == cmdImportJson # Import Json
              #   pbImportJson(selected, @heldpkmn)
              # elsif cmdToggleShiny >= 0 && command == cmdToggleShiny # Toggle Shiny
              #   pbToggleShiny(selected, @heldpkmn)
              # elsif cmdCarpFill >= 0 && command == cmdCarpFill # Carp Fill
              #   pbCarpFill(selected, @heldpkmn)
              # elsif cmdShinyReroll >= 0 && command == cmdShinyReroll # Re-roll Shiny Color
              #   pbRerollShiny(selected, @heldpkmn)
              # elsif cmdShinyChoose >= 0 && command == cmdShinyChoose # Set Shiny Color
              #   pbDefineShinycolor(selected, @heldpkmn)
              # elsif cmdShinify >= 0 && command == cmdShinify # Shinify
                # pbKuraShinify(selected, @heldpkmn)
              elsif cmdKurayAct >= 0 && command == cmdKurayAct # KurayAct
                pbKurayAct(selected, @heldpkmn)
              elsif cmdNickname >= 0 && command == cmdNickname # Rename
                renamePokemon(selected, @heldpkmn)
              elsif cmdWithdraw >= 0 && command == cmdWithdraw # Store/Withdraw
                (selected[0] == -1) ? pbStore(selected, @heldpkmn) : pbWithdraw(selected, @heldpkmn)
              elsif cmdItem >= 0 && command == cmdItem # Item
                pbItem(selected, @heldpkmn)
              elsif cmdFuse >= 0 && command == cmdFuse # fuse
                pbFuseFromPC(selected, @heldpkmn)
              elsif cmdUnfuse >= 0 && command == cmdUnfuse # unfuse
                pbUnfuseFromPC(selected)
              elsif cmdReverse >= 0 && command == cmdReverse # unfuse
                reverseFromPC(selected)
              elsif cmdRelease >= 0 && command == cmdRelease # Release
                pbRelease(selected, @heldpkmn)
              elsif cmdDebug >= 0 && command == cmdDebug # Debug
                pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon, selected, heldpoke)
              end
            end
          end
        end
      end
      @scene.pbCloseBox
    elsif command == 1 # Withdraw
      @scene.pbStartBox(self, command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected == nil
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          case selected[0]
          when -2 # Party Pokémon
            pbDisplay(_INTL("Which one will you take?"))
            next
          when -3 # Close box
            if pbConfirm(_INTL("Exit from the Box?"))
              pbSEPlay("PC close")
              break
            end
            next
          when -4 # Box name
            pbBoxCommands
            next
          end
          if @fusionMode
            pbFusionCommands(selected)
          else
            pokemon = @storage[selected[0], selected[1]]
            next if !pokemon
            command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
              _INTL("Withdraw"),
              _INTL("Summary"),
              _INTL("Release"),
              _INTL("Cancel")
            ])
            case command
            when 0 then
              pbWithdraw(selected, nil)
            when 1 then
              pbSummary(selected, nil)
              #when 2 then pbMark(selected, nil)
            when 2 then
              pbRelease(selected, nil)
            end

          end
        end
      end
      @scene.pbCloseBox
    elsif command == 2 # Deposit
      @scene.pbStartBox(self, command)
      loop do
        selected = @scene.pbSelectParty(@storage.party)
        if selected == -3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected < 0
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          pokemon = @storage[-1, selected]
          next if !pokemon
          command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
            _INTL("Store"),
            _INTL("Summary"),
            _INTL("Mark"),
            _INTL("Release"),
            _INTL("Cancel")
          ])
          case command
          when 0 then
            pbStore([-1, selected], nil)
          when 1 then
            pbSummary([-1, selected], nil)
          when 2 then
            pbMark([-1, selected], nil)
          when 3 then
            pbRelease([-1, selected], nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command == 3
      @scene.pbStartBox(self, command)
      @scene.pbCloseBox
    end
  end


  def renamePokemon(selected, heldpoke)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    # box = selected[0]
    # index = selected[1]
    # pokemon = @storage[box, index]

    if pokemon.egg?
      pbDisplay(_INTL("You cannot rename an egg!"))
      return
    end

    speciesname = PBSpecies.getName(pokemon.species)
    hasNickname = speciesname == pokemon.name
    if hasNickname
      pbDisplay(_INTL("{1} has no nickname.", speciesname))
    else
      pbDisplay(_INTL("{1} has the nickname {2}.", speciesname, pokemon.name))
    end
    commands = [
      _INTL("Rename"),
      _INTL("Quit")
    ]
    command = pbShowCommands(
      _INTL("What do you want to do?"), commands)
    case command
    when 0
      newname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname), 0, Pokemon::MAX_NAME_SIZE, "", pokemon)
      pokemon.name = (newname == "") ? speciesname : newname
      pbDisplay(_INTL("{1} is now named {2}!", speciesname, pokemon.name))
    when 1
      return
    end
  end

  def pbUpdate # For debug
    @scene.update
  end

  def pbHardRefresh # For debug
    @scene.pbHardRefresh
  end

  def pbKurayRefresh # For debug
    @scene.pbKurayRefresh
  end

  def pbUpdateOverlay(selection, party = nil) # For debug
    @scene.pbUpdateOverlay(selection, party)
  end

  def pbRefreshSingle(i)
    # For debug
    @scene.pbUpdateOverlay(i[1], (i[0] == -1) ? @storage.party : nil)
    @scene.pbHardRefresh
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbConfirm(str)
    return pbShowCommands(str, [_INTL("Yes"), _INTL("No")]) == 0
  end

  def pbShowCommands(msg, commands, index = 0)
    return @scene.pbShowCommands(msg, commands, index)
  end

  def pbAble?(pokemon)
    pokemon && !pokemon.egg? && pokemon.hp > 0
  end

  def pbAbleCount
    count = 0
    for p in @storage.party
      count += 1 if pbAble?(p)
    end
    return count
  end

  def pbHeldPokemon
    return @heldpkmn
  end

  def pbMultiHeldPokemon
    return @multiheldpkmn
  end

  def pbHolding?
    return @heldpkmn != nil || @multiheldpkmn.length > 0
  end

  def pbWithdraw(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box == -1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage.party_full?
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    @scene.pbWithdraw(selected, heldpoke, @storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn = nil
    else
      @storage.pbMove(-1, -1, box, index)
    end
    @scene.pbRefresh
    return true
  end

  def pbStore(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box != -1
      raise _INTL("Can't deposit from box...")
    end
    if pbAbleCount <= 1 && pbAble?(@storage[box, index]) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif heldpoke && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !heldpoke && @storage[box, index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox >= 0
          firstfree = @storage.pbFirstFreePos(destbox)
          if firstfree < 0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          if heldpoke || selected[0] == -1
            p = (heldpoke) ? heldpoke : @storage[-1, index]
            p.time_form_set = nil
            # p.form = 0 if p.isSpecies?(:SHAYMIN)
            p.heal if !$game_temp.fromkurayshop
          end
          @scene.pbStore(selected, heldpoke, destbox, firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke, destbox)
            @heldpkmn = nil
          else
            @storage.pbMove(destbox, -1, -1, index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbHold(selected)
    box = selected[0]
    index = selected[1]
    if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn = @storage[box, index]
    @storage.pbDelete(box, index)
    @scene.pbRefresh
  end

  def pbSetHeldPokemon(pokemon)
    return false if @heldpkmn
    @scene.pbSetHeldPokemon(pokemon)
    @heldpkmn = pokemon
    @scene.pbRefresh
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @storage[box, index]
      pbDisplay("Can't place that there.")
      return
      echoln _INTL("Position {1},{2} is not empty...", box, index)
    end
    if box != -1 && index >= @storage.maxPokemon(box)
      pbDisplay("Can't place that there.")
      return
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return
    end
    if box >= 0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal if !$game_temp.fromkurayshop
    end
    @scene.pbPlace(selected, @heldpkmn)
    @storage[box, index] = @heldpkmn
    if box == -1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]
    if !@storage[box, index]
      raise _INTL("Position {1},{2} is empty...", box, index)
    end
    if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1 && !pbAble?(@heldpkmn)
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return false
    end
    if box >= 0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal if !$game_temp.fromkurayshop
    end
    @scene.pbSwap(selected, @heldpkmn)
    tmp = @storage[box, index]
    @storage[box, index] = @heldpkmn
    @heldpkmn = tmp
    @scene.pbRefresh
    return true
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box, index]
    return if !pokemon
    if pokemon.owner.name  == "RENTAL"
      pbDisplay(_INTL("This Pokémon cannot be released"))
      return
    elsif pokemon.egg?
      pbDisplay(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box == -1 && pbAbleCount <= 1 && pbAble?(pokemon) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release this Pokémon?"), [_INTL("No"), _INTL("Yes")])
    if command == 1
      pkmnname = pokemon.name
      @scene.pbRelease(selected, heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box, index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.", pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!", pkmnname))
      @scene.pbRefresh
    end
    return
  end

  def pbHoldMulti(box, selectedIndex)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    selectedPos = getBoxPosition(box, selectedIndex)
    ableCount = 0
    newHeld = []
    finalSelected = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      ableCount += 1 if pbAble?(pokemon)
      pos = getBoxPosition(box, index)
      newHeld.push([pokemon, pos[0] - selectedPos[0], pos[1] - selectedPos[1]])
      finalSelected.push(index)
    end
    if box == -1 && pbAbleCount == ableCount
      if newHeld.length > 1
        # For convenience: if you selected every Pokémon in the party, deselect the first one
        for i in 0...newHeld.length
          if pbAble?(newHeld[i][0])
            newHeld.delete_at(i)
            finalSelected.delete_at(i)
            break
          end
        end
      else
        pbPlayBuzzerSE
        pbDisplay(_INTL("That's your last Pokémon!"))
        return
      end
    end
    @multiSelectRange = nil
    @scene.pbUpdateSelectionRect(0, 0)
    @scene.pbHoldMulti(box, finalSelected, selectedIndex)
    @multiheldpkmn = newHeld
    @storage.pbDeleteMulti(box, finalSelected)
    @scene.pbRefresh
  end

  def pbPlaceMulti(box, selectedIndex)
    selectedPos = getBoxPosition(box, selectedIndex)
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    boxHeight = box == -1 ? (Settings::MAX_PARTY_SIZE / 2).ceil : PokemonBox::BOX_HEIGHT
    if box >= 0
      for held in @multiheldpkmn
        heldX = held[1] + selectedPos[0]
        heldY = held[2] + selectedPos[1]
        if heldX < 0 || heldX >= PokemonBox::BOX_WIDTH || heldY < 0 || heldY >= PokemonBox::BOX_HEIGHT
          pbDisplay("Can't place that there.")
          return
        end
        if @storage[box, heldX + heldY * PokemonBox::BOX_WIDTH]
          pbDisplay("Can't place that there.")
          return
        end
      end
      @scene.pbPlaceMulti(box, selectedIndex)
      for held in @multiheldpkmn
        pokemon = held[0]
        heldX = held[1] + selectedPos[0]
        heldY = held[2] + selectedPos[1]
        pokemon.time_form_set = nil
        pokemon.form = 0 if pokemon.isSpecies?(:SHAYMIN)
        pokemon.heal if !$game_temp.fromkurayshop
        @storage[box, heldX + heldY * PokemonBox::BOX_WIDTH] = pokemon
      end
    else
      partyCount = @storage.party.length
      if partyCount + @multiheldpkmn.length > Settings::MAX_PARTY_SIZE
        pbDisplay("Can't place that there.")
        return
      end
      @scene.pbPlaceMulti(box, selectedIndex)
      for held in @multiheldpkmn
        pokemon = held[0]
        pokemon.time_form_set = nil
        pokemon.form = 0 if pokemon.isSpecies?(:SHAYMIN)
        pokemon.heal if !$game_temp.fromkurayshop
        @storage.party.push(pokemon)
      end
    end
    @scene.pbRefresh
    @multiheldpkmn = []
  end
  
  def init_trainer(trainer_data)
    return trainer_data  # Just return the provided data without trying to convert it
  end
  
  def createTrainer(trainerid,trainername,party,items=[])
    name = pbGetMessageFromHash(MessageTypes::TrainerNames, trainername)

    trainer_hash = {
      :id_number    => 999,
      :trainer_type => trainerid,
      :name         => name,
      :version      => 0,
      :pokemon      => party,
      :items        => items
    }
    opponent = GameData::Trainer.new(trainer_hash)
    # opponent.setForeignID($Trainer) if $Trainer
    # opponent.party = party
    return [opponent, items, party]
  end
 
  def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil)
    trainer = NPCTrainer.new(trainerName, trainerType, sprite_override)
    trainer.lose_text = endSpeech
    party = []
    party_array.each do |pokemon|
    if pokemon.is_a?(Pokemon)
      party << pokemon
    # elsif pokemon.is_a?(Symbol)
    #   party << Pokemon.new(pokemon, default_level, trainer)
    # elsif pokemon.is_a?(Hash)  # Handle hash representations
    #   new_pokemon = Pokemon.new(pokemon[:species], pokemon[:level], trainer)
    #   new_pokemon.ability = pokemon[:ability]
	#   new_pokemon.ability_index = pokemon[:ability_index]
	#   # You can set other attributes like moves, IVs, EVs here if needed
    #   party << new_pokemon
      end
    end
    trainer.party = party
    $PokemonSystem.nomoneylost = 1
    setBattleRule("noexp")
    setBattleRule("canLose")
    Events.onTrainerPartyLoad.trigger(nil, trainer)
    decision = pbTrainerBattleCore(trainer)
    # Return true if the player won the battle, false otherwise
    return decision
  end

  def battlebr(defaultteam)
    if defaultteam
      $Trainer.party=defaultteam
    end
    $PokemonSystem.sb_loopbreaker = 1
    @scene.pbHardRefresh
    $Trainer.heal_party# healing player again
    return
  end

  # def build_tree(directory_name)
  #   tree = []
  #   # Check if the current directory has .json files
  #   json_files = Dir.glob(File.join(directory_name, "*.json"))
  #   tree << File.basename(directory_name) if json_files.any?
  #   # Recursively traverse child directories
  #   directories = Dir.glob(File.join(directory_name, "*")).select { |entry| File.directory?(entry) }
  #   directories.each do |entry|
  #     subdir_tree = build_tree(entry)
  #     subdir_tree.each do |subdir|
  #       tree << File.join(File.basename(entry), subdir)
  #     end
  #   end
  #   puts tree
  #   return tree
  # end

  def build_tree(base_directory, tree)
    # Check if the base_directory contains at least one .json file
    if Dir.glob(File.join(base_directory, '*.json')).any?
      # Add the base_directory to the tree
      tree << base_directory
    end
    # Get a list of all entries (files and directories) in the base_directory
    entries = Dir.entries(base_directory)
    # Iterate through the entries
    entries.each do |entry|
      next if entry == '.' || entry == '..'  # Skip "." and ".."
      entry_path = File.join(base_directory, entry)
  
      # Check if the entry is a directory
      if File.directory?(entry_path)
        # Recursively call the method for subdirectories
        build_tree(entry_path, tree)
      end
    end
  end

  def build_jsons(base_directory, json_files)
    # Get a list of all entries (files and directories) in the base_directory
    entries = Dir.entries(base_directory)
    # Iterate through the entries
    entries.each do |entry|
      next if entry == '.' || entry == '..'  # Skip "." and ".."
      entry_path = File.join(base_directory, entry)
  
      # Check if the entry is a directory
      if File.directory?(entry_path)
        # Recursively call the method for subdirectories
        build_jsons(entry_path, json_files)
      elsif entry.end_with?('.json')
        # If the entry is a .json file, add it to the json_files array
        json_files << entry_path
      end
    end
  end
  
  def navigationSystem(base_name, messagechoice)
    directory_name = base_name
    # directory_name = "ExportedPokemons"  # Replace with the actual path to your folder
    checkDirectory(directory_name)
    cancelled = false
    havingjsons = []
    randomized = false
    #subdirectory support
    # Use Dir.glob to get a list of directories in the folder
    directories = Dir.glob(File.join(directory_name, "*")).select { |entry| File.directory?(entry) }
    # Extract just the directory names without the full path
    directory_names = directories.map { |entry| File.basename(entry) }
    # recursed_dir = []
    # build_tree(directory_name, recursed_dir)

    while true
      # recursed_json = []
      # build_jsons(directory_name, recursed_json)
      # havingjsons = recursed_json
      # puts havingjsons
      dir_cmd = 0
      director_actions = directory_names.clone
      director_actions.unshift("<Random Sub-Folder>")#2 or 3 // (was 1 or 2)
      director_actions.unshift("<This Folder+Sub-Folders>")#1 or 2
      director_actions.unshift("<This Folder>")#0 or 1
      director_actions.unshift("<...>") if directory_name != base_name#0
      cancelcmd = director_actions.length
      director_actions.push("<Cancel>") # always last
      #prompt to choose a directory
      # pbDisplay(_INTL(directory_name))
      dir_cmd = pbShowCommands(_INTL(messagechoice), director_actions, dir_cmd)
      if (dir_cmd == 0 && directory_name == base_name) || (dir_cmd == 1 && directory_name != base_name)
        # this folder (SELECTING <THIS FOLDER>)
        break
      elsif dir_cmd == 0 && directory_name != base_name
        # move up (SELECTING <...>)
        directory_name = directory_name.sub(/[^\/]+$/, '').chop
        directories = Dir.glob(File.join(directory_name, "*")).select { |entry| File.directory?(entry) }
        directory_names = directories.map { |entry| File.basename(entry) }
      elsif (dir_cmd == 1 && directory_name == base_name) || (dir_cmd == 2 && directory_name != base_name)
        # json gather (SELECTING <THIS FOLDER+SUB-FOLDERS>)
        recursed_json = []
        build_jsons(directory_name, recursed_json)
        havingjsons = recursed_json
        directory_name = "[Every .jsons]"
        break
      elsif (dir_cmd == 2 && directory_name == base_name) || (dir_cmd == 3 && directory_name != base_name)
        # randomize (SELECTING <RANDOM SUB-FOLDER>)
        if directory_names.empty?
          pbPlayBuzzerSE
          pbDisplay(_INTL("No sub-folders to randomize from!"))
        else
          recursed_dir = []
          directory_names = directory_name
          build_tree(directory_name, recursed_dir)
          directory_name = recursed_dir.sample.to_s
          # directory_name = directory_name.to_s + "/" + directory_names.sample.to_s
          randomized = true
          break
        end
      elsif (dir_cmd == cancelcmd)
        # (SELECTING <CANCEL>)
        cancelled = true
        break
      elsif dir_cmd > 2#cannot be below anyway
        # choosing a folder (SELECTING A FOLDER)
        directory_name = directory_name.to_s + "/" + director_actions[dir_cmd].to_s
        directories = Dir.glob(File.join(directory_name, "*")).select { |entry| File.directory?(entry) }
        directory_names = directories.map { |entry| File.basename(entry) }
      else
        cancelled = true
        break
      end
    end
    return directory_name, directory_names, cancelled, randomized, havingjsons
  end

  def pbBattleSelected(box, frommulti=true, defaultteam=nil, enemydirsupp=nil, playerdirsupp=nil)
    playerteamok = true
    tempclone = ""
    alreadycloned = false
    clone = true
    #init player randomizer if necessary
    playerfolder = false
    if $PokemonSystem.sb_playerfolder
      if $PokemonSystem.sb_playerfolder == 1
        playerfolder = true
      end
    end
    randteam = 0
    if $PokemonSystem.sb_randomizeteam
      randteam = $PokemonSystem.sb_randomizeteam
    end
    if randteam == 0
      randteam = false
    else
      randteam = true
    end
    playernum = 1
    if $PokemonSystem.sb_randomizesize
      playernum = $PokemonSystem.sb_randomizesize+1
    end
    # if $PokemonSystem.sb_soullinked
    #   if $PokemonSystem.sb_soullinked == 1
    #     clone = false
    #   end
    # end
    buildparty = []
    buildobject = []
    if frommulti
      if playerfolder && randteam
        krplayer = []
        # we randomize the player team

        directory_name, directory_array, cancelled, randomized, havingjsons = navigationSystem("ExportedPokemons", "Choose Player Sub-Directory.")
        if cancelled
          battlebr(defaultteam)
          return
        end
        if havingjsons.length < 1
          # Use Dir.glob to get a list of JSON files in the folder
          json_files = Dir.glob(File.join(directory_name, "*.json"))
          if json_files.empty?
            pbPlayBuzzerSE
            pbDisplay(_INTL("No Players Battler to Import!"))
            battlebr(defaultteam)
            return
          end
        else
          json_files = havingjsons.clone
        end
        pokekuraysplayer = json_files
        if pokekuraysplayer.empty?
          pbDisplay(_INTL("No Player Team for Fighting! Using current team instead."))
          playerfolder = false
        end
        if playerfolder
          playerteamok = false
        end
        if playerfolder && randteam || playernum != $Trainer.party.length
          defaultteam = $Trainer.party.clone
          alreadycloned = true
        end
        if playerfolder && randteam
          if pokekuraysplayer.length < playernum
              playernum = pokekuraysplayer.length
              pbDisplay(_INTL("Battling with only {1} Pokemon(s) (Player)", playernum))
          end
          playernum.times do
            # Choose a random JSON file from the list
            randomkuray = pokekuraysplayer.sample
            pokemon = Pokemon.new(:BULBASAUR, 1)
            json_data = File.read(randomkuray)
            pokemon.load_json(eval(json_data), randomkuray, true)
            playerteamok = true if !pokemon.egg?
            krplayer.push(pokemon)
            # Remove the chosen file from the list
            pokekuraysplayer.delete(randomkuray)
          end
          # $Trainer.party = krplayer.clone
          # finaleparty = $Trainer.party.clone
          # for i in 0...finaleparty.length
          #   # player level setup
          #   $Trainer.party[i] = finaleparty[i].clone
          #   if $PokemonSystem.sb_level
          #     if $PokemonSystem.sb_level == 1
          #       $Trainer.party[i].level = 1
          #     elsif $PokemonSystem.sb_level == 2
          #       $Trainer.party[i].level = 5
          #     elsif $PokemonSystem.sb_level == 3
          #       $Trainer.party[i].level = 10
          #     elsif $PokemonSystem.sb_level == 4
          #       $Trainer.party[i].level = 50
          #     elsif $PokemonSystem.sb_level == 5
          #       $Trainer.party[i].level = 70
          #     elsif $PokemonSystem.sb_level == 6
          #       $Trainer.party[i].level = 100
          #     end
          #   end
          # end
        end
      end

      if !playerteamok
        pbPlayBuzzerSE
        pbDisplay(_INTL("One of the team is empty!"))
        battlebr(defaultteam)
        return
      end
      selected = getMultiSelection(box, nil)
      if selected.length == 0 || selected.length > 6
        battlebr(defaultteam)
        return
      end
      unless alreadycloned
        defaultteam = $Trainer.party.clone
      end
    else
      selected = box
    end
    for index in selected
      if frommulti#we take from multi select, creating the array and working another way
        next unless @storage[box, index]
        tmppkm = @storage[box, index].clone
        tempclone = tmppkm.to_json
        pokemon = Pokemon.new(:BULBASAUR, 1)
        pokemon.load_json(tempclone)
        # if clone
        #   tmppkm = @storage[box, index].clone
        #   tempclone = tmppkm.to_json
        #   pokemon = Pokemon.new(:BULBASAUR, 1)
        #   pokemon.load_json(tempclone)
        # else
        #   pokemon = @storage[box, index]
        # end
      else#we already have an array in this variable!
        next unless index
        tmppkm = index.clone
        # puts tmppkm.species
        # puts tmppkm.species_data
        tempclone = tmppkm.to_json
        pokemon = Pokemon.new(:BULBASAUR, 1)
        pokemon.load_json(tempclone)
        # if clone
        #   tmppkm = index.clone
        #   tempclone = tmppkm.to_json
        #   pokemon = Pokemon.new(:BULBASAUR, 1)
        #   pokemon.load_json(tempclone)
        # else
        #   pokemon = index
        # end
      end
      if pokemon
        # finalpokemon = pokemon.clone
        # enemy level setup
        if $PokemonSystem.sb_level
          if $PokemonSystem.sb_level == 1
            pokemon.level = 1
          elsif $PokemonSystem.sb_level == 2
            pokemon.level = 5
          elsif $PokemonSystem.sb_level == 3
            pokemon.level = 10
          elsif $PokemonSystem.sb_level == 4
            pokemon.level = 50
          elsif $PokemonSystem.sb_level == 5
            pokemon.level = 70
          elsif $PokemonSystem.sb_level == 6
            pokemon.level = 100
          end
        end
        pkmn_data = {
          species: pokemon.species,
          level: pokemon.level,
          moves: pokemon.moves.map { |m| m.id },
          iv: pokemon.iv,
          ev: pokemon.ev,
		  ability: pokemon.ability,
		  ability_index: pokemon.ability_index,
        }
	  # puts "Captured Ability: #{pokemon.ability}"  # Debug line
      buildparty.push(pkmn_data)
      buildobject.push(pokemon)
      end
    end
    if buildparty.length == 0  # Ensure there's at least one Pokémon to battle
      battlebr(defaultteam)
      return
    end
    if frommulti
      if playerfolder && randteam
        $Trainer.party = krplayer.clone
      end
      finaleparty = $Trainer.party.clone
      for i in 0...finaleparty.length
        # player level setup
        $Trainer.party[i] = finaleparty[i].clone
        # if i >= playernum
          # break
        # end
        if $PokemonSystem.sb_level
          if $PokemonSystem.sb_level == 1
            $Trainer.party[i].level = 1
          elsif $PokemonSystem.sb_level == 2
            $Trainer.party[i].level = 5
          elsif $PokemonSystem.sb_level == 3
            $Trainer.party[i].level = 10
          elsif $PokemonSystem.sb_level == 4
            $Trainer.party[i].level = 50
          elsif $PokemonSystem.sb_level == 5
            $Trainer.party[i].level = 70
          elsif $PokemonSystem.sb_level == 6
            $Trainer.party[i].level = 100
          end
        end
      end
    end
    $Trainer.heal_party # healing player
    # choicelimit = buildparty.length
    choicelimit = 1
    if $PokemonSystem.sb_randomizesize
      choicelimit = $PokemonSystem.sb_randomizesize+1
    end
    if $PokemonSystem.sb_maxing
      if $PokemonSystem.sb_maxing == 1
        choicelimit = 6
      end
    end
    continuingbattle = false
    selectpkmn = false
    if $PokemonSystem.sb_select
      if $PokemonSystem.sb_select == 1
        selectpkmn = true
      end
    end
    if selectpkmn
      if PokemonSelection.choose(1,choicelimit,true,true)
        continuingbattle = true
      end
    else
      continuingbattle = true
    end
    unless continuingbattle
      battlebr(defaultteam)
      return
    end
    possibletrainers = [0, 1, 2, 3] # put IDs of trainer sprites to use here :3
    ktrainertype = possibletrainers.sample
    # Create a trainer with the selected Pokémon as their party
    trainer_data = createTrainer(ktrainertype, $Trainer.name, buildparty)
    if !trainer_data  # Ensure the trainer was successfully created
      battlebr(defaultteam)
      return
    end

    # Battle against the created trainer
    trainer = init_trainer(trainer_data[0])

    trainer.pokemon.each_with_index do |pkmn, i|
      pkmn = buildobject[i]   # Turns a pokemon of this party index into the pokemon of the player's party of the same index   
      pkmn.heal#healing enemy
      pkmn.calc_stats
    end

    result = customTrainerBattle(trainer.name, trainer.trainer_type, buildobject, "...", nil)
    # Set the result
    pbSet(1, result == 1 ? 0 : 1)
    $PokemonSystem.nomoneylost = 0
    PokemonSelection.restore()
    battlebr(defaultteam)
    $PokemonSystem.sb_loopbreaker = 0
    if $PokemonSystem.sb_loopinput
      if $PokemonSystem.sb_loopinput == 0
        $PokemonSystem.sb_loopbreaker = 1
      end
        # Trapstarr - Track the result if wintracker is on
      if $PokemonSystem.sb_stat_tracker != nil && $PokemonSystem.sb_stat_tracker == 1
        if result == 1
          $PokemonSystem.player_wins += 1
        elsif result == 2
          $PokemonSystem.enemy_wins += 1
        end
        if enemydirsupp && playerdirsupp
          enemydirsupp = enemydirsupp.sub(/^ExportedPokemons\//, '')
          playerdirsupp = playerdirsupp.sub(/^ExportedPokemons\//, '')
          File.open("ExportedPokemons/Data.csv", 'a') { |f| f.write(playerdirsupp + "," + enemydirsupp + "," + result.to_s + "\n") }
        end
        if $PokemonSystem.sb_loopbreaker == 1
          $PokemonSystem.player_wins = 0
          $PokemonSystem.enemy_wins = 0
        end
	    end
  	end
    return
  end

  #KurayX
  def pbExportSelected(box, frombox=false)
    directory_name = "ExportedPokemons"
    checkDirectory(directory_name)
    unless frombox
      selected = getMultiSelection(box, nil)
    end
    return if selected.length == 0
    for index in selected
      if frombox
        next unless index
        pokemon = index
      else
        next unless @storage[box, index]
        pokemon = @storage[box, index]
      end
      addincra = 0
      cleaned_name = pokemon.name.gsub(/[^a-zA-Z0-9]/, '_')
      importname = directory_name + "/" + pokemon.speciesName + "-" + cleaned_name + "-" + pokemon.personalID.to_s + "-" + pokemon.gender.to_s + "-" + pokemon.level.to_s
      classyname = importname
      while File.file?(importname + ".json") || File.file?(importname + ".png")
        importname = classyname + "(" + addincra.to_s + ")"
        addincra += 1
        if addincra > 9999
          break
        end
      end
      File.open(importname + ".json", 'w') { |f| f.write(pokemon.to_json) }
      logic_png(pokemon, importname)
    end
    pbDisplay(_INTL("Pokemon(s) Exported!"))
  end

  def pbReleaseMulti(box)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    ableCount = 0
    finalReleased = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      if pokemon.owner.name  == "RENTAL"
        pbDisplay(_INTL("This Pokémon cannot be released"))
        return
      elsif pokemon.egg?
        pbDisplay(_INTL("You can't release an Egg."))
        return false
      elsif pokemon.mail
        pbDisplay(_INTL("Please remove the mail."))
        return false
      end
      ableCount += 1 if pbAble?(pokemon)
      finalReleased.push(index)
    end
    if box == -1 && pbAbleCount == ableCount
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release {1} Pokémon?", finalReleased.length), [_INTL("No"), _INTL("Yes")])
    if command == 1
      @multiSelectRange = nil
      @scene.pbUpdateSelectionRect(0, 0)
      @scene.pbReleaseMulti(box, finalReleased)
      @storage.pbDeleteMulti(box, finalReleased)
      @scene.pbRefresh
      pbDisplay(_INTL("The Pokémon were released."))
      pbDisplay(_INTL("Bye-bye!"))
      @scene.pbRefresh
    end
    return
  end

  def logic_png(pokemon, importname)
    @scene.logic_png(pokemon, importname)
  end

  def pbChooseMove(pkmn, helptext, index = 0)
    movenames = []
    for i in pkmn.moves
      if i.total_pp <= 0
        movenames.push(_INTL("{1} (PP: ---)", i.name))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
      end
    end
    return @scene.pbShowCommands(helptext, movenames, index)
  end

  #KurayX
  def pbImportJson(selected, heldpoke)
    @scene.pbImportJson(selected, heldpoke)
  end

  #KurayX
  def pbToggleShiny(selected, heldpoke)
    @scene.pbToggleShiny(selected, heldpoke)
  end

  #KurayX
  def pbCarpFill(selected, heldpoke)
    @scene.pbCarpFill(selected, heldpoke)
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbRerollShiny(selected, heldpoke)
    @scene.pbRerollShiny(selected, heldpoke)
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbDefineShinycolor(selected, heldpoke)
    @scene.pbDefineShinycolor(selected, heldpoke)
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbKurayAct(selected, heldpoke)
    @scene.pbKurayAct(selected, heldpoke)
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbKuraShinify(selected, heldpoke)
    @scene.pbKuraShinify(selected, heldpoke)
  end

  #KurayX
  def pbKurayNoEvo(selected, heldpoke)
    @scene.pbKurayNoEvo(selected, heldpoke)
  end

  #KurayX
  def pbExport(selected, heldpoke, dodelete=0)
    @scene.pbExport(selected, heldpoke, dodelete)
  end

  #KurayX
  def pbExportBox(box)
    @scene.pbExportBox(box)
  end

  #KurayX
  def pbExportAll()
    @scene.pbExportAll()
  end

  def pbSummary(selected, heldpoke)
    @scene.pbSummary(selected, heldpoke)
  end

  def pbMark(selected, heldpoke)
    @scene.pbMark(selected, heldpoke)
  end

  def pbItem(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box, index]
    if pokemon.egg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if pokemon.item
      itemname = pokemon.item.name
      if pbConfirm(_INTL("Take this {1}?", itemname))
        if !$PokemonBag.pbStoreItem(pokemon.item)
          pbDisplay(_INTL("Can't store the {1}.", itemname))
        else
          pbDisplay(_INTL("Took the {1}.", itemname))
          pokemon.item = nil
          @scene.pbHardRefresh
        end
      end
    else
      item = scene.pbChooseItem($PokemonBag)
      if item
        itemname = GameData::Item.get(item).name
        pokemon.item = item
        $PokemonBag.pbDeleteItem(item)
        pbDisplay(_INTL("{1} is now being held.", itemname))
        @scene.pbHardRefresh
      end
    end
  end

  def sort_box(box, kurayid, attribute, sortingkuray, all_sorting)
    for k in 0..29
      if pokekuray = box[k]
        case attribute
        when :shiny
          shinykur = pokekuray.shiny? ? 1 : 0
          sortingkuray.append([shinykur, kurayid])
        when :OT
          otname = pokekuray.owner.name.empty? ? "0" : pokekuray.owner.name
          sortingkuray.append([otname, kurayid])
        when :gender
          actualgender = pokekuray.pizza? ? 3 : pokekuray.gender
          sortingkuray.append([actualgender, kurayid])
        when :ability
          sortingkuray.append([pokekuray.ability.name, kurayid])
        when :nature
          sortingkuray.append([pokekuray.nature.name, kurayid])
        when :item
          sortingkuray.append([pokekuray.item ? pokekuray.item.name : "0", kurayid])
        when :type1
          kuraytype = GameData::Type.get(pokekuray.type1).id_number
          sortingkuray.append([kuraytype, kurayid])
        when :type2
          kuraytype = GameData::Type.get(pokekuray.type2).id_number
          sortingkuray.append([kuraytype, kurayid])
        when :totalivs
          sumivs = pokekuray.iv[:HP] + pokekuray.iv[:ATTACK] + pokekuray.iv[:DEFENSE] + pokekuray.iv[:SPECIAL_ATTACK] + pokekuray.iv[:SPECIAL_DEFENSE] + pokekuray.iv[:SPEED]
          sortingkuray.append([sumivs, kurayid])
        when :totalevs
          sumevs = pokekuray.ev[:HP] + pokekuray.ev[:ATTACK] + pokekuray.ev[:DEFENSE] + pokekuray.ev[:SPECIAL_ATTACK] + pokekuray.ev[:SPECIAL_DEFENSE] + pokekuray.ev[:SPEED]
          sortingkuray.append([sumevs, kurayid])
        else
          sortingkuray.append([pokekuray.send(attribute), kurayid])
        end
      end
      if all_sorting && pokekuray
        kurayid += 1
      elsif !all_sorting
        kurayid += 1
      end
    end
    kurayid
  end
  
  def sort_boxes(attribute, all_sorting=false, sortingkuray)
    kurayid = 0
    if all_sorting
      for j in 0...@storage.maxBoxes
        next if @storage[j].empty?
        next if @storage[j].sortlock?
        kurayid = sort_box(@storage[j], kurayid, attribute, sortingkuray, all_sorting)
      end
    else
      kurayid = sort_box(@storage[@storage.currentBox], kurayid, attribute, sortingkuray, all_sorting)
    end
  end

  def pre_sort_boxes(all_sorting=false)
    kuraychoices = [
      _INTL("Sort by Name"),
      _INTL("Sort by Nickname"),
      _INTL("Sort by Dex Number"),
      _INTL("Sort by Level"),
      _INTL("Sort by HP"),
      _INTL("Sort by Atk"),
      _INTL("Sort by Def"),
      _INTL("Sort by SpA"),
      _INTL("Sort by SpD"),
      _INTL("Sort by Spe"),
      _INTL("Sort by Caught Date"),
      _INTL("Sort by Shiny"),
      _INTL("Sort by OT"),
      _INTL("Sort by Gender"),
      _INTL("Sort by Ability"),
      _INTL("Sort by Nature"),
      _INTL("Sort by Held Item"),
      _INTL("Sort by 1st Type"),
      _INTL("Sort by 2nd Type"),
      _INTL("Sort by Caught Map"),
      _INTL("Sort by Happiness"),
      _INTL("Sort by EXP"),
      _INTL("Sort by Markings"),
      _INTL("Sort by Total IVs"),
      _INTL("Sort by Total EVs"),
      _INTL("Nevermind"),
    ]
    kuraychoice = pbShowCommands(
      _INTL("Sort box how ?"), kuraychoices)
    sortingkuray = []
    case kuraychoice
    when 0 # by name
      sort_boxes(:speciesName, all_sorting, sortingkuray)
    when 1 # by nickname
      sort_boxes(:name, all_sorting, sortingkuray)
    when 2 # by dexnum
      sort_boxes(:dexNum, all_sorting, sortingkuray)
    when 3 # by level
      sort_boxes(:level, all_sorting, sortingkuray)
    when 4 # by HP
      sort_boxes(:totalhp, all_sorting, sortingkuray)
    when 5 # by atk
      sort_boxes(:attack, all_sorting, sortingkuray)
    when 6 # by def
      sort_boxes(:defense, all_sorting, sortingkuray)
    when 7 # by spA
      sort_boxes(:spatk, all_sorting, sortingkuray)
    when 8 # by spD
      sort_boxes(:spdef, all_sorting, sortingkuray)
    when 9 # by spe
      sort_boxes(:speed, all_sorting, sortingkuray)
    when 10 # by received
      sort_boxes(:timeReceived, all_sorting, sortingkuray)
    when 11 # by shiny
      sort_boxes(:shiny, all_sorting, sortingkuray)
    when 12 # by OT
      sort_boxes(:OT, all_sorting, sortingkuray)
    when 13 # by gender
      sort_boxes(:gender, all_sorting, sortingkuray)
    when 14 # by ability
      sort_boxes(:ability, all_sorting, sortingkuray)
    when 15 # by nature
      sort_boxes(:nature, all_sorting, sortingkuray)
    when 16 # by item
      sort_boxes(:item, all_sorting, sortingkuray)
    when 17 # by first type
      sort_boxes(:type1, all_sorting, sortingkuray)
    when 18 # by last type
      sort_boxes(:type2, all_sorting, sortingkuray)
    when 19 # by obtain map
      sort_boxes(:obtain_map, all_sorting, sortingkuray)
    when 20 # by happiness
      sort_boxes(:happiness, all_sorting, sortingkuray)
    when 21 # by exp
      sort_boxes(:exp, all_sorting, sortingkuray)
    when 22 # by markings
      sort_boxes(:markings, all_sorting, sortingkuray)
    when 23 # by IVS
      sort_boxes(:totalivs, all_sorting, sortingkuray)
    when 24 # by EVS
      sort_boxes(:totalevs, all_sorting, sortingkuray)
    end

    if !sortingkuray.empty?
      sorted = 0
      kuraychoices = [
          _INTL("Normal Order"),
          _INTL("Reverse Order"),
          _INTL("Nevermind"),
        ]
      kuraychoice = pbShowCommands(
        _INTL("Sort box how ?"), kuraychoices)
      case kuraychoice
      when 0 # by normal
        # sortingkuray.sort!
        sortingkuray = sortingkuray.sort_by { |h| h[0]}
        sorted = 1
      when 1 # by reverse
        sortingkuray = sortingkuray.sort_by { |h| h[0]}
        sortingkuray = sortingkuray.reverse
        sorted = 1
      end
      if sorted == 1
        copytmp = []
        if all_sorting
          for j in 0...@storage.maxBoxes
            next if @storage[j].sortlock?
            for k in 0..29
              copytmp.push(*@storage[j, k])
              @storage[j, k] = nil
            end
          end
          boxhere = 0
          while @storage[boxhere].sortlock?
            boxhere += 1
          end
          boxcheck = -1
        else
          for k in 0..29
            copytmp.push(@storage[@storage.currentBox, k])
            @storage[@storage.currentBox, k] = nil
          end
        end
        for k in 0..sortingkuray.size-1
          dealwith = sortingkuray[k, 1].flatten
          if all_sorting
            if boxcheck > 28
              boxhere += 1
              boxcheck = -1
              while @storage[boxhere].sortlock?
                boxhere += 1
              end
            end
            boxcheck += 1
            @storage[boxhere, boxcheck] = copytmp[dealwith[1].to_i]
          else
            @storage[@storage.currentBox, k] = copytmp[dealwith[1].to_i]
          end
        end
        # puts "copytmp: #{copytmp.inspect}"
        # puts "sortingkuray: #{sortingkuray.inspect}"
        # puts "dealwith: #{dealwith.inspect}"
        pbHardRefresh
        # pbUpdateOverlay(@selection)
        # @scene.pbRefresh
        # pbRefresh
        pbDisplay(_INTL("Pokemons sorted!"))
      end
    end
  end

  #KurayBoxesS
  def pbBoxCommands
    commands = [
      _INTL("Jump"),
      _INTL("Wallpaper"),
      _INTL("Name")
    ]
    if @storage[@storage.currentBox].sortlock?
      tmp_txt = "Unlock Sorting"
    else
      tmp_txt = "Lock Sorting"
    end
    if @storage[@storage.currentBox].exportlock?
      tmp_txt2 = "Unlock Exporting"
    else
      tmp_txt2 = "Lock Exporting"
    end
    commands[commands.length] = _INTL(tmp_txt)#Allows to exempt a box from sorting
    commands[commands.length] = _INTL(tmp_txt2)#Allows to exempt a box from exporting
    additional_commands = [
      _INTL("Buy Box"),
      # _INTL("Export All"),
      # _INTL("Import"),
      # _INTL("Import Randomly"),
      _INTL("Sort"),
      _INTL("Sort (all Boxes)"),
      _INTL("Battle"),
      # _INTL("Cancel"),
    ]
    commands += additional_commands
    canExportImport = true
    if $PokemonSystem.debugfeature
      if $PokemonSystem.debugfeature == 1
        canExportImport = false
      end
    end
    if $DEBUG || canExportImport
      commands[commands.length] = _INTL("Export this Box")
      commands[commands.length] = _INTL("Export All")
      commands[commands.length] = _INTL("Import")
      commands[commands.length] = _INTL("Import Randomly")
    end
    commands[commands.length] = _INTL("Cancel")
    command = pbShowCommands(
      _INTL("What do you want to do?"), commands)
    case command
    when 0
      destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
      if destbox >= 0
        @scene.pbJumpToBox(destbox)
      end
    when 1
      papers = @storage.availableWallpapers
      index = 0
      for i in 0...papers[1].length
        if papers[1][i] == @storage[@storage.currentBox].background
          index = i; break
        end
      end
      wpaper = pbShowCommands(_INTL("Pick the wallpaper."), papers[0], index)
      if wpaper >= 0
        @scene.pbChangeBackground(papers[1][wpaper])
      end
    when 2#name
      @scene.pbBoxName(_INTL("Box name?"), 0, 12)
    when 3#sort lock
      @scene.pbToggleSortBox()
    when 4#export lock
      @scene.pbToggleExportBox()
    when 5
      pricenow = @storage.maxBoxes * 300
      if pricenow > 100000
        pricenow = 100000
      end
      pricenow = 0 if $PokemonSystem.kuraystreamerdream != 0
      if $Trainer.money < pricenow
        pbPlayBuzzerSE
        pbDisplay(_INTL("Not enough Money ! Cost P" + pricenow.to_s))
      else
        kuraychoices = [
          _INTL("Buy! (P" + pricenow.to_s + ")"),
          _INTL("Nevermind"),
        ]
        kuraychoice = pbShowCommands(
          _INTL("You have P" + $Trainer.money.to_s_formatted), kuraychoices)
        case kuraychoice
        when 0
          $Trainer.money -= pricenow
          @storage.boxes[@storage.boxes.length] = PokemonBox.new(_INTL("Box {1}",@storage.boxes.length+1),PokemonBox::BOX_SIZE)
          # @boxnumber += 1
          pbDisplay(_INTL("Bought a new box!"))
        end
      end
    when 6
      #Sort Pokemons
      # box = selected[0]
      # index = selected[1]
      # if @storage[box, index]
      pre_sort_boxes()
    when 7
      #Sort Pokemons
      # box = selected[0]
      # index = selected[1]
      # if @storage[box, index]
      pre_sort_boxes(true)
    when 8
      #battle
      battlerchoice = 1
      if $PokemonSystem.sb_battlesize
        battlerchoice = $PokemonSystem.sb_battlesize+1
      end
      playernum = 1
      if $PokemonSystem.sb_randomizesize
        playernum = $PokemonSystem.sb_randomizesize+1
      end
      # randomize team?
      randteam = 0
      if $PokemonSystem.sb_randomizeteam
        randteam = $PokemonSystem.sb_randomizeteam
      end
      if randteam == 0
        randteam = false
      else
        randteam = true
      end
      battleshare = false
      if $PokemonSystem.sb_randomizeshare
        if $PokemonSystem.sb_randomizeshare == 1
          battleshare = true
        end
      end

      playerfolder = false
      if $PokemonSystem.sb_playerfolder
        if $PokemonSystem.sb_playerfolder == 1
          playerfolder = true
        end
      end

      isjson = false

      if battlerchoice < 7
        #battler logic
        kuraychoices = [
          _INTL("Battle Randomly this Box"),
          _INTL("Battle Randomly this Box + Team"),
          _INTL("Battle Randomly entire Storage"),
          _INTL("Battle Randomly entire Storage + Team"),
          _INTL("Battle from ExportedPokemons"),
          _INTL("Nevermind"),
        ]
        kuraychoice = pbShowCommands(
          _INTL("Battle system"), kuraychoices)

        # battlertimes = battlerchoice
        krbattlers = []
        krplayer = []
        defaultteam = $Trainer.party.clone
        pokekurays = []
        case kuraychoice
        when 0 # box - IMPORT THE CURRENT BOX
          for k in 0..29
            if @storage[@storage.currentBox, k]
              pokekuray = @storage[@storage.currentBox, k]
              pokekurays.append(pokekuray) if !pokekuray.egg?
            end
          end
        when 1 # box + team - IMPORT THE CURRENT BOX + THE TEAM
          for j in 0..5
            if @storage.party[j]
              pokekuray = @storage.party[j]
              pokekurays.append(pokekuray) if !pokekuray.egg?
            end
          end
          for k in 0..29
            if @storage[@storage.currentBox, k]
              pokekuray = @storage[@storage.currentBox, k]
              pokekurays.append(pokekuray) if !pokekuray.egg?
            end
          end
        when 2 # storage
          for j in 0...@storage.maxBoxes
            if @storage[j].empty?
              next
            end
            for k in 0..29
              if @storage[j, k]
                pokekuray = @storage[j, k]
                pokekurays.append(pokekuray) if !pokekuray.egg?
              end
            end
          end
        when 3 # storage + team
          for j in 0..5
            if @storage.party[j]
              pokekuray = @storage.party[j]
              pokekurays.append(pokekuray) if !pokekuray.egg?
            end
          end
          for j in 0...@storage.maxBoxes
            if @storage[j].empty?
              next
            end
            for k in 0..29
              if @storage[j, k]
                pokekuray = @storage[j, k]
                pokekurays.append(pokekuray) if !pokekuray.egg?
              end
            end
          end
        when 4 # battler folder
          directoryplayer_name = nil
          directorybattler_name = nil
          directorybattler_name, directorybattler_array, cancelled, battler_randomized, havingjsons = navigationSystem("ExportedPokemons", "Choose Battler Sub-Directory.")
          if cancelled
            return
          end

          if havingjsons.length < 1
            # Use Dir.glob to get a list of JSON files in the folder
            json_files = Dir.glob(File.join(directorybattler_name, "*.json"))
            if json_files.empty?
              pbPlayBuzzerSE
              pbDisplay(_INTL("No Enemies Battler to Import!"))
              return
            end
          else
            json_files = havingjsons.clone
          end
          pokekurays = json_files
          isjson = true
        when 5 # cancel
          return
        end
        firsttime = true
        defaultenemy = pokekurays.clone
        while true
          if $PokemonSystem.sb_loopbreaker
            if $PokemonSystem.sb_loopbreaker == 1
              $PokemonSystem.sb_loopbreaker = 0
              break
            end
          end
          enemyteamok = true
          playerteamok = true
          if isjson
            playerteamok = false
            enemyteamok = false
          end
          unless firsttime
            # not first time!
            pokekurays = defaultenemy.clone
            krbattlers = []
            krplayer = []
            if battler_randomized
              # directorybattler_name = directorybattler_name.sub(/[^\/]+$/, '').chop
              recursed_dir = []
              build_tree(directorybattler_array, recursed_dir)
              directorybattler_name = recursed_dir.sample.to_s
              # directorybattler_name = directorybattler_name.to_s + "/" + directorybattler_array.sample.to_s
              enemyjson = Dir.glob(File.join(directorybattler_name, "*.json"))
              maxtries = 50
              gaveup = false
              while enemyjson.empty?
                pbPlayBuzzerSE
                # re-randomize until match
                # directorybattler_name = directorybattler_name.sub(/[^\/]+$/, '').chop
                recursed_dir = []
                build_tree(directorybattler_array, recursed_dir)
                directorybattler_name = recursed_dir.sample.to_s
                # directorybattler_name = directorybattler_name.to_s + "/" + directorybattler_array.sample.to_s
                enemyjson = Dir.glob(File.join(directorybattler_name, "*.json"))
                maxtries -= 1
                if maxtries == 0
                  gaveup = true
                  pbDisplay(_INTL("Gave up after 50 tries on Battler folder!"))
                  break
                end
              end
              if gaveup
                return
              end
              pokekurays = enemyjson
            end
          end
          if playerfolder
            if firsttime
              directoryplayer_name, directoryplayer_array, cancelled, player_randomized, havingjsons = navigationSystem("ExportedPokemons", "Choose Player Sub-Directory.")
              if !battleshare && player_randomized && (directoryplayer_name == directorybattler_name)
                # directoryplayer_name = directoryplayer_name.sub(/[^\/]+$/, '').chop
                recursed_dir = []
                build_tree(directoryplayer_array, recursed_dir)
                recursed_dir.delete(directorybattler_name) unless recursed_dir.length <= 1
                directoryplayer_name = recursed_dir.sample.to_s
              end
              if cancelled
                return
              end
              if havingjsons.length < 1
                # Use Dir.glob to get a list of JSON files in the folder
                json_files = Dir.glob(File.join(directoryplayer_name, "*.json"))
                if json_files.empty?
                  pbPlayBuzzerSE
                  pbDisplay(_INTL("No Players Battler to Import! Using Battlers instead."))
                  pokekuraysplayer = pokekurays.clone
                  playerfolder = false
                else
                  pokekuraysplayer = json_files
                  if pokekuraysplayer.empty?
                    pbDisplay(_INTL("No Player Team for Fighting! Using Battler instead."))
                    pokekuraysplayer = pokekurays.clone
                    playerfolder = false
                  end
                end
              else
                pokekuraysplayer = havingjsons.clone
              end
            else
              # we do player and enemy if enemy was randomized
              if player_randomized
                # directoryplayer_name = directoryplayer_name.sub(/[^\/]+$/, '').chop
                recursed_dir = []
                build_tree(directoryplayer_array, recursed_dir)
                unless battleshare
                  recursed_dir.delete(directorybattler_name) unless recursed_dir.length <= 1
                end
                directoryplayer_name = recursed_dir.sample.to_s
                # directoryplayer_name = directoryplayer_name.to_s + "/" + directoryplayer_array.sample.to_s
                playerjson = Dir.glob(File.join(directoryplayer_name, "*.json"))
                maxtries = 50
                gaveup = false
                while playerjson.empty?
                  pbPlayBuzzerSE
                  # re-randomize until match
                  # directoryplayer_name = directoryplayer_name.sub(/[^\/]+$/, '').chop
                  recursed_dir = []
                  build_tree(directoryplayer_array, recursed_dir)
                  unless battleshare
                    recursed_dir.delete(directorybattler_name) unless recursed_dir.length <= 1
                  end
                  directoryplayer_name = recursed_dir.sample.to_s
                  # directoryplayer_name = directoryplayer_name.to_s + "/" + directoryplayer_array.sample.to_s
                  playerjson = Dir.glob(File.join(directoryplayer_name, "*.json"))
                  maxtries -= 1
                  if maxtries == 0
                    gaveup = true
                    pbDisplay(_INTL("Gave up after 50 tries on Player folder!"))
                    break
                  end
                end
                if gaveup
                  return
                end
                pokekuraysplayer = playerjson
              else
                if havingjsons.length < 1
                  # Use Dir.glob to get a list of JSON files in the folder
                  json_files = Dir.glob(File.join(directoryplayer_name, "*.json"))
                  if json_files.empty?
                    pbPlayBuzzerSE
                    pbDisplay(_INTL("No Players Battler to Import! Using Battlers instead."))
                    pokekuraysplayer = pokekurays.clone
                    playerfolder = false
                  else
                    pokekuraysplayer = json_files
                    if pokekuraysplayer.empty?
                      pbDisplay(_INTL("No Player Team for Fighting! Using Battler instead."))
                      pokekuraysplayer = pokekurays.clone
                      playerfolder = false
                    end
                  end
                else
                  pokekuraysplayer = havingjsons.clone
                end
              end
            end
          else
            pokekuraysplayer = pokekurays.clone
          end
          if firsttime
            firsttime = false
          end
          if playerfolder
            playerteamok = false
          end
          if pokekurays.empty?
            pbPlayBuzzerSE
            pbDisplay(_INTL("No Battler to Fight!"))
            break
          else
            if randteam && !battleshare && !playerfolder
              needingval = battlerchoice+playernum
            else
              needingval = battlerchoice
            end
            if randteam && !battleshare && pokekurays.length < 2
              pbPlayBuzzerSE
              pbDisplay(_INTL("No Battler to Fight!"))
              break
            end
            if pokekurays.length < needingval
              if battleshare
                playernum = pokekurays.length
                battlerchoice = pokekurays.length
              else
                playernum = pokekurays.length/2
                battlerchoice = pokekurays.length/2
              end
                pbDisplay(_INTL("Battling with only {1} Pokemon(s)", battlerchoice))
            end
            if pokekuraysplayer.length < playernum
                playernum = pokekuraysplayer.length
                pbDisplay(_INTL("Battling with only {1} Pokemon(s) (Player)", playernum))
            end
            battlerchoice.times do
              # Choose a random JSON file from the list
              randomkuray = pokekurays.sample
              if isjson
                pokemon = Pokemon.new(:BULBASAUR, 1)
                json_data = File.read(randomkuray)
                pokemon.load_json(eval(json_data), randomkuray, true)
                enemyteamok = true if !pokemon.egg?
                krbattlers.push(pokemon)
              else
                krbattlers.push(randomkuray)
              end
              # Remove the chosen file from the list
              pokekurays.delete(randomkuray)
              unless battleshare || playerfolder
                pokekuraysplayer.delete(randomkuray)
              end
            end
            playernum.times do
              # Choose a random JSON file from the list
              randomkuray = pokekuraysplayer.sample
              if isjson || playerfolder
                pokemon = Pokemon.new(:BULBASAUR, 1)
                json_data = File.read(randomkuray)
                pokemon.load_json(eval(json_data), randomkuray, true)
                playerteamok = true if !pokemon.egg?
                krplayer.push(pokemon)
              else
                krplayer.push(randomkuray)
              end
              # Remove the chosen file from the list
              pokekuraysplayer.delete(randomkuray)
            end
            if !enemyteamok || !playerteamok
              pbPlayBuzzerSE
              pbDisplay(_INTL("One of the team is empty!"))
              break
            end
            if randteam
              $Trainer.party = krplayer.clone
            end
            finaleparty = $Trainer.party.clone
            for i in 0...finaleparty.length
              # player level setup
              $Trainer.party[i] = finaleparty[i].clone
              if $PokemonSystem.sb_level
                if $PokemonSystem.sb_level == 1
                  $Trainer.party[i].level = 1
                elsif $PokemonSystem.sb_level == 2
                  $Trainer.party[i].level = 5
                elsif $PokemonSystem.sb_level == 3
                  $Trainer.party[i].level = 10
                elsif $PokemonSystem.sb_level == 4
                  $Trainer.party[i].level = 50
                elsif $PokemonSystem.sb_level == 5
                  $Trainer.party[i].level = 70
                elsif $PokemonSystem.sb_level == 6
                  $Trainer.party[i].level = 100
                end
              end
            end
            if !directorybattler_name || !directoryplayer_name
              pbBattleSelected(krbattlers, false, defaultteam)
            else
              pbBattleSelected(krbattlers, false, defaultteam, directorybattler_name, directoryplayer_name)
            end
          end
        end
      end
      when 9
      # Export (box)
      if !$DEBUG && !canExportImport
        pbPlayBuzzerSE
        pbDisplay(_INTL("DEBUG needed!"))
      else
        pbExportBox(@storage.currentBox)
      end
    when 10
      #Export (all)
      if !$DEBUG && !canExportImport
        pbPlayBuzzerSE
        pbDisplay(_INTL("DEBUG needed!"))
      else
        pbExportAll()
      end
    when 11
      if !$DEBUG && !canExportImport
        pbPlayBuzzerSE
        pbDisplay(_INTL("DEBUG needed!"))
      else
        #Import (all)
        directory_name, directory_array, cancelled, randomized, havingjsons = navigationSystem("ExportedPokemons", "Choose Import Sub-Directory.")
        if cancelled
          return
        end

        deletejson = true
        if $PokemonSystem.importnodelete
          if $PokemonSystem.importnodelete == 1
            deletejson = false
          end
        end

        if havingjsons.length < 1
          # Use Dir.glob to get a list of JSON files in the folder
          json_files = Dir.glob(File.join(directory_name, "*.json"))
        else
          json_files = havingjsons.clone
        end
        x = @storage.currentBox
        y = 0
        triedcurrent = false
        outofspace = 0
        # x = box, max is @storage.maxBoxes
        # y = space, max is 29
        # Check if there are JSON files
        if json_files.empty?
          pbPlayBuzzerSE
          pbDisplay(_INTL("No Pokemon to Import!"))
        else
          importunevo = false
          importegg = false
          if $PokemonSystem.importegg && $PokemonSystem.importegg == 1
            importegg = true
          end
          importlevel = 0
          if $PokemonSystem.importlvl
            if $PokemonSystem.importlvl == 1
              importlevel = 1
            elsif $PokemonSystem.importlvl == 2
              importlevel = 5
            elsif $PokemonSystem.importlvl == 3
              importlevel = 50
            elsif $PokemonSystem.importlvl == 4
              importlevel = 100
            end
          end
          if $PokemonSystem.importdevolve
            if $PokemonSystem.importdevolve == 1
              importunevo = true
            end
          end
          # Iterate through the JSON files
          json_files.each do |json_file|
            # Load and process the JSON data
            pokemon = Pokemon.new(:BULBASAUR, 1)
            json_data = File.read(json_file)
            pokemon.load_json(eval(json_data), json_file)
            if importunevo
              pokemon.species = GameData::Species.get(pokemon.species).get_baby_species(false)
            end
            if importlevel != 0
              pokemon.level = importlevel
              # pokemon.calc_stats
            end
            if importegg
              pokemon.name           = _INTL("Egg")
              pokemon.steps_to_hatch = pokemon.species_data.hatch_steps
              pokemon.hatched_map    = 0
              pokemon.obtain_method  = 1
            end
            # pokemon.calc_stats
            while @storage[x, y]
              y += 1
              if y > 29
                y = 0
                if x == @storage.currentBox && x != 0 && !triedcurrent
                  x = -1
                  triedcurrent = true
                end
                x += 1
                if x >= @storage.maxBoxes
                  x = 0
                  outofspace = 1
                  break
                end
              end
            end
            unless @storage[x, y]
              if outofspace == 0
                @storage.pbImportKuray(x, y, pokemon)
                File.delete(json_file) if deletejson
              end
            end
            #redo it for the next slot for the next import
            y += 1
            if y > 29
              y = 0
              if x == @storage.currentBox && x != 0 && !triedcurrent
                x = -1
                triedcurrent = true
              end
              x += 1
              if x >= @storage.maxBoxes
                x = 0
                outofspace = 1
                break
              end
            end
            # code to add pokemon here, break if cannot add it
          end
          if outofspace == 1
            pbPlayBuzzerSE
            pbHardRefresh
            # pbUpdateOverlay(@selection)
            pbDisplay(_INTL("Out of place!"))
          else
            pbHardRefresh
            # pbUpdateOverlay(@selection)
            pbDisplay(_INTL("Pokemon(s) Imported!"))
          end
        end
      end
    when 12
      if !$DEBUG && !canExportImport
        pbPlayBuzzerSE
        pbDisplay(_INTL("DEBUG needed!"))
      else
        #Import 1 random
        directory_name, directory_array, cancelled, randomized, havingjsons = navigationSystem("ExportedPokemons", "Choose Import Sub-Directory.")
        if cancelled
          return
        end
        
        deletejson = true
        if $PokemonSystem.importnodelete
          if $PokemonSystem.importnodelete == 1
            deletejson = false
          end
        end
        
        if havingjsons.length < 1
          # Use Dir.glob to get a list of JSON files in the folder
          json_files = Dir.glob(File.join(directory_name, "*.json"))
        else
          json_files = havingjsons.clone
        end

        x = @storage.currentBox
        y = 0
        triedcurrent = false
        outofspace = 0
        # x = box, max is @storage.maxBoxes
        # y = space, max is 29
        # Check if there are JSON files
        if json_files.empty?
          pbPlayBuzzerSE
          pbDisplay(_INTL("No Pokemon to Import!"))
        else
          importunevo = false
          importegg = false
          if $PokemonSystem.importegg && $PokemonSystem.importegg == 1
            importegg = true
          end
          importlevel = 0
          if $PokemonSystem.importlvl
            if $PokemonSystem.importlvl == 1
              importlevel = 1
            elsif $PokemonSystem.importlvl == 2
              importlevel = 5
            elsif $PokemonSystem.importlvl == 3
              importlevel = 50
            elsif $PokemonSystem.importlvl == 4
              importlevel = 100
            end
          end
          if $PokemonSystem.importdevolve
            if $PokemonSystem.importdevolve == 1
              importunevo = true
            end
          end
          # Choose a random JSON file from the list
          random_json_file = json_files.sample
          # Load and process the JSON data
          pokemon = Pokemon.new(:BULBASAUR, 1)
          json_data = File.read(random_json_file)
          pokemon.load_json(eval(json_data), random_json_file)
          if importunevo
            pokemon.species = GameData::Species.get(pokemon.species).get_baby_species(false)
          end
          if importlevel != 0
            pokemon.level = importlevel
            # pokemon.calc_stats
          end
          if importegg
            pokemon.name           = _INTL("Egg")
            pokemon.steps_to_hatch = pokemon.species_data.hatch_steps
            pokemon.hatched_map    = 0
            pokemon.obtain_method  = 1
          end
          # pokemon.calc_stats
          while @storage[x, y]
            y += 1
            if y > 29
              y = 0
              if x == @storage.currentBox && x != 0 && !triedcurrent
                x = -1
                triedcurrent = true
              end
              x += 1
              if x >= @storage.maxBoxes
                x = 0
                outofspace = 1
                break
              end
            end
          end
          unless @storage[x, y]
            if outofspace == 0
              @storage.pbImportKuray(x, y, pokemon)
              File.delete(random_json_file) if deletejson
            end
          end
          if outofspace == 1
            pbPlayBuzzerSE
            pbHardRefresh
            # pbUpdateOverlay(@selection)
            pbDisplay(_INTL("Out of place!"))
          else
            pbHardRefresh
            # pbUpdateOverlay(@selection)
            pbDisplay(_INTL("Pokemon(s) Imported!"))
          end
        end
      end
    # when 6
    #   @storage.deleteboxes
    #   pbDisplay(_INTL("Boxes deleted!"))
    end
  end

  def pbChoosePokemon(_party = nil)
    @heldpkmn = nil
    @scene.pbStartBox(self, 1)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0] == -3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      end
      if selected == nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == -4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        next if !pokemon
        commands = [
          _INTL("Select"),
          _INTL("Summary"),
          _INTL("Withdraw"),
          _INTL("Item"),
          _INTL("Mark")
        ]
        commands.push(_INTL("Cancel"))
        commands[2] = _INTL("Store") if selected[0] == -1
        helptext = _INTL("{1} is selected.", pokemon.name)
        command = pbShowCommands(helptext, commands)
        case command
        when 0 # Select
          if pokemon
            retval = selected
            break
          end
        when 1
          pbSummary(selected, nil)
        when 2 # Store/Withdraw
          if selected[0] == -1
            pbStore(selected, nil)
          else
            pbWithdraw(selected, nil)
          end
        when 3
          pbItem(selected, nil)
        when 4
          pbMark(selected, nil)
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end

  #
  # Fusion stuff
  #

  def pbFuseFromPC(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    poke_body = @storage[box, index]
    poke_head = heldpoke

    if heldpoke
      if dexNum(heldpoke.species) > NB_POKEMON
        pbDisplay(_INTL("{1} is already fused!", heldpoke.name))
        return
      end
      if heldpoke.egg?
        pbDisplay(_INTL("It's impossible to fuse an egg!"))
        return
      end
    end
    if poke_body
      if dexNum(poke_body.species) > NB_POKEMON
        pbDisplay(_INTL("{1} is already fused!", poke_body.name))
        return
      end
      if poke_body.egg?
        pbDisplay(_INTL("It's impossible to fuse an egg!"))
        return
      end
    end

    splicerItem = selectSplicer()
    if splicerItem == nil
      cancelFusion()
      return
    end

    @fusionMode = true
    @fusionItem = splicerItem
    @scene.setFusing(true, @fusionItem)

    if !heldpoke
      pbHold(selected)
      pbDisplay(_INTL("Select a Pokémon to fuse it with"))
      @scene.sprites["box"].disableFusions()
      return
    end
    if !poke_body
      pbDisplay(_INTL("Select a Pokémon to fuse it with"))
      @scene.sprites["box"].disableFusions()
      return
    end

    pbStartFusion(selected)
    return
  end

  def deleteHeldPokemon(heldpoke, selected)
    @scene.pbReleaseInstant(selected, heldpoke)
    @heldpkmn = nil
  end

  def deleteSelectedPokemon(heldpoke, selected)
    pbSwap(selected)
    deleteHeldPokemon(heldpoke, selected)
  end

  def cancelFusion
    @splicerItem = nil
    @scene.setFusing(false)
    @fusionMode = false
    @scene.sprites["box"].enableFusions()
  end

  def canDeleteItem(item)
    return item == :SUPERSPLICERS || item == :DNASPLICERS
  end

  def isSuperSplicer?(item)
    return item == :SUPERSPLICERS || item == :INFINITESPLICERS2
  end

  def pbFusionCommands(selected)
    heldpoke = pbHeldPokemon
    pokemon = @storage[selected[0], selected[1]]

    if !pokemon
      command = pbShowCommands("Select an action", ["Stop fusing", "Cancel"])
      case command
      when 0 #stop
        pbPlace(selected)
        cancelFusion()
      end
    else
      commands = [
        _INTL("Fuse"),
        _INTL("Swap")
      ]
      commands.push(_INTL("Stop fusing"))
      commands.push(_INTL("Cancel"))

      if !heldpoke
        pbPlace(selected)
        @fusionMode = false
        @scene.setFusing(false)
        return
      end
      command = pbShowCommands("Select an action", commands)
      case command
      when 0 #Fuse
        pbStartFusion(selected)
      when 1 #swap
        if pokemon
          if dexNum(pokemon.species) <= NB_POKEMON
            pbSwap(selected)
          else
            pbDisplay(_INTL("This Pokémon is already fused!"))
          end
        else
          pbDisplay(_INTL("Select a Pokémon!"))
        end
      when 2 #cancel
        cancelFusion()
        return
      end
    end
  end

  def pbStartFusion(selected)
    heldpoke = pbHeldPokemon
    pokemon = @storage[selected[0], selected[1]]

    if !pokemon
      pbDisplay(_INTL("No Pokémon selected!"))
      return
    else
      if dexNum(pokemon.species) > NB_POKEMON
        pbDisplay(_INTL("This Pokémon is already fused!"))
        return
      end
    end
    isSuperSplicer = isSuperSplicer?(@fusionItem)


    selectedHead =selectFusion(pokemon, heldpoke, isSuperSplicer)
    if selectedHead == nil
      pbDisplay(_INTL("It won't have any effect."))
      return false
    end
    if selectedHead == -1 #cancelled out
      return false
    end

    selectedBase = selectedHead == pokemon ? heldpoke : pokemon
    firstOptionSelected= selectedBase == pokemon


    if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?")))
      playingBGM = $game_system.getPlayingBGM
      pbFuse(selectedHead, selectedBase, @fusionItem)
      if canDeleteItem(@fusionItem)
        $PokemonBag.pbDeleteItem(@fusionItem)
      end
      if firstOptionSelected
        deleteSelectedPokemon(heldpoke, selected)
      else
        deleteHeldPokemon(heldpoke, selected)
      end

      @scene.setFusing(false)
      @fusionMode = false
      @scene.sprites["box"].enableFusions()
      pbBGMPlay(playingBGM)
      return
    else
      # print "fusion cancelled"
      # @fusionMode = false
    end
  end

  def reverseFromPC(selected)
    box = selected[0]
    index = selected[1]
    pokemon = @storage[box, index]

    if !pokemon.isFusion?
      scene.pbDisplay(_INTL("It won't have any effect."))
      return
    end
    if Kernel.pbConfirmMessage(_INTL("Should {1} be reversed?", pokemon.name))
      reverseFusion(pokemon)
    end
    $PokemonBag.pbDeleteItem(:DNAREVERSER) if $PokemonBag.pbQuantity(:INFINITEREVERSERS) <= 0
  end

  def pbUnfuseFromPC(selected)
    box = selected[0]
    index = selected[1]
    pokemon = @storage[box, index]

    #Kuray No Confirm on Unfuse
    item = selectSplicer()
    return if item == nil
    isSuperSplicer = isSuperSplicer?(item)
    if pbUnfuse(pokemon, @scene, isSuperSplicer, selected)
      if canDeleteItem(item)
        $PokemonBag.pbDeleteItem(item)
      end
    end
    @scene.pbHardRefresh
    # if pbConfirm(_INTL("Unfuse {1}?", pokemon.name))
    #   item = selectSplicer()
    #   return if item == nil
    #   isSuperSplicer = isSuperSplicer?(item)
    #   if pbUnfuse(pokemon, @scene, isSuperSplicer, selected)
    #     if canDeleteItem(item)
    #       $PokemonBag.pbDeleteItem(item)
    #     end
    #   end
    #   @scene.pbHardRefresh
    # end
  end

  def selectSplicer()
    dna_splicers_const = "DNA Splicers"
    super_splicers_const = "Super Splicers"
    infinite_splicers_const = "Infinite Splicers"

    dnaSplicersQt = $PokemonBag.pbQuantity(:DNASPLICERS)
    superSplicersQt = $PokemonBag.pbQuantity(:SUPERSPLICERS)
    infiniteSplicersQt = $PokemonBag.pbQuantity(:INFINITESPLICERS)
    infiniteSplicers2Qt = $PokemonBag.pbQuantity(:INFINITESPLICERS2)

    options = []
    options.push(_INTL "{1}", infinite_splicers_const) if infiniteSplicers2Qt > 0 || infiniteSplicersQt > 0
    options.push(_INTL("{1} ({2})", super_splicers_const, superSplicersQt)) if superSplicersQt > 0
    options.push(_INTL("{1} ({2})", dna_splicers_const, dnaSplicersQt)) if dnaSplicersQt > 0

    if options.length <= 0
      pbDisplay(_INTL("You have no fusion items available."))
      return nil
    end

    cmd = pbShowCommands("Use which splicers?", options)
    if cmd == -1
      return nil
    end
    ret = options[cmd]
    if ret.start_with?(dna_splicers_const)
      return :DNASPLICERS
    elsif ret.start_with?(super_splicers_const)
      return :SUPERSPLICERS
    elsif ret.start_with?(infinite_splicers_const)
      return infiniteSplicers2Qt >= 1 ? :INFINITESPLICERS2 : :INFINITESPLICERS
    end
    return nil
  end

  def getBoxPosition(box, index)
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    return index % boxWidth, (index.to_f / boxWidth).floor
  end

  def getBoxIndex(box, x, y)
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    return x + y * boxWidth
  end

  def getSelectionRect(box, currentSelected)
    rangeEnd = (currentSelected != nil ? currentSelected : @multiSelectRange[1])

    if !@multiSelectRange || !@multiSelectRange[0] || !rangeEnd
      return nil
    end

    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH

    ax = @multiSelectRange[0] % boxWidth
    ay = (@multiSelectRange[0].to_f / boxWidth).floor
    bx = rangeEnd % boxWidth
    by = (rangeEnd.to_f / boxWidth).floor

    minx = [ax, bx].min
    miny = [ay, by].min
    maxx = [ax, bx].max
    maxy = [ay, by].max

    return Rect.new(minx, miny, maxx-minx+1, maxy-miny+1)
  end

  def getMultiSelection(box, currentSelected)
    rect = getSelectionRect(box, currentSelected)

    ret = []

    for j in (rect.y)..(rect.y+rect.height-1)
      for i in (rect.x)..(rect.x+rect.width-1)
        ret.push(getBoxIndex(box, i, j))
      end
    end

    return ret
  end
end
