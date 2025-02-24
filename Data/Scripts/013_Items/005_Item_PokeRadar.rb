class PokemonGlobalMetadata
  attr_accessor :pokeradarBattery
end

class PokemonTemp
  attr_accessor :pokeradar # [species, level, chain count, grasses (x,y,ring,rarity)]
  attr_accessor :pokeradar_ui # [species, level, chain count, grasses (x,y,ring,rarity)]

end

################################################################################
# Using the Poke Radar
################################################################################
def pbCanUsePokeRadar?
  # Can't use Radar if not in tall grass
  terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  # if !terrain.land_wild_encounters || !terrain.shows_grass_rustle
  #   pbMessage(_INTL("Can't use that here."))
  #   return false
  # end
  if $PokemonEncounters.encounter_type == nil
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  # Can't use Radar if map has no grass-based encounters (ignoring Bug Contest)
  # if !$PokemonEncounters.has_normal_land_encounters?
  #   pbMessage(_INTL("Can't use that here."))
  #   return false
  # end
  # Can't use Radar while cycling
  # if $PokemonGlobal.bicycle
  #   pbMessage(_INTL("Can't use that while on a bicycle."))
  #   return false
  # end
  # Debug
  return true if $DEBUG && Input.press?(Input::CTRL)
  # Can't use Radar if it isn't fully charged
  if $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery > 0
    pbMessage(_INTL("The battery has run dry!\nFor it to recharge, you need to walk another {1} steps.",
                    $PokemonGlobal.pokeradarBattery))
    return false
  end
  return true
end

def pbUsePokeRadar
  return false if !pbCanUsePokeRadar?
  $PokemonGlobal.repel = 2 if $PokemonGlobal.repel < 2 # autorepel
  $PokemonTemp.pokeradar = [0, 0, 0, []] if !$PokemonTemp.pokeradar
  $PokemonGlobal.pokeradarBattery = Settings::POKERADAR_BATTERY_STEPS
  unseenPokemon = listPokemonInCurrentRoute($PokemonEncounters.encounter_type, false, true)
  seenPokemon = listPokemonInCurrentRoute($PokemonEncounters.encounter_type, true, false)

  rareAllowed = canEncounterRarePokemon(unseenPokemon)
  displayPokeradarBanner(seenPokemon, unseenPokemon, rareAllowed)
  playPokeradarLightAnimation(rareAllowed)
  pbWait(20)
  pbPokeRadarHighlightGrass
  return true
end

def listPokeradarRareEncounters()
  map = $game_map.map_id
  array = []
  Settings::POKE_RADAR_ENCOUNTERS.each do |enc|
    if enc[0] == map
      species = enc[2]
      array.push(species)
    end
  end
  return array
end

# #can only encounter rare if have seen every encounterable land pokemon on the route
# def canEncounterRarePokemon()
#   processed = []
#   for encounter in $PokemonEncounters.listPossibleEncounters($PokemonEncounters.pbEncounterType)
#     species = encounter[0]
#     if !processed.include?(species)
#       if $Trainer.seen[species]
#         processed << species
#       else
#         return false
#       end
#     end
#   end
#   return true
# end

def playPokeradarLightAnimation(rareAllowed = false)
  if rareAllowed
    $scene.spriteset.addUserAnimation(Settings::POKERADAR_LIGHT_ANIMATION_GREEN_ID, $game_player.x, $game_player.y, true)
  else
    $scene.spriteset.addUserAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, $game_player.x, $game_player.y, true)
  end
end

def displayPokeradarBanner(seenPokemon = [], unseenPokemon = [], includeRare = false)
  return if $PokemonTemp.pokeradar_ui != nil
  rarePokemon = includeRare ? listPokeradarRareEncounters() : []
  $PokemonTemp.pokeradar_ui = PokeRadar_UI.new(seenPokemon, unseenPokemon, rarePokemon)
end

def pbPokeRadarCancel
  if $PokemonTemp.pokeradar_ui != nil
    $PokemonTemp.pokeradar_ui.dispose
    $PokemonTemp.pokeradar_ui = nil
  end
  if $PokemonTemp.pokeradar != nil && $PokemonGlobal.repel <= 2
    $PokemonGlobal.repel = 0
  end
  $PokemonTemp.pokeradar = nil
end



