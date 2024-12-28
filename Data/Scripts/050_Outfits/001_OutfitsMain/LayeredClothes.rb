def find_last_outfit(outfit_type_path, firstOutfit)
  for i in firstOutfit..Settings::MAX_NB_OUTFITS
    outfit_path = outfit_type_path + "/" + i.to_s #Settings::PLAYER_GRAPHICS_FOLDER + outfit_type_path + "/" + outfit_type_path + "_" + player_sprite + "_" + i.to_s
    return i - 1 if !Dir.exist?(outfit_path)
  end
  return firstOutfit
end

def list_all_numeric_folders(directory_path)
  entries = Dir.entries(directory_path)
  # Filter out only the directories whose names are numeric (excluding "." and "..")
  numeric_folders = entries.select do |entry|
    full_path = File.join(directory_path, entry)
    File.directory?(full_path) && entry != '.' && entry != '..' && entry.match?(/^\d+$/)
  end

  # Convert the folder names to integers and store in an array
  folder_integers = numeric_folders.map(&:to_i)
  folder_integers.sort!
  return folder_integers
end

def list_all_numeric_files_with_filter(directory_path, prefix)
  entries = Dir.entries(directory_path)
  prefixless = []
  for file in entries
    next if file == "." || file == ".."
    prefixless << file.gsub((prefix + "_"), "")
  end

  folder_integers = prefixless.map(&:to_i)
  folder_integers.sort!
  return folder_integers
end

#unlocked:
# -1 for all outfits unlocked
# Otherwise, an array of the ids of unlocked outfits
def list_available_outfits(directory, versions = [], unlocked = [], prefix_filter = nil)
  if prefix_filter
    outfits = list_all_numeric_files_with_filter(directory, prefix_filter)
  else
    outfits = list_all_numeric_folders(directory)
  end
  # #echoln outfits
  # return outfits  #todo: remove this return for unlockable outfits
  available_outfits = []
  for outfit in outfits
    if !unlocked || unlocked.include?(outfit)
      for version in versions
        available_outfits << outfit.to_s + version
      end
      available_outfits << outfit.to_s if versions.empty?
    end
  end
  return available_outfits
end

def get_current_outfit_position(currentOutfit_id, available_outfits)
  current_index = available_outfits.index(currentOutfit_id)
  return current_index.nil? ? 0 : current_index
end

def setHairColor(hue_shift)
  $Trainer.hair_color = hue_shift
end

def shiftHatColor(incr)
  $Trainer.hat_color = 0 if !$Trainer.hat_color
  $Trainer.hat_color += incr
end

def shiftClothesColor(incr)
  $Trainer.clothes_color = 0 if !$Trainer.clothes_color
  $Trainer.clothes_color += incr
end

def shiftHairColor(incr)
  $Trainer.hair_color = 0 if !$Trainer.hair_color
  $Trainer.hair_color += incr
end

def pbLoadOutfitBitmap(outfitFileName)
  begin
    outfitBitmap = RPG::Cache.load_bitmap("", outfitFileName)
    return outfitBitmap
  rescue
    return nil
  end
end

def setOutfit(outfit_id)
  $Trainer.clothes = outfit_id
end

def setHat(hat_id)
  $Trainer.hat = hat_id
end

def getEasterEggHeldItem()
  map = $game_map.map_id
  return "HOTDOG" if [141, 194].include?(map) #restaurant
  return "SNOWBALL" if [670, 693, 698, 694].include?(map)
  return "WALLET" if [432, 433, 434, 435, 436, 292].include?(map) #dept. store
  return "ALARMCLOCK" if [43, 48, 67, 68, 69, 70, 71, 73].include?(map) #Player room
  return "SAFARIBALL" if [445, 484, 485, 486, 107, 487, 488, 717, 82, 75, 74].include?(map) #Safari Zone

  return nil
end

def getCurrentPokeball()
  otherItem = getEasterEggHeldItem()
  return otherItem if otherItem
  firstPokemon = $Trainer.party[0]
  return firstPokemon.poke_ball if firstPokemon
  return nil
end

