#===============================================================================
# Data box for regular battles
#===============================================================================
class PokemonDataBox < SpriteWrapper
  attr_reader   :battler
  attr_accessor :selected
  attr_reader   :animatingHP
  attr_reader   :animatingExp

  # Time in seconds to fully fill the Exp bar (from empty).
  EXP_BAR_FILL_TIME  = 1.75
  # Maximum time in seconds to make a change to the HP bar.
  HP_BAR_CHANGE_TIME = 1.0
  STATUS_ICON_HEIGHT = 16
  # NAME_BASE_COLOR         = Color.new(72,72,72)
  # NAME_SHADOW_COLOR       = Color.new(184,184,184)
  # MALE_BASE_COLOR         = Color.new(48,96,216)
  # MALE_SHADOW_COLOR       = NAME_SHADOW_COLOR
  # FEMALE_BASE_COLOR       = Color.new(248,88,40)
  # FEMALE_SHADOW_COLOR     = NAME_SHADOW_COLOR
  #KurayNewSymbolGender
  NAME_BASE_COLOR         = Color.new(255,255,255)
  NAME_SHADOW_COLOR       = Color.new(32,32,32)
  MALE_BASE_COLOR         = Color.new(55, 148, 229)
  MALE_SHADOW_COLOR       = NAME_SHADOW_COLOR
  FEMALE_BASE_COLOR       = Color.new(229, 55, 203)
  FEMALE_SHADOW_COLOR     = NAME_SHADOW_COLOR


  def initialize(battler,sideSize,viewport=nil)
    super(viewport)
    @battler      = battler
	@sideSize     = sideSize # Trapstarr BattleGUI
    @sprites      = {}
    @spriteX      = 0
    @spriteY      = 0
    @spriteBaseX  = 0
    @selected     = 0
    @frame        = 0
    @showHP       = false   # Specifically, show the HP numbers
    @animatingHP  = false
    @showExp      = false   # Specifically, show the Exp bar
    @animatingExp = false
    @expFlash     = 0
    initializeDataBoxGraphic(sideSize)
    initializeOtherGraphics(viewport)
    refresh
  end

  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = ((@battler.index%2)==0)
    # Get the data box graphic and set whether the HP numbers/Exp bar are shown
    if sideSize == 1   # One Pokémon on side, use the regular data box BG
      bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                        "Graphics/Pictures/Battle/databox_normal_foe"][@battler.index % 2]
      if onPlayerSide
        @showHP  = true
        @showExp = true
      end
    else   # Multiple Pokémon on side, use the thin data box BG
      bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                        "Graphics/Pictures/Battle/databox_thin_foe"][@battler.index % 2]
    end

    # Trapstarr - Adding swappable battle GUIs. WIP
    if $PokemonSystem.battlegui != 0 && $PokemonSystem.battlegui != nil
      case $PokemonSystem.battlegui
      when 1
        bgFilename = bgFilename.gsub("Battle", "BattleGUI") + "_M"
        # Adjust for darkmode
        if $PokemonSystem.darkmode && $PokemonSystem.darkmode == 1
          bgFilename += "_darkmode"
        end
      when 2
        bgFilename = bgFilename.gsub("Battle", "BattleGUI") + "_M2"
        # You can also add dark mode adjustment here if needed
      end
    end

    @databoxBitmap  = AnimatedBitmap.new(bgFilename)
    # Determine the co-ordinates of the data box and the left edge padding width
    if onPlayerSide
      @spriteX = Graphics.width - 244
      @spriteY = Graphics.height - 180 #176#192
      @spriteBaseX = 34
    else
      @spriteX = 8 #-16
      @spriteY = 0 #36
      @spriteBaseX = 8 #16
    end
    case sideSize
    when 2
      @spriteX += [-12,  12,  0,  0][@battler.index]

      #@spriteY += [-38, -6, 16, 48][@battler.index]    #standard
      @spriteY += [-32, -6, 16, 42][@battler.index]     #smaller gap
      #@spriteY += [-18, -6, 16, 28][@battler.index]     #overlap

    when 3
      @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]

      @spriteY += [-74, -8,  -28,  38, 16, 84][@battler.index]    #standard
      #@spriteY += [-54, -8,  -18,  26, 16, 58][@battler.index]    #overlap
    end
  end

  def initializeOtherGraphics(viewport)
    # Use hardcoded paths to perform gsub
    hpPath = "Graphics/Pictures/Battle/overlay_hp"
    expPath = "Graphics/Pictures/Battle/overlay_exp"

    # Trapstarr - Adding swappable battle GUIs. WIP
    if $PokemonSystem.battlegui != 0 && $PokemonSystem.battlegui != nil
      case $PokemonSystem.battlegui
      when 1
        hpPath = hpPath.gsub("Battle", "BattleGUI") + "_M"
        expPath = expPath.gsub("Battle", "BattleGUI") + "_M"
      when 2
        hpPath = hpPath.gsub("Battle", "BattleGUI") + "_M2"
        expPath = expPath.gsub("Battle", "BattleGUI") + "_M2"    
      end
    end

    # Create other bitmaps with the modified paths
    @numbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/icon_numbers"))
    @hpBarBitmap = AnimatedBitmap.new(hpPath)
    @expBarBitmap = AnimatedBitmap.new(expPath)
	
	# Trapstarr's Type Display
   if $PokemonSystem.typedisplay != 0  && $PokemonSystem.typedisplay != nil
      case $PokemonSystem.typedisplay
      when 1
        @typeDisplayBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/TypeIcons_Lolpy1"))
      when 2
        @typeDisplayBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/TypeIcons_TCG"))
      when 3
        @typeDisplayBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/TypeIcons_Square"))
      when 4
        @typeDisplayBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/TypeIcons_FairyGodmother"))
      when 5
        @typeDisplayBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types_display"))
      end
    end
    # Create sprite to draw HP numbers on
    @hpNumbers = BitmapSprite.new(124,16,viewport)
    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    # Create sprite wrapper that displays HP bar
    @hpBar = SpriteWrapper.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar"] = @hpBar
    # Create sprite wrapper that displays Exp bar
    @expBar = SpriteWrapper.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    # Trapstarr's Type Display: Create a sprite wrapper that displays Opponents Type
    if [1,2,3,4,5].include?($PokemonSystem.typedisplay)
      typeDisplayBitmap = Bitmap.new(Graphics.width, Graphics.height)  
      @typeDisplay = SpriteWrapper.new(viewport)  
      @typeDisplay.bitmap = typeDisplayBitmap  
      @sprites["typeDisplay"] = @typeDisplay
	  @sprites["typeDisplay"].z = 10000 # Applying Z Layer
    end	
    # Trapstarr's Status Icon Fix (Seperating status icon, appling z+1)	
    @statusIcon = SpriteWrapper.new(viewport)	
    @sprites["statusIcon"] = @statusIcon
    # Create sprite wrapper that displays everything except the above
    @contents = BitmapWrapper.new(@databoxBitmap.width,@databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150+((@battler.index)/2)*5
    pbSetSystemFont(self.bitmap)
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
    # Trapstarr's Type Display & Status Icon
    @typeDisplayBitmap.dispose if @typeDisplayBitmap # Prevents nil
    @statusIcon.dispose if @statusIcon # Prevents nil
    @contents.dispose
    super
  end

 def x=(value)
    super
	# Trapstarr BattleGUI swapping
    if $PokemonSystem.battlegui && $PokemonSystem.battlegui == 2
      case @sideSize
      when 2,3
        @hpBar.x = value + @spriteBaseX + (@battler.opposes?(0) ? 31 : 31) # Foe/Player
      else
        @hpBar.x = value + @spriteBaseX + (@battler.opposes?(0) ? 31 : 12) # Foe/Player
      end
      @expBar.x    = value + @spriteBaseX - 25
      @hpNumbers.x = value + @spriteBaseX + 80
      @statusIcon.x = value + @spriteBaseX + 24
    else
      @hpBar.x     = value + @spriteBaseX + 12
      @expBar.x    = value + @spriteBaseX + 24
      @hpNumbers.x = value + @spriteBaseX + 80
      @statusIcon.x = value + @spriteBaseX + 24
    end
  end

  # Trapstarr - BattleGUI swapping
  def y=(value)
    super
    if $PokemonSystem.battlegui && $PokemonSystem.battlegui == 2
      case @sideSize
      when 2,3
        @hpBar.y = value + (@battler.opposes?(0) ? 37 : 37) # Foe/Player
      else
        @hpBar.y = value + (@battler.opposes?(0) ? 38 : 38) # Foe/Player
      end
      @expBar.y    = value + 60
      @hpNumbers.y = value + 52
      @statusIcon.y = value + (@battler.opposes?(0) ? 49 : 52) # Foe/Player
    else
      @hpBar.y     = value + 40
      @expBar.y    = value + 64
      @hpNumbers.y = value + 52
      @statusIcon.y = value + (@battler.opposes?(0) ? 49 : 52) # Foe/Player
    end
  end

  def z=(value)
    super
    @hpBar.z     = value+1
    @expBar.z    = value+1
    @hpNumbers.z = value+2
    @statusIcon.z = value+2 if @statusIcon # Push status icon to top
  end

  def opacity=(value)
    super
    for i in @sprites
      i[1].opacity = value if !i[1].disposed?
    end
  end

  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
  end

  def color=(value)
    super
    for i in @sprites
      i[1].color = value if !i[1].disposed?
    end
  end

  def battler=(b)
    @battler = b
    self.visible = (@battler && !@battler.fainted?)
  end

  def hp
    return (@animatingHP) ? @currentHP : @battler.hp
  end

  def exp_fraction
    return (@animatingExp) ? @currentExp.to_f/@rangeExp : @battler.pokemon.exp_fraction
  end

  def animateHP(oldHP,newHP,rangeHP)
    @currentHP   = oldHP
    @endHP       = newHP
    @rangeHP     = rangeHP
    # NOTE: A change in HP takes the same amount of time to animate, no matter
    #       how big a change it is.
    @hpIncPerFrame = (newHP-oldHP).abs/(HP_BAR_CHANGE_TIME*Graphics.frame_rate)
    # minInc is the smallest amount that HP is allowed to change per frame.
    # This avoids a tiny change in HP still taking HP_BAR_CHANGE_TIME seconds.
    minInc = (rangeHP*4)/(@hpBarBitmap.width*HP_BAR_CHANGE_TIME*Graphics.frame_rate)
    @hpIncPerFrame = minInc if @hpIncPerFrame<minInc
    @animatingHP   = true
  end

  def animateExp(oldExp,newExp,rangeExp)
    @currentExp     = oldExp
    @endExp         = newExp
    @rangeExp       = rangeExp
    # NOTE: Filling the Exp bar from empty to full takes EXP_BAR_FILL_TIME
    #       seconds no matter what. Filling half of it takes half as long, etc.
    @expIncPerFrame = rangeExp/(EXP_BAR_FILL_TIME*Graphics.frame_rate)
    @animatingExp   = true
    pbSEPlay("Pkmn exp gain") if @showExp
  end

  def pbDrawNumber(number,btmp,startX,startY,align=0)
    # -1 means draw the / character
    n = (number == -1) ? [10] : number.to_i.digits.reverse
    charWidth  = @numbersBitmap.width/11
    charHeight = @numbersBitmap.height
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,@numbersBitmap.bitmap,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end
  
  # Trapstarr's Type Display
  def drawtypeDisplay
    return if $PokemonSystem.typedisplay == 0 || $PokemonSystem.typedisplay == nil
    typeDisplay = @sprites["typeDisplay"].bitmap
    if @battler.opposes?(0)
      type1 = @battler.pokemon.type1
      type2 = @battler.pokemon.type2
      type1_number = GameData::Type.get(type1).id_number
      type2_number = GameData::Type.get(type2).id_number

      case $PokemonSystem.typedisplay
      when 1,2,3,4#icons
        type1rect = Rect.new(0, type1_number * 20, 24, 20)
        type2rect = Rect.new(0, type2_number * 20, 24, 20)
      when 5#text
        type1rect = Rect.new(0, type1_number * 28, 64, 28)
        type2rect = Rect.new(0, type2_number * 28, 64, 28)
      end

      scale = ($PokemonSystem.typedisplay == 5) ? 0.65 : 1
      scaled_width = (type1rect.width * scale).to_i
      case $PokemonSystem.typedisplay
      when 1,2,3,4#icons
        scaled_height = (type1rect.height * (scale)).to_i
      when 5#text
        scaled_height = (type1rect.height * (scale * 1.2)).to_i
      end
	  
      type_x = @spriteBaseX + (@hpBar.x + 185)
      case $PokemonSystem.typedisplay
      when 1,2,3,4#icons
        type_y = @hpBar.y + @hpBar.src_rect.height - 43
        type2_y = type_y + 5 # Spacing
      when 5#text
        type_y = @hpBar.y + @hpBar.src_rect.height - 40
      end
	  
      if type1 == type2
        typeDisplay.stretch_blt(
          Rect.new(type_x, type_y, scaled_width, scaled_height),
          @typeDisplayBitmap.bitmap,
          type1rect
        )
      else
        typeDisplay.stretch_blt(
          Rect.new(type_x, type_y, scaled_width, scaled_height),
          @typeDisplayBitmap.bitmap,
          type1rect
        )
        case $PokemonSystem.typedisplay
        when 1,2,3,4#icons
          typeDisplay.stretch_blt(
            Rect.new(type_x, type2_y + scaled_height, scaled_width, scaled_height),
            @typeDisplayBitmap.bitmap,
            type2rect
         )
        when 5#text
          typeDisplay.stretch_blt(
            Rect.new(type_x, type_y + scaled_height, scaled_width, scaled_height),
            @typeDisplayBitmap.bitmap,
            type2rect
          )
        end
      end
    end
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    textPos = []
    imagePos = []
    # Draw background panel
    self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
    # Draw Pokémon's name
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth-116 if nameWidth>116
    textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
    # Draw Pokémon's gender symbol
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
    if @battler.displayGenderPizza
      imagePos.push(["Graphics/Pictures/Storage/gender4", @spriteBaseX+126-18, 5])
      # textPos.push([_INTL(kuraygender4t), @spriteBaseX+126, 0, false, Color.new(kuraygender4r[0], kuraygender4r[1], kuraygender4r[2]), Color.new(kuraygender4s[0], kuraygender4s[1], kuraygender4s[2])])
    else
      case @battler.displayGender
      when 0   # Male
        textPos.push([_INTL(kuraygender1t), @spriteBaseX+126, 0, false, Color.new(kuraygender1r[0], kuraygender1r[1], kuraygender1r[2]), Color.new(kuraygender1s[0], kuraygender1s[1], kuraygender1s[2])])
      when 1   # Female
        textPos.push([_INTL(kuraygender2t), @spriteBaseX+126, 0, false, Color.new(kuraygender2r[0], kuraygender2r[1], kuraygender2r[2]), Color.new(kuraygender2s[0], kuraygender2s[1], kuraygender2s[2])])
      when 2  # Genderless
        imagePos.push(["Graphics/Pictures/Storage/gender3", @spriteBaseX+126-14, 14])
        # textPos.push([_INTL(kuraygender3t), @spriteBaseX+126, 0, false, Color.new(kuraygender3r[0], kuraygender3r[1], kuraygender3r[2]), Color.new(kuraygender3s[0], kuraygender3s[1], kuraygender3s[2])])
      end
    end
    pbDrawTextPositions(self.bitmap,textPos)
    # Draw Pokémon's level
    show_level = true
    if $game_switches[SWITCH_NO_LEVELS_MODE] && ($PokemonSystem.showlevel_nolevelmode && $PokemonSystem.showlevel_nolevelmode == 0)
      show_level = false
    end
    imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16]) if show_level
    pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16) if show_level
    # Draw shiny icon
    if @battler.shiny? || @battler.fakeshiny?
      shinyX = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
      #KurayX
      # pokeRadarShiny= !@battler.pokemon.debugShiny? && !@battler.pokemon.naturalShiny?
      #KurayX new ShinyStars
      shinyY = 35
      if $PokemonSystem.typedisplay != 0 #Trapstarr - Reposition shiny star if type display is on
        shinyX = (@battler.opposes?(0)) ? -8 : -6 # Foe's/player's (Left of Nameplate)
        shinyY = 13
      end
      addShinyStarsToGraphicsArray(imagePos,@spriteBaseX+shinyX,shinyY, @battler.pokemon.bodyShiny?,@battler.pokemon.headShiny?,@battler.pokemon.debugShiny?,nil,nil,nil,nil,false,false,@battler.pokemon.fakeshiny?,[@battler.pokemon.shinyR?,@battler.pokemon.shinyG?,@battler.pokemon.shinyB?,@battler.pokemon.shinyKRS?])
    end
    # Draw Mega Evolution/Primal Reversion icon
    if @battler.mega?
      imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
    elsif @battler.primal?
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      if @battler.isSpecies?(:KYOGRE)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+primalX,4])
      elsif @battler.isSpecies?(:GROUDON)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+primalX,4])
      end
    end
    # Draw owned icon (foe Pokémon only)
    if @battler.owned? && @battler.opposes?(0)
      imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX-8,42])
    end
    # Draw status icon
    # if @battler.status != :NONE
    #   s = GameData::Status.get(@battler.status).id_number
    #   if s == :POISON && @battler.statusCount > 0   # Badly poisoned
    #     s = GameData::Status::DATA.keys.length / 2
    #   end
    #   imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,56,
    #                  0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
    # end
    pbDrawImagePositions(self.bitmap,imagePos)
    refreshHP
    refreshExp
    refreshStatus
    # Trapstarr's Type Display
    if $PokemonSystem.typedisplay != 0 && $PokemonSystem.typedisplay != nil
      refreshtypeDisplay
    end
  end

  def refreshHP
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Show HP numbers
    if @showHP
      pbDrawNumber(self.hp,@hpNumbers.bitmap,54,2,1)
      pbDrawNumber(-1,@hpNumbers.bitmap,54,2)   # / char
      pbDrawNumber(@battler.totalhp,@hpNumbers.bitmap,70,2)
    end
    # Resize HP bar
    w = 0
    if self.hp>0
      w = @hpBarBitmap.width.to_f*self.hp/@battler.totalhp
      w = 1 if w<1
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      #       fit in with the rest of the graphics which are doubled in size.
      w = ((w/2.0).round)*2
    end
    @hpBar.src_rect.width = w
    hpColor = 0                                  # Green bar
    hpColor = 1 if self.hp<=@battler.totalhp/2   # Yellow bar
    hpColor = 2 if self.hp<=@battler.totalhp/4   # Red bar
    @hpBar.src_rect.y = hpColor*@hpBarBitmap.height/3
  end
	
  # def refreshExp
  #   return if !@showExp
  #   return if @battler.level >= 100
  #   w = exp_fraction * @expBarBitmap.width
  #   # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
  #   #       fit in with the rest of the graphics which are doubled in size.
  #   w = ((w/2).round)*2
  #   @expBar.src_rect.width = w
  # end
	
  # Trapstarr's exp bar patch & BattleGUI swapping
  def refreshExp
    return if !@showExp
    return if @battler.level >= GameData::GrowthRate.max_level
    # Set the default scaling factor
    default_scaling_factor = 1.0 # Change this to your default scaling factor
    case $PokemonSystem.battlegui
    when nil, 0, 1
      # Use the default scaling factor
      scaling_factor = default_scaling_factor
    when 2
      # Use your custom scaling factor
      scaling_factor = 1.5 # Change this to your custom scaling factor
    else
      # Handle other cases if needed
      scaling_factor = default_scaling_factor
    end
    # if exp_fraction != 0 && @expBarBitmap.width != 0
    if exp_fraction != 0 && @expBarBitmap.width != 0 && !exp_fraction.nan?
    # if !exp_fraction.nan? && !@expBarBitmap.width && exp_fraction != 0 && @expBarBitmap.width != 0
      width = exp_fraction * @expBarBitmap.width
      # Apply scaling by multiplying 'width' by the scaling factor
      width *= scaling_factor
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      # fit in with the rest of the graphics which are doubled in size.
      width = ((width / 2).round) * 2
      @expBar.src_rect.width = width
    else
      @expBar.src_rect.width = 0
    end
  end

  
  # Trapstarr's Status Icon Patch
  def refreshStatus
   scale = 1.0  # logic for future scaling to match text
   @statusIcon.bitmap.clear if @statusIcon.bitmap
    return if !@battler || @battler.status == :NONE
    s = GameData::Status.get(@battler.status).id_number
    if s == :POISON && @battler.statusCount > 0   # Badly poisoned
      s = GameData::Status::DATA.keys.length / 2
    end
    unscaled_bitmap = Bitmap.new("Graphics/Pictures/Battle/icon_statuses")
    # Calculate scaled dimensions
    scaled_width = (unscaled_bitmap.width * scale).to_i
    scaled_height = (STATUS_ICON_HEIGHT * scale).to_i
    # Create a new bitmap with scaled dimensions
    @statusIcon.bitmap = Bitmap.new(scaled_width, scaled_height)
    # Stretch the relevant portion of the unscaled bitmap to the scaled bitmap
    @statusIcon.bitmap.stretch_blt(Rect.new(0, 0, scaled_width, scaled_height), 
                                   unscaled_bitmap, 
                                   Rect.new(0, (s - 1) * STATUS_ICON_HEIGHT, unscaled_bitmap.width, STATUS_ICON_HEIGHT))
    @statusIcon.src_rect.set(0, 0, scaled_width, scaled_height)
  end
  
  # Trapstarr's Type Display
  def refreshtypeDisplay
    return if $PokemonSystem.typedisplay == 0 || $PokemonSystem.typedisplay == nil
    @typeDisplay.bitmap.clear
    return if !@battler.pokemon || @battler.fainted?
    if @hpBar.visible
      drawtypeDisplay
    end
  end

  # Trapstarr's Type Display
  def updatetypeDisplay
    return if $PokemonSystem.typedisplay == 0 || $PokemonSystem.typedisplay == nil
    refreshtypeDisplay
  end

  def updateHPAnimation
    return if !@animatingHP
    if @currentHP<@endHP      # Gaining HP
      @currentHP += @hpIncPerFrame
      @currentHP = @endHP if @currentHP>=@endHP
    elsif @currentHP>@endHP   # Losing HP
      @currentHP -= @hpIncPerFrame
      @currentHP = @endHP if @currentHP<=@endHP
    end
    # Refresh the HP bar/numbers
    refreshHP
    @animatingHP = false if @currentHP==@endHP
  end

  def updateExpAnimation
    return if !@animatingExp
    if !@showExp   # Not showing the Exp bar, no need to waste time animating it
      @currentExp = @endExp
      @animatingExp = false
      return
    end
    if @currentExp<@endExp   # Gaining Exp
      @currentExp += @expIncPerFrame
      @currentExp = @endExp if @currentExp>=@endExp
    elsif @currentExp>@endExp   # Losing Exp
      @currentExp -= @expIncPerFrame
      @currentExp = @endExp if @currentExp<=@endExp
    end
    # Refresh the Exp bar
    refreshExp
    return if @currentExp!=@endExp   # Exp bar still has more to animate
    # Exp bar is completely filled, level up with a flash and sound effect
    if @currentExp>=@rangeExp
      if @expFlash==0
        pbSEStop
        @expFlash = Graphics.frame_rate/5
        pbSEPlay("Pkmn exp full")
        self.flash(Color.new(64,200,248,192),@expFlash)
        for i in @sprites
          i[1].flash(Color.new(64,200,248,192),@expFlash) if !i[1].disposed?
        end
      else
        @expFlash -= 1
        @animatingExp = false if @expFlash==0
      end
    else
      pbSEStop
      # Exp bar has finished filling, end animation
      @animatingExp = false
    end
  end

  QUARTER_ANIM_PERIOD = Graphics.frame_rate*3/20

  def updatePositions(frameCounter)
    self.x = @spriteX
    self.y = @spriteY
    # Data box bobbing while Pokémon is selected
    if @selected==1 || @selected==2   # Choosing commands/targeted or damaged
      case (frameCounter/QUARTER_ANIM_PERIOD).floor
      when 1 then self.y = @spriteY-2
      when 3 then self.y = @spriteY+2
      end
    end
  end

  def update(frameCounter=0)
    super()
    # Animate HP bar
    updateHPAnimation
    # Animate Exp bar
    updateExpAnimation
    # Trapstarr - Update Type Display
    if $PokemonSystem.typedisplay != 0 && $PokemonSystem.typedisplay != nil	
      updatetypeDisplay	
    end
    # Update coordinates of the data box
    updatePositions(frameCounter)
    pbUpdateSpriteHash(@sprites)
  end
