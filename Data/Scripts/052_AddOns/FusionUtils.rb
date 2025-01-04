def is_fusion_of_any(species_id, pokemonList)
  is_species = false
  for fusionPokemon in pokemonList
    if is_fusion_of(species_id, fusionPokemon)
      is_species = true
    end
  end
  return is_species
end

def is_fusion_of(checked_species, checked_against)
  return species_has_body_of(checked_species, checked_against) || species_has_head_of(checked_species, checked_against)
end

def is_species(checked_species, checked_against)
  return checked_species == checked_against
end

def species_has_body_of(checked_species, checked_against)
  if !species_is_fusion(checked_species)
    return is_species(checked_species, checked_against)
  end
  bodySpecies = get_body_species_from_symbol(checked_species)
  ret = bodySpecies == checked_against
  #echoln _INTL("{1} HAS BODY OF {2} : {3} (body is {4})",checked_species,checked_against,ret,bodySpecies)
  return ret
end

def species_has_head_of(checked_species, checked_against)
  if !species_is_fusion(checked_species)
    return is_species(checked_species, checked_against)
  end
  headSpecies = get_head_species_from_symbol(checked_species)
  ret = headSpecies == checked_against
  #echoln _INTL("{1} HAS HEAD OF {2} : {3}",checked_species,checked_against,ret)
  return ret
end

def species_is_fusion(species_id)
  dex_number = get_dex_number(species_id)
  return dex_number > NB_POKEMON && dex_number < Settings::ZAPMOLCUNO_NB
end

def get_dex_number(species_id)
  return GameData::Species.get(species_id).id_number
end

def getBodyID(species)
  if species.is_a?(Integer)
    dexNum = species
  else
    dexNum = getDexNumberForSpecies(species)
  end
  if dexNum % NB_POKEMON == 0
    return (dexNum / NB_POKEMON) - 1
  end
  return (dexNum / NB_POKEMON).round
end

def getHeadID(species, bodyId = nil)
  if species.is_a?(Integer)
    fused_dexNum = species
  else
    fused_dexNum = getDexNumberForSpecies(species)
  end

  if bodyId == nil
    bodyId = getBodyID(species)
  end
  body_dexNum = getDexNumberForSpecies(bodyId)

  calculated_number = (fused_dexNum - (body_dexNum * NB_POKEMON)).round
  return calculated_number == 0 ? NB_POKEMON : calculated_number
end