def generate_front_trainer_sprite_bitmap(pokeball = nil, clothes_id = nil, hat_id = nil, hair_id = nil,
                                         skin_tone_id = nil, hair_color = nil, hat_color = nil, clothes_color = nil)
  clothes_id = $Trainer.clothes if !clothes_id
  hat_id = $Trainer.hat if !hat_id
  hair_id = $Trainer.hair if !hair_id
  skin_tone_id = $Trainer.skin_tone if !skin_tone_id
  hair_color = $Trainer.hair_color if !hair_color
  hat_color = $Trainer.hat_color if !hat_color
  clothes_color = $Trainer.clothes_color if !clothes_color

  hairFilename = getTrainerSpriteHairFilename(hair_id) #_INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_HAIR_FOLDER + "/hair_trainer_{1}", $Trainer.hair)
  outfitFilename = getTrainerSpriteOutfitFilename(clothes_id) #_INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_CLOTHES_FOLDER + "/clothes_trainer_{1}", $Trainer.clothes)

  hatFilename = getTrainerSpriteHatFilename(hat_id) # _INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_HAT_FOLDER + "/hat_trainer_{1}", $Trainer.hat)
  pokeball = getCurrentPokeball if !pokeball
  ballFilename = getTrainerSpriteBallFilename(pokeball) if pokeball

  baseFilePath = getBaseTrainerSpriteFilename(skin_tone_id)

  hair_color_shift = hair_color
  hat_color_shift = hat_color
  clothes_color_shift = clothes_color

  hair_color_shift = 0 if !hair_color_shift
  hat_color_shift = 0 if !hat_color_shift
  clothes_color_shift = 0 if !clothes_color_shift

  baseBitmap = AnimatedBitmap.new(baseFilePath) if pbResolveBitmap(baseFilePath)
  ballBitmap = pbLoadOutfitBitmap(ballFilename) if pbResolveBitmap(ballFilename)

  if !pbResolveBitmap(outfitFilename)
    outfitFilename = getTrainerSpriteOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK)
  end
  if !pbResolveBitmap(outfitFilename)
    raise "No temp clothes graphics available"
  end

  outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift) # if pbResolveBitmap(outfitFilename) #pb
  hairBitmapWrapper = AnimatedBitmap.new(hairFilename, hair_color_shift) if pbResolveBitmap(hairFilename)

  hatBitmap = AnimatedBitmap.new(hatFilename, hat_color_shift) if pbResolveBitmap(hatFilename) #pbLoadOutfitBitmap(hatFilename) if pbResolveBitmap(hatFilename)

  baseBitmap.bitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect) if outfitBitmap

  baseBitmap.bitmap.blt(0, 0, hairBitmapWrapper.bitmap, hairBitmapWrapper.bitmap.rect) if hairBitmapWrapper
  baseBitmap.bitmap.blt(0, 0, hatBitmap.bitmap, hatBitmap.bitmap.rect) if hatBitmap
  baseBitmap.bitmap.blt(44, 42, ballBitmap, ballBitmap.rect) if ballBitmap

  return baseBitmap
end

def generateClothedBitmapStatic(trainer, action = "walk")
  baseBitmapFilename = getBaseOverworldSpriteFilename(action, trainer.skin_tone)
  if !pbResolveBitmap(baseBitmapFilename)
    baseBitmapFilename = Settings::PLAYER_GRAPHICS_FOLDER + action
  end
  baseSprite = AnimatedBitmap.new(baseBitmapFilename)

  baseBitmap = baseSprite.bitmap.clone #nekkid sprite
  outfitFilename = getOverworldOutfitFilename(trainer.clothes, action) #
  outfitFilename = getOverworldOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK) if !pbResolveBitmap(outfitFilename)
  hairFilename = getOverworldHairFilename(trainer.hair)
  hatFilename = getOverworldHatFilename(trainer.hat)

  hair_color_shift = trainer.hair_color
  hat_color_shift = trainer.hat_color
  clothes_color_shift = trainer.clothes_color

  hair_color_shift = 0 if !hair_color_shift
  hat_color_shift = 0 if !hat_color_shift
  clothes_color_shift = 0 if !clothes_color_shift
  #@hat.update(@character_name, hatFilename,hat_color_shift) if @hat
  if !pbResolveBitmap(outfitFilename)
    outfitFilename = Settings::PLAYER_TEMP_OUTFIT_FALLBACK
  end

  outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift) # if pbResolveBitmap(outfitFilename) #pbLoadOutfitBitmap(outfitFilename) if pbResolveBitmap(outfitFilename)
  hairBitmapWrapper = AnimatedBitmap.new(hairFilename, hair_color_shift) if pbResolveBitmap(hairFilename)

  baseBitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect) if outfitBitmap

  #baseBitmap.blt(0, 0, hairBitmapWrapper.bitmap, hairBitmapWrapper.bitmap.rect)

  current_offset = 0 #getCurrentSpriteOffset()
  positionHair(baseBitmap, hairBitmapWrapper.bitmap, current_offset) if hairBitmapWrapper
  #baseBitmap.blt(0, 0, hatBitmap, hatBitmap.rect) if hatBitmap
  return baseBitmap
end

def positionHair(baseBitmap, hairBirmap, offset)
  baseBitmap.blt(offset[0], offset[1], hairBirmap, hairBirmap.rect)
end

def add_hat_to_bitmap(bitmap, hat_id, x_pos, y_pos, scale = 1, mirrored = false)
  base_scale = 1.5 #coz hat & poke sprites aren't the same size
  adjusted_scale = base_scale * scale
  hat_filename = getTrainerSpriteHatFilename(hat_id)
  hatBitmapWrapper = AnimatedBitmap.new(hat_filename, 0) if pbResolveBitmap(hat_filename)
  hatBitmapWrapper.scale_bitmap(adjusted_scale) if hatBitmapWrapper
  hatBitmapWrapper.mirror if hatBitmapWrapper && mirrored
  bitmap.blt(x_pos * adjusted_scale, y_pos * adjusted_scale, hatBitmapWrapper.bitmap, hatBitmapWrapper.bitmap.rect) if hatBitmapWrapper
end

class PokemonTemp
  attr_accessor :trainer_preview
end

def display_outfit_preview(x = 320, y = 0, withBorder = true)
  hide_outfit_preview() if $PokemonTemp.trainer_preview
  $PokemonTemp.trainer_preview = TrainerClothesPreview.new(x, y, withBorder)
  $PokemonTemp.trainer_preview.show()
end

def hide_outfit_preview()
  $game_screen.pictures[20].erase
  $PokemonTemp.trainer_preview.erase() if $PokemonTemp.trainer_preview
  $PokemonTemp.trainer_preview = nil
end