end



#===============================================================================
# Splash bar to announce a triggered ability
#===============================================================================
class AbilitySplashBar < SpriteWrapper
  attr_reader :battler

  TEXT_BASE_COLOR   = Color.new(0,0,0)
  TEXT_SHADOW_COLOR = Color.new(248,248,248)

  def initialize(side,viewport=nil, secondAbility=false)
    super(viewport)
    @ability_name=nil
    @secondAbility=secondAbility
    @side    = side
    @battler = nil
    # Create sprite wrapper that displays background graphic
    @bgBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/ability_bar"))
    @bgSprite = SpriteWrapper.new(viewport)
    @bgSprite.bitmap = @bgBitmap.bitmap
    @bgSprite.src_rect.y      = (side==0) ? 0 : @bgBitmap.height/2
    @bgSprite.src_rect.height = @bgBitmap.height/2
    # Create bitmap that displays the text
    @contents = BitmapWrapper.new(@bgBitmap.width,@bgBitmap.height/2)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    # Position the bar
    self.x       = (side==0) ? -Graphics.width/2 : Graphics.width
    self.y       = (side==0) ? 180 : 80
    self.z       = 120
    self.visible = false
  end

  def dispose
    @bgSprite.dispose
    @bgBitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    @bgSprite.x = value
  end

  def y=(value)
    super
    @bgSprite.y = value
  end

  def z=(value)
    super
    @bgSprite.z = value-1
  end

  def ability_name=(value)
    @ability_name=value
  end

  def opacity=(value)
    super
    @bgSprite.opacity = value
  end

  def visible=(value)
    super
    @bgSprite.visible = value
  end

  def color=(value)
    super
    @bgSprite.color = value
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def secondAbility=(value)
    @secondAbility = value
  end
  
  def refresh
    self.bitmap.clear
    return if !@battler
    textPos = []
    textX = (@side==0) ? 10 : self.bitmap.width-8
    # Draw Pokémon's name
    textPos.push([_INTL("{1}'s",@battler.name),textX,-4,@side==1,
       TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true]) if !@secondAbility
    # Draw Pokémon's ability
    abilityName = @secondAbility ? @battler.ability2Name : @battler.abilityName
    abilityName = @ability_name if @ability_name
    #return if abilityName ==""
    textPos.push([abilityName,textX,26,@side==1,
       TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
    pbDrawTextPositions(self.bitmap,textPos)
  end

  def update
    super
    @bgSprite.update
  end
end



#===============================================================================
# Pokémon sprite (used in battle)
#===============================================================================
class PokemonBattlerSprite < RPG::Sprite
  attr_reader   :pkmn
  attr_accessor :index
  attr_accessor :selected
  attr_reader   :sideSize

  def initialize(viewport,sideSize,index,battleAnimations)
    super(viewport)
    @pkmn             = nil
    @sideSize         = sideSize
    @index            = index
    @battleAnimations = battleAnimations
    # @selected: 0 = not selected, 1 = choosing action bobbing for this Pokémon,
    #            2 = flashing when targeted
    @selected         = 0
    @frame            = 0
    @updating         = false
    @spriteX          = 0   # Actual x coordinate
    @spriteY          = 0   # Actual y coordinate
    @spriteXExtra     = 0   # Offset due to "bobbing" animation
    @spriteYExtra     = 0   # Offset due to "bobbing" animation
    @_iconBitmap      = nil
    self.visible      = false
    @back=false
  end

  def dispose
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def x; return @spriteX; end
  def y; return @spriteY; end

  def x=(value)
    @spriteX = value
    self.mirror=true if @back
    super(value+@spriteXExtra)
  end

  def y=(value)
    @spriteY = value
    self.mirror=true if @back
    super(value+@spriteYExtra)
  end

  def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end

  def visible=(value)
    @spriteVisible = value if !@updating   # For selection/targeting flashing
    super
  end

  # Set sprite's origin to bottom middle
  def pbSetOrigin
    return if !@_iconBitmap
    self.mirror=true if @back
    self.ox = @_iconBitmap.width/2
    self.oy = @_iconBitmap.height
  end

  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    if (@index%2)==0
      self.z = 50+5*@index/2
    else
      self.z = 50-5*(@index+1)/2
    end
    # Set original position
    p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index)
  end

  def setPokemonBitmap(pkmn,back=false)
    @back = back
    self.mirror=true if @back
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back)
    scale =Settings::FRONTSPRITE_SCALE
    scale = Settings::BACKRPSPRITE_SCALE if @back
    @_iconBitmap.scale_bitmap(scale)

    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    add_hat_to_bitmap(self.bitmap,pkmn.hat,pkmn.hat_x,pkmn.hat_y,scale,self.mirror) if self.bitmap && pkmn.hat

    pbSetPosition
  end

  # This method plays the battle entrance animation of a Pokémon. By default
  # this is just playing the Pokémon's cry, but you can expand on it. The
  # recommendation is to create a PictureEx animation and push it into
  # the @battleAnimations array.
  def pbPlayIntroAnimation(pictureEx=nil)
    @pkmn.play_cry if @pkmn
  end

  QUARTER_ANIM_PERIOD = Graphics.frame_rate*3/20
  SIXTH_ANIM_PERIOD   = Graphics.frame_rate*2/20

  def update(frameCounter=0)
    return if !@_iconBitmap
    @updating = true
    # Update bitmap
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    # Pokémon sprite bobbing while Pokémon is selected
    @spriteYExtra = 0
    if @selected==1    # When choosing commands for this Pokémon
      case (frameCounter/QUARTER_ANIM_PERIOD).floor
      when 1 then @spriteYExtra = 2
      when 3 then @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    self.visible = @spriteVisible
    # Pokémon sprite blinking when targeted
    if @selected==2 && @spriteVisible
      case (frameCounter/SIXTH_ANIM_PERIOD).floor
      when 2, 5 then self.visible = false
      else           self.visible = true
      end
    end
    @updating = false
  end
end



#===============================================================================
# Shadow sprite for Pokémon (used in battle)
#===============================================================================
class PokemonBattlerShadowSprite < RPG::Sprite
  attr_reader   :pkmn
  attr_accessor :index
  attr_accessor :selected

  def initialize(viewport,sideSize,index)
    super(viewport)
    @pkmn        = nil
    @sideSize    = sideSize
    @index       = index
    @_iconBitmap = nil
    self.visible = false
  end

  def dispose
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end

  # Set sprite's origin to centre
  def pbSetOrigin
    return if !@_iconBitmap
    self.ox = @_iconBitmap.width/2
    self.oy = @_iconBitmap.height/2
  end

  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    self.z = 3
    # Set original position
    p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize)
    self.x = p[0]
    self.y = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, true)
  end

  def setPokemonBitmap(pkmn)
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = GameData::Species.shadow_bitmap_from_pokemon(@pkmn)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
  end

  def update(frameCounter=0)
    return if !@_iconBitmap
    # Update bitmap
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
  end
end