def listPokemonInCurrentRoute(encounterType, onlySeen = false, onlyUnseen = false)
  return [] if encounterType == nil
  processed = []
  seen = []
  unseen = []
  for encounter in $PokemonEncounters.listPossibleEncounters(encounterType)
    species = $game_switches[SWITCH_RANDOM_WILD] && !$game_switches[SWITCH_RANDOM_WILD_AREA] ? getRandomizedTo(encounter[1]) : encounter[1]
    if species.is_a?(Integer)
      species = GameData::Species.get(species).id
    end

    if !processed.include?(species)
      if $Trainer.seen?(species)
        seen << species
        processed << species
      else
        unseen << species
        processed << species
      end
    end
  end
  if onlySeen
    return seen
  elsif onlyUnseen
    return unseen
  else
    return processed
  end
end

#can only encounter rare if have seen every encounterable land pokemon on the route
def canEncounterRarePokemon(unseenPokemon)
  terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  return unseenPokemon.length == 0 &&
    $PokemonEncounters.has_normal_land_encounters? &&
    terrain.land_wild_encounters &&
    terrain.shows_grass_rustle
end

def pbPokeRadarHighlightGrass(showmessage = true)
  if $PokemonSystem.pokeradarplus > 0
    pbMessage(_INTL("Chain count: {1}\\wtnp[10]", $PokemonTemp.pokeradar[2]))
  end
  grasses = [] # x, y, ring (0-3 inner to outer), rarity§
  # Choose 1 random tile from each ring around the player
  for i in 0...4
    r = rand((i + 1) * 8)
    # Get coordinates of randomly chosen tile
    x = $game_player.x
    y = $game_player.y
    if r <= (i + 1) * 2
      x = $game_player.x - i - 1 + r
      y = $game_player.y - i - 1
    elsif r <= (i + 1) * 6 - 2
      x = [$game_player.x + i + 1, $game_player.x - i - 1][r % 2]
      y = $game_player.y - i + ((r - 1 - (i + 1) * 2) / 2).floor
    else
      x = $game_player.x - i + r - (i + 1) * 6
      y = $game_player.y + i + 1
    end
    # Add tile to grasses array if it's a valid grass tile
    if x >= 0 && x < $game_map.width &&
      y >= 0 && y < $game_map.height
      terrain = $game_map.terrain_tag(x, y)
      if terrain.land_wild_encounters && terrain.shows_grass_rustle
        # Choose a rarity for the grass (0=normal, 1=rare, 2=shiny)
        s = (rand(100) < 25) ? 1 : 0
        if $PokemonTemp.pokeradar && $PokemonTemp.pokeradar[2] > 0
          $PokemonSystem.shinyodds = 1 if $PokemonSystem.shinyodds < 1
          v = [(65536 / $PokemonSystem.shinyodds) - $PokemonTemp.pokeradar[2] * 200, 200].max
          # v = [(65536 / Settings::SHINY_POKEMON_CHANCE) - $PokemonTemp.pokeradar[2] * 200, 200].max
          v = 0xFFFF / v
          v = rand(65536) / v
          s = 2 if v == 0
        end
        grasses.push([x, y, i, s])
      end
    end
  end
  if grasses.length == 0
    # No shaking grass found, break the chain
    if $PokemonSystem.pokeradarplus > 0
      pbMessage(_INTL("Nothing happened...\nPokeRadar+ saved the chain!"))
    else
      pbMessage(_INTL("Nothing happened...")) if showmessage
      pbPokeRadarCancel
    end
  else
    # Show grass rustling animations
    for grass in grasses
      case grass[3]
      when 0 # Normal rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_NORMAL_ANIMATION_ID, grass[0], grass[1], true, 1)
      when 1 # Vigorous rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_VIGOROUS_ANIMATION_ID, grass[0], grass[1], true, 1)
      when 2 # Shiny rustle
        $scene.spriteset.addUserAnimation(Settings::RUSTLE_SHINY_ANIMATION_ID, grass[0], grass[1], true, 1)
      end
    end
    $PokemonTemp.pokeradar[3] = grasses if $PokemonTemp.pokeradar
    pbWait(Graphics.frame_rate / 2)
  end
end

def pbPokeRadarGetShakingGrass
  return -1 if !$PokemonTemp.pokeradar
  grasses = $PokemonTemp.pokeradar[3]
  return -1 if grasses.length == 0
  for i in grasses
    return i[2] if $game_player.x == i[0] && $game_player.y == i[1]
  end
  return -1
end

def pbPokeRadarOnShakingGrass
  return pbPokeRadarGetShakingGrass >= 0
end

