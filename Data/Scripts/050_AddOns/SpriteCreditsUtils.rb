def map_sprites_by_artist
  creditsMap = Hash.new
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    spritename = row[0]
    if row[1]
      artist = row[1].chomp
      sprites = creditsMap.key?(artist) ? creditsMap[artist] : []
      sprites << spritename
      creditsMap[artist] = sprites
    end
  end
  return creditsMap
end

def get_top_artists(nb_names = 100)
  filename = Settings::CREDITS_FILE_PATH
  name_counts = Hash.new(0)

  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    name_counts[name] += 1
  end

  name_counts.sort_by { |name, count| -count }.to_h
             .first(nb_names)
             .to_h
end

def analyzeSpritesList(spritesList, mostPopularCallbackVariable = 1)
  pokemon_map = Hash.new
  for spritename in spritesList
    splitName = spritename.split(".")
    headNum = splitName[0].to_i
    bodyNum = splitName[1].to_i

    if pokemon_map.key?(headNum)
      pokemon_map[headNum] += 1
    else
      pokemon_map[headNum] = 1
    end

    if pokemon_map.key?(bodyNum)
      pokemon_map[bodyNum] += 1
    else
      pokemon_map[bodyNum] = 1
    end
  end
  most_popular = pokemon_map.max_by { |key, value| value }
  most_popular_poke = most_popular[0]
  most_popular_nb = most_popular[1]

  pbSet(mostPopularCallbackVariable, most_popular_nb)
  species = getSpecies(most_popular_poke)

  return species
end

def getPokemonSpeciesFromSprite(spritename)
  return nil if !spritename
  splitName = spritename.split(".")
  headNum = splitName[0].to_i
  bodyNum = splitName[1].to_i

  #call this to make sure that the sprite is downloaded
  get_fusion_sprite_path(headNum, bodyNum)

  species = getFusionSpecies(bodyNum, headNum)
  return species
end

def doesCurrentExhibitionFeaturePokemon(displayedSprites, pokemon)
  for sprite in displayedSprites
    parts = sprite.split(".")
    headNum = parts[0].to_i
    bodyNum = parts[1].to_i
    return true if headNum == pokemon.id_number || bodyNum == pokemon.id_number
  end
  return false
end

def select_spriter(minNbSprites = 10, save_in_var = 1)
  spriters_list = list_all_spriters_with_min_nb_of_sprites(minNbSprites)
  commands = []
  spriters_list.each do |name, i|
    if name
      commands.push([i, name, name])
    end
  end
  chosen = pbChooseList(commands, 0, nil, 1)
  return nil if !chosen
  return chosen
end

def list_all_spriters_with_min_nb_of_sprites(minNbSprites)
  return list_all_spriters() if !minNbSprites
  filename = Settings::CREDITS_FILE_PATH
  spriters_hash = Hash.new(0)

  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    if name
      spriters_hash[name] += 1
    end
  end

  spriters_list = []
  for spriter_name in spriters_hash.keys
    if spriters_hash[spriter_name] >= minNbSprites
      spriters_list << spriter_name
    end
  end
  return spriters_list
end

def list_all_spriters()
  filename = Settings::CREDITS_FILE_PATH
  names_list = []
  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    if !names_list.include?(name)
      names_list << name
    end
  end
  return names_list
end

def generateCurrentGalleryBattle(level = nil, number_of_pokemon = 3)
  spriter_name = pbGet(259)
  #set highest level in party if nil
  if !level
    level = $Trainer.highest_level_pokemon_in_party
  end
  possible_battlers = []
  for i in 0..5
    sprite = pbGet(VAR_GALLERY_FEATURED_SPRITES)[i]
    species = getPokemonSpeciesFromSprite(sprite)
    possible_battlers << species if species
  end

  selected_battlers_idx = possible_battlers.sample(number_of_pokemon)
  party = []
  selected_battlers_idx.each { |species|00
    party << Pokemon.new(species, level)
  }
  customTrainerBattle(spriter_name,
                      :PAINTER,
                      party,
                      level,
                      pick_spriter_losing_dialog(spriter_name),
                      pick_trainer_sprite(spriter_name)
  )

end

def generateArtGallery(nbSpritesDisplayed = 6, saveArtistNameInVariable = 1, saveSpritesInVariable = 2, saveAllArtistSpritesInVariable = 3, artistName = nil)
  artistName = nil if artistName == 0
  creditsMap = map_sprites_by_artist
  featuredArtist = artistName ? artistName : getRandomSpriteArtist(creditsMap, nbSpritesDisplayed)
  if featuredArtist
    if !creditsMap[featuredArtist]  #try again if issue
      artistName = getRandomSpriteArtist(creditsMap, nbSpritesDisplayed)
      return generateArtGallery(nbSpritesDisplayed,saveSpritesInVariable,saveSpritesInVariable,saveSpritesInVariable,artistName)
    end
    featuredSprites = creditsMap[featuredArtist].shuffle.take(nbSpritesDisplayed)
    pbSet(saveArtistNameInVariable, File.basename(featuredArtist, '#*'))
    pbSet(saveSpritesInVariable, featuredSprites)
    pbSet(saveAllArtistSpritesInVariable, creditsMap[featuredArtist])
    return featuredSprites
  end
  return nil
end

def format_artist_name(full_name)
  return File.basename(full_name, '#*')
end

def getRandomSpriteArtist(creditsMap = nil, minimumNumberOfSprites = 10, giveUpAfterX = 50)
  creditsMap = map_sprites_by_artist if !creditsMap
  i = 0
  while i < giveUpAfterX
    artist = creditsMap.keys.sample
    return artist if creditsMap[artist].length >= minimumNumberOfSprites
  end
  return nil
end

def getSpriteCredits(spriteName)
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    if row[0] == (spriteName)
      return row[1]
    end
  end
  return nil
end

def formatList(list, separator)
  formatted = ""
  i = 0
  for element in list
    formatted << element
    formatted << separator if i < list.length
    i += 1
  end
end

def format_names_for_game_credits()
  spriters_map = get_top_artists(100)
  formatted = ""
  i = 1
  for spriter in spriters_map.keys
    formatted << spriter
    if i % 2 == 0
      formatted << "\n"
    else
      formatted << "<s>"
    end
    i += 1
  end
  return formatted
end
