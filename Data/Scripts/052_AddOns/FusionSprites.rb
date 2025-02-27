module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil, makeShiny = true)
      species = pkmn.species if !species
      species = GameData::Species.get(species).id_number # Just to be sure it's a number
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        #KurayX - KURAYX_ABOUT_SHINIES
        if makeShiny
          ret = self.back_sprite_bitmap(species, pkmn.spriteform_body, pkmn.spriteform_head, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?,pkmn.shinyValue?,pkmn.shinyR?,pkmn.shinyG?,pkmn.shinyB?,pkmn.shinyKRS?,pkmn.kuraycustomfile?)
        else
          ret = self.back_sprite_bitmap(species, pkmn.spriteform_body, pkmn.spriteform_head, false, false, false)
        end
      else
        #KurayX - KURAYX_ABOUT_SHINIES
        if makeShiny
          ret = self.front_sprite_bitmap(species, nil, nil, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?,pkmn.shinyValue?,pkmn.shinyR?,pkmn.shinyG?,pkmn.shinyB?,pkmn.shinyKRS?,pkmn.kuraycustomfile?)
        else
          ret = self.front_sprite_bitmap(species, nil, nil, false, false, false)
        end
      end
      ret.scale_bitmap(pkmn.sprite_scale) #for pokemon with size differences
      return ret
    end

    #KurayX - KURAYX_ABOUT_SHINIES
    def self.sprite_bitmap_from_pokemon_id(id, back = false, shiny=false, bodyShiny=false,headShiny=false, pokeHue = 0, pokeR = 0, pokeG = 1, pokeB = 2, cusFile=nil)
      if back
        ret = self.back_sprite_bitmap(id,nil,nil,shiny,bodyShiny,headShiny,pokeHue,pokeR,pokeG,pokeB,cusFile)
      else
        ret = self.front_sprite_bitmap(id,nil,nil,shiny,bodyShiny,headShiny,pokeHue,pokeR,pokeG,pokeB,cusFile)
      end
      return ret
    end

    MAX_SHIFT_VALUE = 360
    MINIMUM_OFFSET=40
    ADDITIONAL_OFFSET_WHEN_TOO_CLOSE=40
    MINIMUM_DEX_DIF=20

    #KurayBringingBack
    def self.calculateShinyHueOffset(dex_number, isBodyShiny = false, isHeadShiny = false)
      if dex_number <= NB_POKEMON
        if SHINY_COLOR_OFFSETS[dex_number]
          return SHINY_COLOR_OFFSETS[dex_number]
        end
        body_number = dex_number
        head_number=dex_number

        else
        body_number = getBodyID(dex_number)
        head_number=getHeadID(dex_number,body_number)
      end
      if isBodyShiny && isHeadShiny && SHINY_COLOR_OFFSETS[body_number]  && SHINY_COLOR_OFFSETS[head_number]
        offset = SHINY_COLOR_OFFSETS[body_number] + SHINY_COLOR_OFFSETS[head_number]
      elsif isHeadShiny && SHINY_COLOR_OFFSETS[head_number]
        offset = SHINY_COLOR_OFFSETS[head_number]
      elsif isBodyShiny && SHINY_COLOR_OFFSETS[body_number]
        offset = SHINY_COLOR_OFFSETS[body_number]
      else
        offset = calculateShinyHueOffsetDefaultMethod(body_number,head_number,dex_number,isBodyShiny,isHeadShiny)
      end
      return offset
    end

    #KurayBringingBack
    def self.calculateShinyHueOffsetDefaultMethod(body_number,head_number,dex_number, isBodyShiny = false, isHeadShiny = false)
      dex_offset = dex_number
      #body_number = getBodyID(dex_number)
      #head_number=getHeadID(dex_number,body_number)
      dex_diff = (body_number-head_number).abs
      if isBodyShiny && isHeadShiny
        dex_offset = dex_number
      elsif isHeadShiny
        dex_offset = head_number
      elsif isBodyShiny
        dex_offset = dex_diff > MINIMUM_DEX_DIF ? body_number : body_number+ADDITIONAL_OFFSET_WHEN_TOO_CLOSE
      end
      offset = dex_offset + Settings::SHINY_HUE_OFFSET
      offset /= MAX_SHIFT_VALUE if offset > NB_POKEMON
      offset = MINIMUM_OFFSET if offset < MINIMUM_OFFSET
      offset = MINIMUM_OFFSET if (MAX_SHIFT_VALUE - offset).abs < MINIMUM_OFFSET
      offset += pbGet(VAR_SHINY_HUE_OFFSET) #for testing - always 0 during normal gameplay
      return offset
    end

    #KurayX - KURAYX_ABOUT_SHINIES
    #KuraSprite
    def self.front_sprite_bitmap(dex_number, spriteform_body = nil, spriteform_head = nil, isShiny = false, bodyShiny = false, headShiny = false, shinyValue = 0, shinyR = 0, shinyG = 1, shinyB = 2, shinyKRS=[0, 0, 0, 0, 0, 0, 0, 0, 0],cusFile=nil)
      spriteform_body = nil# if spriteform_body == 0
      spriteform_head = nil# if spriteform_head == 0
      #TODO Remove spriteform mechanic entirely

      #la méthode est utilisé ailleurs avec d'autres arguments (gender, form, etc.) mais on les veut pas
      if dex_number.is_a?(Symbol)
        dex_number = GameData::Species.get(dex_number).id_number
      end
      if cusFile == nil
        filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
      else
        if pbResolveBitmap(cusFile) && (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
          filename = cusFile
        else
          filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
        end
      end
      sprite = (filename) ? AnimatedBitmap.new(filename).recognizeDims() : nil
      if isShiny
        # sprite.shiftColors(colorshifting)
        #KurayBringBackOldShinies
        if $PokemonSystem.kuraynormalshiny == 1
          sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
        else
          sprite.pbGiveFinaleColor(shinyR, shinyG, shinyB, shinyValue, shinyKRS)
        end
      end
      return sprite
    end

    #KurayX - KURAYX_ABOUT_SHINIES
    #KuraSprite
    def self.back_sprite_bitmap(dex_number, spriteform_body = nil, spriteform_head = nil, isShiny = false, bodyShiny = false, headShiny = false, shinyValue = 0, shinyR = 0, shinyG = 1, shinyB = 2, shinyKRS=[0, 0, 0, 0, 0, 0, 0, 0, 0], cusFile=nil)
      if cusFile == nil
        filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
      else
        if pbResolveBitmap(cusFile) && (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
          filename = cusFile
        else
          filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
        end
      end
      sprite = (filename) ? AnimatedBitmap.new(filename).recognizeDims() : nil
      if isShiny
        # sprite.shiftColors(colorshifting)
        #KurayBringBackOldShinies
        if $PokemonSystem.kuraynormalshiny == 1
          sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
        else
          sprite.pbGiveFinaleColor(shinyR, shinyG, shinyB, shinyValue, shinyKRS)
        end
      end
      return sprite
    end

    def self.egg_sprite_bitmap(dex_number, form = nil)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    #KurayX - KURAYX_ABOUT_SHINIES
    def self.sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false, shinyValue = 0, shinyR = 0, shinyG = 1, shinyB = 2, shinyKRS=[0, 0, 0, 0, 0, 0, 0, 0, 0], cusFile=nil)
      return self.egg_sprite_bitmap(species, form) if egg
      return self.back_sprite_bitmap(species, form, gender, shiny, shadow, shinyValue, shinyR, shinyG, shinyB, shinyKRS, cusFile) if back
      return self.front_sprite_bitmap(species, form, gender, shiny, shadow, shinyValue, shinyR, shinyG, shinyB, shinyKRS, cusFile)
    end

    def self.getSpecialSpriteName(dexNum)
      return kuray_global_triples(dexNum)
    end

    def self.sprite_filename(dex_number, spriteform_body = nil, spriteform_head = nil)
      
      #dex_number = GameData::NAT_DEX_MAPPING[dex_number] ? GameData::NAT_DEX_MAPPING[dex_number] : dex_number
      if dex_number.is_a?(GameData::Species)
        dex_number = dex_number.id_number
      end
      if dex_number.is_a?(Symbol)
        dex_number = getDexNumberForSpecies(dex_number)
      end
      return nil if dex_number == nil
      if dex_number <= Settings::NB_POKEMON
        return get_unfused_sprite_path(dex_number, spriteform_body)
      else
        if dex_number >= Settings::ZAPMOLCUNO_NB
          specialPath = getSpecialSpriteName(dex_number)
          # Check if specialPath exists as a .png
          if !pbResolveBitmap(specialPath)
            specialPath = sprintf("Graphics/Battlers/special/000")
          end
          return pbResolveBitmap(specialPath)
          head_id=nil
        else
          body_id = getBodyID(dex_number)
          head_id = getHeadID(dex_number, body_id)
          return get_fusion_sprite_path(head_id, body_id, spriteform_body, spriteform_head)
          # folder = head_id.to_s
          # filename = sprintf("%s.%s.png", head_id, body_id)
        end
      end
      # customPath = pbResolveBitmap(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + "/" + head_id.to_s + "/" +filename)
      # customPath = download_custom_sprite(head_id,body_id)
      #
      # species = getSpecies(dex_number)
      # use_custom = customPath && !species.always_use_generated
      # if use_custom
      #   return customPath
      # end
      # #return Settings::BATTLERS_FOLDER + folder + "/" + filename
      # return download_autogen_sprite(head_id,body_id)
    end

  end
end


def get_unfused_sprite_path(dex_number_id, spriteform = nil)
  dex_number = dex_number_id.to_s
  spriteform_letter = spriteform ? "_" + spriteform.to_s : ""
  folder = dex_number.to_s
  substitution_id = _INTL("{1}{2}", dex_number, spriteform_letter)

  if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(substitution_id)
    substitutionPath = $PokemonGlobal.alt_sprite_substitutions[substitution_id]
    return substitutionPath if pbResolveBitmap(substitutionPath)
  end
  random_alt = get_random_alt_letter_for_unfused(dex_number, true) #nil if no main
  random_alt = "" if !random_alt

  filename = _INTL("{1}{2}{3}.png", dex_number, spriteform_letter,random_alt)
  path = Settings::CUSTOM_BASE_SPRITES_FOLDER + filename

  if pbResolveBitmap(path)
    record_sprite_substitution(substitution_id,path)
    return path
  end
  downloaded_path = download_unfused_main_sprite(dex_number, random_alt)
  if pbResolveBitmap(downloaded_path)
    record_sprite_substitution(substitution_id,downloaded_path)
    return downloaded_path
  end
  fallback_filename = _INTL("{1}{2}.png", dex_number, spriteform_letter)
  return Settings::BATTLERS_FOLDER + folder + spriteform_letter + "/" + fallback_filename
end

def alt_sprites_substitutions_available
  return $PokemonGlobal && $PokemonGlobal.alt_sprite_substitutions
end

def print_stack_trace
  stack_trace = caller
  stack_trace.each_with_index do |call, index|
    echo("#{index + 1}: #{call}")
  end
end

def record_sprite_substitution(substitution_id, sprite_name)
  return if !$PokemonGlobal
  return if !$PokemonGlobal.alt_sprite_substitutions
  $PokemonGlobal.alt_sprite_substitutions[substitution_id] = sprite_name
end

def add_to_autogen_cache(pokemon_id, sprite_name)
  return if !$PokemonGlobal
  return if !$PokemonGlobal.autogen_sprites_cache
  $PokemonGlobal.autogen_sprites_cache[pokemon_id]=sprite_name
end

class PokemonGlobalMetadata
  attr_accessor :autogen_sprites_cache
end

#To force a specific sprites before a battle
#
#  ex:
# $PokemonTemp.forced_alt_sprites={"20.25" => "20.25a"}
#
class PokemonTemp
  attr_accessor :forced_alt_sprites
end

#todo: refactor into smaller methods
def get_fusion_sprite_path(head_id, body_id, spriteform_body = nil, spriteform_head = nil)
  $PokemonGlobal.autogen_sprites_cache = {} if $PokemonGlobal && !$PokemonGlobal.autogen_sprites_cache
  #Todo: ça va chier si on fusionne une forme d'un pokemon avec une autre forme, mais pas un problème pour tout de suite
  form_suffix = ""
  form_suffix += "_" + spriteform_body.to_s if spriteform_body
  form_suffix += "_" + spriteform_head.to_s if spriteform_head

  #Swap path if alt is selected for this pokemon
  dex_num = getSpeciesIdForFusion(head_id, body_id)
  substitution_id = dex_num.to_s + form_suffix

  if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(substitution_id)
    substitutionPath= $PokemonGlobal.alt_sprite_substitutions[substitution_id]
    return substitutionPath if pbResolveBitmap(substitutionPath)
  end


  spriteform_body_letter = spriteform_body ? "_" + spriteform_body.to_s : ""
  spriteform_head_letter = spriteform_head ? "_" + spriteform_head.to_s : ""

  pokemon_name = _INTL("{1}{2}.{3}{4}",head_id, spriteform_head_letter, body_id, spriteform_body_letter)


  #get altSprite letter
  #random_alt = get_random_alt_letter_for_custom(head_id, body_id) #nil if no main
  random_alt = PokedexUtils.pbGetAvailableAlts(dex_num).sample.match(/[a-z]+(?=.png)/i)
  random_alt = "" if !random_alt
  forcingSprite=false
  if $PokemonTemp.forced_alt_sprites && $PokemonTemp.forced_alt_sprites.key?(pokemon_name)
    random_alt = $PokemonTemp.forced_alt_sprites[pokemon_name]
    forcingSprite=true
  end


  filename = _INTL("{1}{2}.png", pokemon_name, random_alt)
  #Try local custom sprite
  local_custom_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + spriteform_head_letter + "/" + filename
  if pbResolveBitmap(local_custom_path)
    record_sprite_substitution(substitution_id, local_custom_path) if !forcingSprite
    return local_custom_path
  end
  #if the game has loaded an autogen earlier, no point in trying to redownload, so load that instead
  return $PokemonGlobal.autogen_sprites_cache[substitution_id] if  $PokemonGlobal && $PokemonGlobal.autogen_sprites_cache[substitution_id]

  #Try to download custom sprite if none found locally
  downloaded_custom = download_custom_sprite(head_id, body_id, spriteform_body_letter, spriteform_head_letter, random_alt)
  if downloaded_custom
    record_sprite_substitution(substitution_id, downloaded_custom) if !forcingSprite
    return downloaded_custom
  end

  #Try local generated sprite
  local_generated_path = Settings::BATTLERS_FOLDER + head_id.to_s + spriteform_head_letter + "/" + pokemon_name + ".png"
  if pbResolveBitmap(local_generated_path)
    add_to_autogen_cache(substitution_id,local_generated_path)
    return local_generated_path
  end

  #Download generated sprite if nothing else found
  autogen_path = download_autogen_sprite(head_id, body_id,spriteform_body,spriteform_head)
  if pbResolveBitmap(autogen_path)
    add_to_autogen_cache(substitution_id,autogen_path)
    return autogen_path
  end

  return Settings::DEFAULT_SPRITE_PATH
end

# def get_fusion_sprite_path(head_id, body_id, spriteform_body = nil, spriteform_head = nil)
#   $PokemonGlobal.autogen_sprites_cache = {} if $PokemonGlobal && !$PokemonGlobal.autogen_sprites_cache
#   #Todo: ça va chier si on fusionne une forme d'un pokemon avec une autre forme, mais pas un problème pour tout de suite
#   form_suffix = ""
#   form_suffix += "_" + spriteform_body.to_s if spriteform_body
#   form_suffix += "_" + spriteform_head.to_s if spriteform_head

#   #Swap path if alt is selected for this pokemon
#   dex_num = getSpeciesIdForFusion(head_id, body_id)
#   substitution_id = dex_num.to_s + form_suffix


#   if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(substitution_id)
#     substitutionPath= $PokemonGlobal.alt_sprite_substitutions[substitution_id]
#     return substitutionPath if pbResolveBitmap(substitutionPath)
#   end

#   random_alt = get_random_alt_letter_for_custom(head_id, body_id) #nil if no main
#   random_alt = "" if !random_alt
#   #if the game has loaded an autogen earlier, no point in trying to redownload, so load that instead
#   return $PokemonGlobal.autogen_sprites_cache[substitution_id] if  $PokemonGlobal && $PokemonGlobal.autogen_sprites_cache[substitution_id]

#   #Try local custom sprite
#   spriteform_body_letter = spriteform_body ? "_" + spriteform_body.to_s : ""
#   spriteform_head_letter = spriteform_head ? "_" + spriteform_head.to_s : ""

#   filename = _INTL("{1}{2}.{3}{4}{5}.png", head_id, spriteform_head_letter, body_id, spriteform_body_letter, random_alt)
#   local_custom_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + spriteform_head_letter + "/" + filename
#   if pbResolveBitmap(local_custom_path)
#     record_sprite_substitution(substitution_id, local_custom_path)
#     return local_custom_path
#   end
#   #Try to download custom sprite if none found locally
#   downloaded_custom = download_custom_sprite(head_id, body_id, spriteform_body_letter, spriteform_head_letter, random_alt)
#   if downloaded_custom
#     record_sprite_substitution(substitution_id, downloaded_custom)
#     return downloaded_custom
#   end

#   #Try local generated sprite
#   local_generated_path = Settings::BATTLERS_FOLDER + head_id.to_s + spriteform_head_letter + "/" + filename
#   if pbResolveBitmap(local_generated_path)
#     add_to_autogen_cache(substitution_id,local_generated_path)
#     return local_generated_path
#   end

#   #Download generated sprite if nothing else found
#   # autogen_path = download_autogen_sprite(head_id, body_id)
#   autogen_path = download_autogen_sprite(head_id, body_id,spriteform_body,spriteform_head)
#   if pbResolveBitmap(autogen_path)
#     add_to_autogen_cache(substitution_id,autogen_path)
#     return autogen_path
#   end

#   return Settings::DEFAULT_SPRITE_PATH
# end

def get_random_alt_letter_for_custom(head_id, body_id, onlyMain = true)
  spriteName = _INTL("{1}.{2}", head_id, body_id)
  if onlyMain
    return list_main_sprites_letters(spriteName).sample
  else
    return list_all_sprites_letters(spriteName).sample
  end
end

def get_random_alt_letter_for_unfused(dex_num, onlyMain = true)
  spriteName = _INTL("{1}", dex_num)
  if onlyMain
    letters_list= list_main_sprites_letters(spriteName)
  else
    letters_list= list_all_sprites_letters(spriteName)
  end
  letters_list << ""  #add main sprite
  return letters_list.sample
end

def list_main_sprites_letters(spriteName)
  all_sprites = map_alt_sprite_letters_for_pokemon(spriteName)
  main_sprites = []
  all_sprites.each do |key, value|
    main_sprites << key if value == "main"
  end
  
  #add temp sprites if no main sprites found
  if main_sprites.empty?
    all_sprites.each do |key, value|
      main_sprites << key if value == "temp"
    end
  end
  return main_sprites
end

def list_all_sprites_letters(spriteName)
  all_sprites_map = map_alt_sprite_letters_for_pokemon(spriteName)
  letters = []
  all_sprites_map.each do |key, value|
    letters << key
  end
  return letters
end

def list_alt_sprite_letters(spriteName)
  all_sprites = map_alt_sprite_letters_for_pokemon(spriteName)
  alt_sprites = []
  all_sprites.each do |key, value|
    alt_sprites << key if value == "alt"
  end
end



def map_alt_sprite_letters_for_pokemon(spriteName)
  alt_sprites = {}
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    sprite_name = row[0]
    if sprite_name.start_with?(spriteName)
      if sprite_name.length > spriteName.length #alt letter
        letter = sprite_name[spriteName.length]
        if letter.match?(/[a-zA-Z]/)
          main_or_alt = row[2] ? row[2] : nil
          alt_sprites[letter] = main_or_alt
        end
      else  #letterless
      main_or_alt = row[2] ? row[2] : nil
      alt_sprites[""] = main_or_alt
      end
    end
  end
  return alt_sprites
end