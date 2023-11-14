module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil, makeShiny = true)
      species = pkmn.species if !species
      species = GameData::Species.get(species).id_number # Just to be sure it's a number
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        #KurayX - KURAYX_ABOUT_SHINIES
        if makeShiny
          ret = self.back_sprite_bitmap(species, pkmn.spriteform_body, pkmn.spriteform_head, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?,pkmn.shinyValue?,pkmn.shinyR?,pkmn.shinyG?,pkmn.shinyB?,pkmn.kuraycustomfile?)
        else
          ret = self.back_sprite_bitmap(species, pkmn.spriteform_body, pkmn.spriteform_head, false, false, false)
        end
      else
        #KurayX - KURAYX_ABOUT_SHINIES
        if makeShiny
          ret = self.front_sprite_bitmap(species, nil, nil, pkmn.shiny?,pkmn.bodyShiny?,pkmn.headShiny?,pkmn.shinyValue?,pkmn.shinyR?,pkmn.shinyG?,pkmn.shinyB?,pkmn.kuraycustomfile?)
        else
          ret = self.front_sprite_bitmap(species, nil, nil, false, false, false)
        end
      end
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
    def self.front_sprite_bitmap(dex_number, spriteform_body = nil, spriteform_head = nil, isShiny = false, bodyShiny = false, headShiny = false, shinyValue = 0, shinyR = 0, shinyG = 1, shinyB = 2, cusFile=nil)
      spriteform_body = nil if spriteform_body == 0
      spriteform_head = nil if spriteform_head == 0

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
      sprite = (filename) ? AnimatedBitmap.new(filename) : nil
      if isShiny
        # sprite.shiftColors(colorshifting)
        #KurayBringBackOldShinies
        if $PokemonSystem.kuraynormalshiny == 1
          sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
        else
          sprite.pbGiveFinaleColor(shinyR, shinyG, shinyB, shinyValue)
        end
      end
      return sprite
    end

    #KurayX - KURAYX_ABOUT_SHINIES
    #KuraSprite
    def self.back_sprite_bitmap(dex_number, spriteform_body = nil, spriteform_head = nil, isShiny = false, bodyShiny = false, headShiny = false, shinyValue = 0, shinyR = 0, shinyG = 1, shinyB = 2, cusFile=nil)
      if cusFile == nil
        filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
      else
        if pbResolveBitmap(cusFile) && (!$PokemonSystem.kurayindividcustomsprite || $PokemonSystem.kurayindividcustomsprite == 0)
          filename = cusFile
        else
          filename = self.sprite_filename(dex_number, spriteform_body, spriteform_head)
        end
      end
      sprite = (filename) ? AnimatedBitmap.new(filename) : nil
      if isShiny
        # sprite.shiftColors(colorshifting)
        #KurayBringBackOldShinies
        if $PokemonSystem.kuraynormalshiny == 1
          sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
        else
          sprite.pbGiveFinaleColor(shinyR, shinyG, shinyB, shinyValue)
        end
      end
      return sprite
    end

    def self.egg_sprite_bitmap(dex_number, form = nil)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.getSpecialSpriteName(dexNum)
      base_path = "Graphics/Battlers/special/"
      case dexNum
      when Settings::ZAPMOLCUNO_NB
        return sprintf(base_path + "144.145.146")
      when Settings::ZAPMOLCUNO_NB + 1
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
      when Settings::ZAPMOLCUNO_NB + 25 #cardboard
        return sprintf(base_path +"invisible")
      when Settings::ZAPMOLCUNO_NB + 26 #cardboard
        return sprintf(base_path + "cardboard")
      when Settings::ZAPMOLCUNO_NB + 27 #Triple regi
        return sprintf(base_path + "447.448.449")
      else
        return sprintf(base_path + "000")
      end
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

  normal_path = Settings::BATTLERS_FOLDER + folder + spriteform_letter + "/" + filename
  lightmode_path = Settings::BATTLERS_FOLDER + filename

  path = random_alt == "" ? normal_path : lightmode_path

  if pbResolveBitmap(path)
    record_sprite_substitution(substitution_id,path)
    return path
  end
  downloaded_path = download_unfused_main_sprite(dex_number, random_alt)
  if pbResolveBitmap(downloaded_path)
    record_sprite_substitution(substitution_id,downloaded_path)
    return downloaded_path
  end
  return normal_path
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

def get_fusion_sprite_path(head_id, body_id, spriteform_body = nil, spriteform_head = nil)
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

  random_alt = get_random_alt_letter_for_custom(head_id, body_id) #nil if no main
  random_alt = "" if !random_alt

  #Try local custom sprite
  spriteform_body_letter = spriteform_body ? "_" + spriteform_body.to_s : ""
  spriteform_head_letter = spriteform_head ? "_" + spriteform_head.to_s : ""

  filename = _INTL("{1}{2}.{3}{4}{5}.png", head_id, spriteform_head_letter, body_id, spriteform_body_letter, random_alt)
  local_custom_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + spriteform_head_letter + "/" + filename
  if pbResolveBitmap(local_custom_path)
    record_sprite_substitution(substitution_id, local_custom_path)
    return local_custom_path
  end
  #Try to download custom sprite if none found locally
  downloaded_custom = download_custom_sprite(head_id, body_id, spriteform_body_letter, spriteform_head_letter, random_alt)
  if downloaded_custom
    record_sprite_substitution(substitution_id, downloaded_custom)
    return downloaded_custom
  end

  #Try local generated sprite
  local_generated_path = Settings::BATTLERS_FOLDER + head_id.to_s + spriteform_head_letter + "/" + filename
  return local_generated_path if pbResolveBitmap(local_generated_path)

  #Download generated sprite if nothing else found
  autogen_path = download_autogen_sprite(head_id, body_id)
  return autogen_path if pbResolveBitmap(autogen_path)

  return Settings::DEFAULT_SPRITE_PATH
end

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
    if sprite_name.start_with?(spriteName) && sprite_name.length > spriteName.length
      letter = sprite_name[spriteName.length]
      if letter.match?(/[a-zA-Z]/)
        main_or_alt = row[2] ? row[2] : nil
        alt_sprites[letter] = main_or_alt
      end
    end
  end
  return alt_sprites
end