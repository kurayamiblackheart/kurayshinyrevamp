# Using mkxp-z v2.2.0 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.2.0
$VERBOSE = nil
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
  # System.set_window_title(System.game_title + " | Kuray's Shiny Revamp | Speed: x1")
end

def kurayRNGforChannels
  kurayRNG = rand(0..10000)
  if kurayRNG < 5
    return rand(0..11)
  elsif kurayRNG < 41
    return rand(0..8)
  elsif kurayRNG < 2041
    return rand(0..5)
  else
    return rand(0..2)
  end
  # 0.04% chance to have an inverse magenta/yellow/cyan
  # 0.4% chance to have an inverse (4/1000*100)
  # 4% chance to have Cyan/Magenta/Yellow (40/1000*100)
  # change Cyan/Magenta/Yellow to 20%
end

class Bitmap
  attr_accessor :storedPath

  alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

  def draw_text(x, y, width, height, text, align = 0)
    height = text_size(text).height
    mkxp_draw_text(x, y, width, height, text, align)
  end
end

module Graphics
  def self.delta_s
    return self.delta.to_f / 1_000_000
  end
end

def pbSetResizeFactor(factor)
  if !$ResizeInitialized
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    $ResizeInitialized = true
  end
  if factor < 0 || factor == 4
    Graphics.fullscreen = true if !Graphics.fullscreen
  else
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = (factor + 1) * 0.5
    Graphics.center
  end
end
