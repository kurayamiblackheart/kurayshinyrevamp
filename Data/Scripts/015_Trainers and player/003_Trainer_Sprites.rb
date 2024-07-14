#===============================================================================
# Walking charset, for use in text entry screens and load game screen
#===============================================================================
class TrainerWalkingCharSprite < SpriteWrapper
  def initialize(charset,viewport=nil,trainer=nil)
    super(viewport)
    @animbitmap = nil
    @trainer=trainer
    self.charset = charset
    @animframe      = 0   # Current pattern
    @frame          = 0   # Frame counter
    self.animspeed  = 5   # Animation speed (frames per pattern)
  end


  def charset=(value)
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil

    outfit_bitmap = _INTL("Graphics/Characters/players/outfits/{1}_{2}",value,$Trainer.outfit) if $Trainer && $Trainer.outfit

    @trainer = $Trainer if !@trainer
    if $Trainer
      meta=GameData::Metadata.get_player($Trainer.character_ID)
      isPlayerCharacter = value == pbGetPlayerCharset(meta,1,nil,true)
    end
    isPlayerCharacter = true if $scene.is_a?(Scene_Intro) #

    bitmapFileName = sprintf("Graphics/Characters/%s",value)
    @charset = pbResolveBitmap(bitmapFileName)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      if isPlayerCharacter #Display clothed player on continue screen
        @animbitmap.bitmap = generateClothedBitmapStatic(@trainer)
        @animbitmap.bitmap.blt(0, 0, outfit_bitmap, outfit_bitmap.rect) if pbResolveBitmap(outfit_bitmap)
      else
        @animbitmap.bitmap.blt(0, 0, outfit_bitmap, outfit_bitmap.rect) if pbResolveBitmap(outfit_bitmap)
      end
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0,0,self.bitmap.width/4,self.bitmap.height/4)
    else
      self.bitmap = nil
    end
  end

  def altcharset=(value)   # Used for box icon in the naming screen
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    @charset = pbResolveBitmap(value)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0,0,self.bitmap.width/4,self.bitmap.height)
    else
      self.bitmap = nil
    end
  end

  def animspeed=(value)
    @frameskip = value*Graphics.frame_rate/40
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
    end

    @frame += 1
    if @frame>=@frameskip
      @animframe = (@animframe+1)%4
      self.src_rect.x = @animframe*@animbitmap.bitmap.width/4
      @frame -= @frameskip
    end
    @updating = false
  end
end