def pbPokeRadarGetEncounter(rarity = 0)
  # Poké Radar-exclusive encounters can only be found in vigorously-shaking grass
  if rarity > 0
    # Get all Poké Radar-exclusive encounters for this map
    map = $game_map.map_id
    array = []
    Settings::POKE_RADAR_ENCOUNTERS.each do |enc|
      array.push(enc) if enc[0] == map && GameData::Species.exists?(enc[2])
    end
    # If there are any exclusives, first have a chance of encountering those
    if array.length > 0 && listPokemonInCurrentRoute($PokemonEncounters.encounter_type, false, true).length==0
      rnd = rand(100)
      array.each do |enc|
        rnd -= enc[1]
        next if rnd >= 0
        level = (enc[4] && enc[4] > enc[3]) ? rand(enc[3]..enc[4]) : enc[3]
        return [enc[2], level]
      end
    end
  end
  # Didn't choose a Poké Radar-exclusive species, choose a regular encounter instead
  encounter = $PokemonEncounters.choose_wild_pokemon($PokemonEncounters.encounter_type, rarity + 1)
  if $game_switches[SWITCH_RANDOM_WILD] && $game_switches[SWITCH_WILD_RANDOM_GLOBAL]
    encounter[0] = getRandomizedTo(encounter[0])
  end
  return encounter
end

################################################################################
# Event handlers
################################################################################
EncounterModifier.register(proc { |encounter|
  if GameData::EncounterType.get($PokemonTemp.encounterType).type != :land ||
    $PokemonGlobal.partner # $PokemonGlobal.bicycle || $PokemonGlobal.partner
    pbPokeRadarCancel
    next encounter
  end
  ring = pbPokeRadarGetShakingGrass
  if ring >= 0 # Encounter triggered by stepping into rustling grass
    # Get rarity of shaking grass
    rarity = 0 # 0 = rustle, 1 = vigorous rustle, 2 = shiny rustle
    $PokemonTemp.pokeradar[3].each { |g| rarity = g[3] if g[2] == ring }
    if $PokemonTemp.pokeradar[2] > 0 # Chain count, i.e. is chaining
      if rarity == 2 || rand(100) < 86 + ring * 4 + ($PokemonTemp.pokeradar[2] / 4).floor || $PokemonSystem.pokeradarplus > 0
        # Continue the chain
        encounter = [$PokemonTemp.pokeradar[0], $PokemonTemp.pokeradar[1]]
        $PokemonTemp.forceSingleBattle = true
      else
        # Break the chain, force an encounter with a different species
        100.times do
          break if encounter && encounter[0] != $PokemonTemp.pokeradar[0]
          encounter = $PokemonEncounters.choose_wild_pokemon($PokemonEncounters.encounter_type)
        end
        pbPokeRadarCancel
      end
    else
      # Not chaining; will start one
      # Force random wild encounter, vigorous shaking means rarer species
      encounter = pbPokeRadarGetEncounter(rarity)
      $PokemonTemp.forceSingleBattle = true
    end
  else
    # Encounter triggered by stepping in non-rustling grass
    pbPokeRadarCancel if encounter  && $PokemonGlobal.repel <= 0
  end
  next encounter
})

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  next if !$PokemonTemp.pokeradar
  grasses = $PokemonTemp.pokeradar[3]
  next if !grasses
  for grass in grasses
    next if $game_player.x != grass[0] || $game_player.y != grass[1]
    pokemon.shiny = true if grass[3] == 2
    break
  end
}

Events.onWildBattleEnd += proc { |_sender, e|
  species = e[0]
  level = e[1]
  decision = e[2]
  if $PokemonTemp.pokeradar && (decision == 1 || decision == 4) # Defeated/caught
    $PokemonTemp.pokeradar[0] = species
    $PokemonTemp.pokeradar[1] = level
    $PokemonTemp.pokeradar[2] += 1
    $PokemonTemp.pokeradar[2] = 40 if $PokemonTemp.pokeradar[2] > 40
    pbPokeRadarHighlightGrass(false)
  else
    pbPokeRadarCancel
  end
}

Events.onStepTaken += proc { |_sender, _e|
  echoln("Repel: #{$PokemonGlobal.repel}")
  if $PokemonTemp.pokeradar # autorepel
    $PokemonGlobal.repel += 1
  end
  if $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery > 0 &&
    !$PokemonTemp.pokeradar
    $PokemonGlobal.pokeradarBattery -= 1
  end
  terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  if !terrain.land_wild_encounters || !terrain.shows_grass_rustle
    pbPokeRadarCancel
  end
}

Events.onMapChange += proc { |_sender, _e|
  pbPokeRadarCancel
}

################################################################################
# Item handlers
################################################################################
ItemHandlers::UseInField.add(:POKERADAR, proc { |item|
  next (pbCanUsePokeRadar?) ? pbUsePokeRadar : 0
})

ItemHandlers::UseFromBag.add(:POKERADAR, proc { |item|
  next (pbCanUsePokeRadar?) ? 2 : 0
})


