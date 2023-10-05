################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Trapstarr - Make all trainer pokemon shiny
Events.onTrainerPartyLoad += proc { |_sender, e|
  foeParty = []
  trainer = e[0]
  party = e[2]

  if $PokemonSystem.shiny_trainer_pkmn == 1
    # Determine the ace pokemon
    last_pokemon = trainer.party.last
    highest_level_pokemon = trainer.party.max_by { |p| p.level }
    ace_pokemon = highest_level_pokemon

    # If the last pokemon's level is >= highest level pokemon, it's the ace
    if last_pokemon.level >= highest_level_pokemon.level
      ace_pokemon = last_pokemon
    end

    # Set the ace pokemon as shiny
    ace_pokemon.shiny = true
    ace_pokemon.debug_shiny = true
  elsif $PokemonSystem.shiny_trainer_pkmn == 2
    # Set the entire trainers party as shiny
    trainer.party.each do |pokemon|
      foeParty.push(pokemon)
      pokemon.shiny = true
      pokemon.debug_shiny = true
    end
  end
}

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
    pokemon.debug_shiny=true
  end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_map.map_id == 51
    new_level = pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pokemon.level = new_level
    pokemon.calc_stats
    pokemon.reset_moves
  end
}

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#Events.onTrainerPartyLoad += proc { |_sender, trainer|
#  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#    YOUR CODE HERE
#  end
#}
