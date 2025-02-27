class PokedexUtils
  # POSSIBLE_ALTS = ["", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
  #                  "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah",
  #                  "ai", "aj", "ak", "al", "am", "an", "ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", "ax",
  #                  "ay", "az"]

  def self.getAltLettersList()
    return ('a'..'z').to_a + ('aa'..'az').to_a
  end

  def self.pbGetAvailableAlts(species, form_index = 0)
    if form_index
      form_suffix = form_index <= 0 ? "" : "_" + form_index.to_s
    else
      form_suffix = ""
    end

    ret = []
    return ret if !species
    dexNum = getDexNumberForSpecies(species)
    isFusion = dexNum > NB_POKEMON
    if !isFusion
      unfused_path = Settings::CUSTOM_BASE_SPRITE_FOLDER + dexNum.to_s + form_suffix + ".png"
      if !pbResolveBitmap(unfused_path)
        unfused_path = Settings::BATTLERS_FOLDER + dexNum.to_s + form_suffix + "/" + dexNum.to_s + form_suffix + ".png"
      end
      ret << unfused_path

      getAltLettersList().each { |alt_letter|
        altFilePath = Settings::CUSTOM_BASE_SPRITES_FOLDER + dexNum.to_s + form_suffix + alt_letter + ".png"
        if pbResolveBitmap(altFilePath)
          ret << altFilePath
        end
      }
      return ret
    end
    body_id = getBodyID(species)
    head_id = getHeadID(species, body_id)

    baseFilename = head_id.to_s + "." + body_id.to_s + form_suffix
    baseFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + ".png"
    if pbResolveBitmap(baseFilePath)
      ret << baseFilePath
    end
    getAltLettersList().each { |alt_letter|
      if alt_letter != "" #empty is included in alt letters because unfused sprites can be alts and not have a letter
        altFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + alt_letter + ".png"
        if pbResolveBitmap(altFilePath)
          ret << altFilePath
        end
      end
    }
    ret << Settings::BATTLERS_FOLDER + head_id.to_s + "/" + baseFilename + ".png"
    return ret
  end

  #todo: return array for split evolution lines that have multiple final evos
  def self.getFinalEvolution(species)
    #ex: [[B3H4,Level 32],[B2H5, Level 35]]
    evolution_line = species.get_evolutions
    return species if evolution_line.empty?
    finalEvoId = evolution_line[0][0]
    return evolution_line[]
    for evolution in evolution_line
      evoSpecies = evolution[0]
      p GameData::Species.get(evoSpecies).get_evolutions
      isFinalEvo = GameData::Species.get(evoSpecies).get_evolutions.empty?
      return evoSpecies if isFinalEvo
    end
    return nil
  end

end
