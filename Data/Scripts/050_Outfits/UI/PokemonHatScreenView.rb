class PokemonHatView
  WINDOW_POS_X = Graphics.width / 4
  WINDOW_POS_Y = Graphics.height / 8

  attr_accessor :x_pos
  attr_accessor :y_pos

  def initialize(x_pos = nil, y_pos = nil, windowed = true)
    @x_pos = x_pos ? x_pos : WINDOW_POS_X
    @y_pos = y_pos ? y_pos : WINDOW_POS_Y
    @windowed = windowed

  end

  def init_window(presenter)
    @presenter = presenter


    presenter.initialize_bitmap()
    pokemon_bitmap = presenter.getPokemonHatBitmap()

    @previewwindow = PictureWindow.new(pokemon_bitmap)
    @previewwindow.opacity = 0 if !@windowed
    update_window_position()
    @previewwindow.z = 9999999

    @viewport = Viewport.new(@previewwindow.x, @previewwindow.y, @previewwindow.width, @previewwindow.height)
    @viewport.z = 9999999
    @sprites = {}

    initialize_arrows()

  end

  def getWindowWidth()
    return @previewwindow.width/2
  end

  def initialize_arrows()
    middle_horizontal = 100
    width_horizontal = 90

    middle_vertical = 100
    width_vertical = 90

    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = middle_horizontal
    @sprites["uparrow"].y = middle_vertical - width_vertical
    @sprites["uparrow"].z = 100
    @sprites["uparrow"].visible=true


    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = middle_horizontal
    @sprites["downarrow"].y = middle_vertical + width_vertical

    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = middle_horizontal - width_horizontal -10
    @sprites["leftarrow"].y = middle_vertical


    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = middle_horizontal + width_horizontal
    @sprites["rightarrow"].y = middle_vertical

    @sprites["uparrow"].visible=false
    @sprites["downarrow"].visible=false
    @sprites["leftarrow"].visible=false
    @sprites["rightarrow"].visible=false

  end

  def update_window_position()
    @previewwindow.x = @x_pos
    @previewwindow.y = @y_pos
  end

  #TODO
  def display_select_arrows
    hide_move_arrows
    @sprites["rightarrow"].visible=true
    @sprites["leftarrow"].visible=true

    @sprites["rightarrow"].play
    @sprites["leftarrow"].play
  end

  def hide_select_arrows
    @sprites["rightarrow"].visible=false
    @sprites["leftarrow"].visible=false
    @sprites["rightarrow"].stop
    @sprites["leftarrow"].stop
    @sprites["rightarrow"].reset
    @sprites["leftarrow"].reset
  end

  def display_move_arrows
    hide_move_arrows
    @sprites["rightarrow"].visible=true
    @sprites["leftarrow"].visible=true
    @sprites["uparrow"].visible=true
    @sprites["downarrow"].visible=true

    @sprites["rightarrow"].play
    @sprites["leftarrow"].play
    @sprites["uparrow"].play
    @sprites["downarrow"].play
  end

  def hide_move_arrows
    @sprites["rightarrow"].visible=false
    @sprites["leftarrow"].visible=false
    @sprites["uparrow"].visible=false
    @sprites["downarrow"].visible=false

    @sprites["rightarrow"].stop
    @sprites["leftarrow"].stop
    @sprites["uparrow"].stop
    @sprites["downarrow"].stop
  end

  def dispose_window
    @previewwindow.dispose
    @viewport.dispose
    pbDisposeSpriteHash(@sprites)
    @sprites = nil
  end

  def update
    @sprites["rightarrow"].update
    @sprites["leftarrow"].update
    @sprites["uparrow"].update
    @sprites["downarrow"].update

    @previewwindow.clearBitmaps
    @previewwindow.setBitmap(@presenter.getPokemonHatBitmap())
    @previewwindow.update
  end
end
