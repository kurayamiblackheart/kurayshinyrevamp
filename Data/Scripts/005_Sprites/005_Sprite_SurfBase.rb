class Sprite_SurfBase
  attr_reader :visible
  attr_accessor :event

  def initialize(sprite, event, viewport = nil)
    @rsprite = sprite
    @sprite = nil
    @event = event
    @viewport = viewport
    @disposed = false
    #@surfbitmap = AnimatedBitmap.new("Graphics/Characters/base_surf")
    @surfbitmap = update_surf_bitmap(:SURF)
    @divebitmap = update_surf_bitmap(:DIVE)
    # RPG::Cache.retain("Graphics/Characters/base_surf")
    # RPG::Cache.retain("Graphics/Characters/base_dive")
    @cws = @surfbitmap.width / 4
    @chs = @surfbitmap.height / 4
    @cwd = @divebitmap.width / 4
    @chd = @divebitmap.height / 4
    update
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite = nil
    @surfbitmap.dispose
    @divebitmap.dispose
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update_surf_bitmap(type)
    species = $Trainer.surfing_pokemon
    path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_board" if type == :SURF
    #path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_scuba" if type == :DIVE
    path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_Head" if type == :DIVE
    if species
      shape = species.shape
      basePath = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER
      action = "divemon" if type == :DIVE
      action = "surfmon" if type == :SURF
      path = "#{basePath}#{action}_#{shape.to_s}"
    end
    return AnimatedBitmap.new(path)
  end


      # case species.shape
      # when :Head
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_Head" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_Head" if type == :SURF
      # when :Serpentine
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Finned
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :HeadArms
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :HeadBase
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :BipedalTail
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :HeadLegs
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Quadruped
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Winged
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Multiped
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :MultiBody
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Bipedal
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :MultiWinged
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # when :Insectoid
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_HeadBase" if type == :DIVE
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "surfmon_HeadBase" if type == :SURF
      # else
      #   path = Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_SURFBASE_FOLDER + "divemon_01"
      # end


  def update
    return if disposed?
    if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    if @sprite
      if $PokemonGlobal.surfing
        @surfbitmap = update_surf_bitmap(:SURF)
        @sprite.bitmap = @surfbitmap.bitmap
        cw = @cws
        ch = @chs
      elsif $PokemonGlobal.diving
        @divebitmap = update_surf_bitmap(:DIVE)
        @sprite.bitmap = @divebitmap.bitmap
        cw = @cwd
        ch = @chd
      end
      sx = @event.pattern_surf * cw
      sy = ((@event.direction - 2) / 2) * ch
      @sprite.src_rect.set(sx, sy, cw, ch)
      if $PokemonTemp.surfJump
        @sprite.x = ($PokemonTemp.surfJump[0] * Game_Map::REAL_RES_X - @event.map.display_x + 3) / 4 + (Game_Map::TILE_WIDTH / 2)
        @sprite.y = ($PokemonTemp.surfJump[1] * Game_Map::REAL_RES_Y - @event.map.display_y + 3) / 4 + (Game_Map::TILE_HEIGHT / 2) + 16
      else
        @sprite.x = @rsprite.x
        @sprite.y = @rsprite.y
      end
      @sprite.ox = cw / 2
      @sprite.oy = ch - 16 # Assume base needs offsetting
      @sprite.oy -= @event.bob_height
      @sprite.z = @event.screen_z(ch) - 1
      @sprite.zoom_x = @rsprite.zoom_x
      @sprite.zoom_y = @rsprite.zoom_y
      @sprite.tone = @rsprite.tone
      @sprite.color = @rsprite.color
      @sprite.opacity = @rsprite.opacity
    end
  end
end
