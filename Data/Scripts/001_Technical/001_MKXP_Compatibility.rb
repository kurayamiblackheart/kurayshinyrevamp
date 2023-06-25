# Using mkxp-z v2.2.0 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.2.0
$VERBOSE = nil
$POTENTIALSPRITES = {}
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
  # System.set_window_title(System.game_title + " | Kuray's Shiny Revamp | Speed: x1")
end

##### Kuray's Global Functions #####

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

def kurayGetCustomNonFusion(dex_number)
  #Settings::CUSTOM_BASE_SPRITES_FOLDER
  $POTENTIALSPRITES = {} if !$POTENTIALSPRITES
  $POTENTIALSPRITES[dex_number] = [] if !$POTENTIALSPRITES[dex_number]
  # usinglocation = "Graphics/Base Sprites/"
  usinglocation = "Graphics/KuraySprites/"
  if $POTENTIALSPRITES[dex_number].empty?
    # Only keep files that correspond to the actual pokemon
    # Dir.foreach(Settings::CUSTOM_BASE_SPRITES_FOLDER + dex_number.to_s + "*") do |filename|
    files = Dir[usinglocation + dex_number.to_s + "*.png"]
    files.each do |filename|
      next if filename == '.' or filename == '..'
      next if !filename.end_with?(".png")
      dexname = File.basename(filename).split('.png')[0]
      checknumber = dexname.gsub(/[^\d]/, '')
      next if checknumber.to_i != dex_number
      $POTENTIALSPRITES[dex_number].append(filename)
    end
    # Choose randomly from the array
    if !$POTENTIALSPRITES[dex_number].empty?
      return $POTENTIALSPRITES[dex_number].sample
    else
      return nil
    end
  else
    # Choose randomly from the array
    if !$POTENTIALSPRITES[dex_number].empty?
      return $POTENTIALSPRITES[dex_number].sample
    else
      return nil
    end
  end
  return nil
end


def kurayGetCustomTripleFusion(dex_number)
  #Unused as of right now
  #getSpecialSpriteName needs to be public
end

def kurayGetCustomDoubleFusion(dex_number, head_id, body_id)
  #Settings::CUSTOM_BATTLERS_FOLDER_INDEXED
  $POTENTIALSPRITES = {} if !$POTENTIALSPRITES
  $POTENTIALSPRITES[dex_number] = [] if !$POTENTIALSPRITES[dex_number]
  usinglocation = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/"
  if $POTENTIALSPRITES[dex_number].empty?
    # Only keep files that correspond to the actual pokemon
    files = Dir[usinglocation + head_id.to_s + "." + body_id.to_s + "*.png"]
    files.each do |filename|
      next if filename == '.' or filename == '..'
      next if !filename.end_with?(".png")
      next if filename.end_with?("_i.png")
      dexname = File.basename(filename).split('.png')[0]
      checknumber = dexname.gsub(/[^\d.]/, '')
      next if checknumber.to_s != head_id.to_s + "." + body_id.to_s
      $POTENTIALSPRITES[dex_number].append(filename)
    end
    # Choose randomly from the array
    if !$POTENTIALSPRITES[dex_number].empty?
      return $POTENTIALSPRITES[dex_number].sample
    else
      return nil
    end
  else
    # Choose randomly from the array
    if !$POTENTIALSPRITES[dex_number].empty?
      return $POTENTIALSPRITES[dex_number].sample
    else
      return nil
    end
  end
  return nil
end

# KurayX Allow to have multiple pokemons uses different sprites, generate sprite from filename for the Pokemon.
def kurayGetCustomSprite(dex_number)
  return nil if dex_number == nil
  if dex_number <= Settings::NB_POKEMON
    #Check for non fusions
    kuraychose = kurayGetCustomNonFusion(dex_number)
    return nil if kuraychose == nil
    return kuraychose
  else
    if dex_number >= Settings::ZAPMOLCUNO_NB
      # kuraychose = kurayGetCustomTripleFusion(dex_number)
      return nil
      # Check for triple fusions
      # specialPath = getSpecialSpriteName(dex_number)
      # return pbResolveBitmap(specialPath)
      # head_id=nil
    else
      # Check for double fusion
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      kuraychose = kurayGetCustomDoubleFusion(dex_number, head_id, body_id)
      return nil if kuraychose == nil
      return kuraychose
    end
  end
  return nil
end

##### END OF Kuray's Global Functions #####

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
