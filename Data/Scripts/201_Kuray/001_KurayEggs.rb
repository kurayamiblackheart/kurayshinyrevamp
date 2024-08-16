# ============================
# Kuray's Eggs System
# ============================

$KURAYEGGS_SPARKLING = false
$KURAYEGGS_FORCEDFUSION = 0
$KURAYEGGS_DEBUG = true
$KURAYEGGS_VALIDATE = false
$KURAYEGGS_BASEPRICE = []

module GameData
    def self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)
        egg_name_display_plural = egg_name_display + "s"
        Item.register({
            :id               => egg_symbol,
            :id_number        => id_here,
            :name             => egg_name_display,
            :name_plural      => egg_name_display_plural,
            :pocket           => 1,
            :price            => egg_price,
            :description      => egg_description,
            :field_use        => 2,
            :battle_use       => 0,
            :type             => 0,
            :move             => nil
        })
        MessageTypes.set(MessageTypes::Items,            id_here, egg_name_display)
        MessageTypes.set(MessageTypes::ItemPlurals,      id_here, egg_name_display_plural)
        MessageTypes.set(MessageTypes::ItemDescriptions, id_here, egg_description)
        
        ItemHandlers::UseInField.add(egg_symbol, proc { |item|
            next kurayeggs_triggereggitem(id_here-2000, item)
        })
    end

    def self.kurayeggs_processsymb(egg_name)
        egg_symbol = "KURAYEGG_" + egg_name.upcase
        egg_symbol = egg_symbol.to_sym
        return egg_symbol
    end


    def self.kurayeggs_loadsystem()
        id_here = 1999

        eggs_baseprice = 5000
        egg_name_last = "K-Egg"

        id_here += 1
        egg_price = eggs_baseprice*3
        egg_name = "Random"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        id_here += 1
        egg_price = eggs_baseprice*6
        egg_name = "Sparkling"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 40x shiny odds."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        all_types = ["Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark", "Fairy"]
        for type in all_types
            id_here += 1
            egg_price = eggs_baseprice*4
            egg_name = type
            egg_symbol = self.kurayeggs_processsymb(egg_name)
            egg_name_display = egg_name + " " + egg_name_last
            egg_description = "Egg with " + type.upcase + "-type Pokémon. 10x shiny odds."
            $KURAYEGGS_BASEPRICE.push(egg_price)
            self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)
        end

        id_here += 1
        egg_price = eggs_baseprice*4
        egg_name = "Fusion"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds. Fusion guaranteed."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        id_here += 1
        egg_price = eggs_baseprice*2
        egg_name = "Base"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds. Non-fused guaranteed."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)
    end
end

def kurayeggs_typelookup(type, list_name)
    # This function creates the list_name key for the dictionnary KURAYEGGS_LISTS. It iterates through all the base Pokemons.
    # It adds to the list any base Pokemon that has the typing as type1 or type2, the first value is the symbol of the Pokemon, the second value is the catch rate.
    # Example: [:CHARIZARD, 20]
    
    $KURAYEGGS_LISTS[list_name] = []
    for i in 1..NB_POKEMON
        species = GameData::Species.get(i)
        if species.type1 == type || species.type2 == type
            $KURAYEGGS_LISTS[list_name].push([species.id, species.catch_rate])
        end
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

def kurayeggs_randomlookup()
    $KURAYEGGS_LISTS["Random"] = []
    for i in 1..NB_POKEMON
      species = GameData::Species.get(i)
      $KURAYEGGS_LISTS["Random"].push([species.id, species.catch_rate])
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

$KURAYEGGS_LISTS = {}

def kurayeggs_main()
    return
    # puts "WIP - Kuray's Eggs System"
    # kurayeggs_effectfromid(0)
    # kurayeggs_effectfromid(5)
    # selected_mon = kurayeggs_choose(0, "Fire")
    # kurayeggs_random()
end

def kurayeggs_triggereggitem(id, itemid)
    # This function is used to trigger the egg item effect based on its ID.
    # The effect is determined by the ID of the egg item.
    found_pokemon = false
    pbUseItemMessage(itemid)
    # Try 20 times to get a valid Pokemon.
    for i in 1..20
        puts "Attempt #{i}" if $KURAYEGGS_DEBUG
        selected_mon = kurayeggs_effectfromid(id)
        $KURAYEGGS_SPARKLING = false
        $KURAYEGGS_FORCEDFUSION = 0
        # 0 = No forcing
        # 1 = Forced Base (non-fusion)
        # 2 = Forced Fusion
        if id == 1
            $KURAYEGGS_SPARKLING = true
        end
        if id == 20
            $KURAYEGGS_FORCEDFUSION = 2
        elsif id == 21
            $KURAYEGGS_FORCEDFUSION = 1
        end

        if $PokemonSystem.kurayeggs_fusionodds != nil && $KURAYEGGS_FORCEDFUSION != 1 && $PokemonSystem.kurayeggs_fusionodds > 0
            # Use the fusion odds to determine if we get a second pokemon.
            if rand(1..100) <= $PokemonSystem.kurayeggs_fusionodds
                $KURAYEGGS_FORCEDFUSION = 2
            end
        end
        # Do we get a second pokemon? (for fusion)
        if $KURAYEGGS_FORCEDFUSION == 2
            # Do the pokemon have to come from the same egg pool or a random pool?
            if $PokemonSystem.kurayeggs_fusionpool != nil && $PokemonSystem.kurayeggs_fusionpool == 1
                selected_mon2 = kurayeggs_effectfromid(id)
            else
                selected_mon2 = kurayeggs_choose(1, "Random")
            end
        end
        # Give the pokemon to the player

        if $KURAYEGGS_FORCEDFUSION == 2
            # 50% chance that the first pokemon is the body and the second is the head.
            if rand(1..100) <= 50
                head_symb = selected_mon2
                body_symb = selected_mon
            else
                head_symb = selected_mon
                body_symb = selected_mon2
            end
            pokemon_id = getFusedPokemonIdFromSymbols(body_symb, head_symb)
            kurayegg_pokemon = Pokemon.new(pokemon_id,1)
            # kurayegg_specie = GameData::FusedSpecies.new(pokemon_id)
            # newid = (pokemon.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number

            # kurayegg_newspecie = GameData::Species.get(pokemon_id)
            # kurayegg_pokemon = Pokemon.new(body_symb,1)
            # kurayegg_pokemon.species = kurayegg_newspecie
        else
            kurayegg_pokemon = Pokemon.new(selected_mon,1)
        end
        # Check if the pokemon is valid
        require_typing = false
        k_typing = nil
        case id
        when 2
            k_typing = :NORMAL
        when 3
            k_typing = :FIGHTING
        when 4
            k_typing = :FLYING
        when 5
            k_typing = :POISON
        when 6
            k_typing = :GROUND
        when 7
            k_typing = :ROCK
        when 8
            k_typing = :BUG
        when 9
            k_typing = :GHOST
        when 10
            k_typing = :STEEL
        when 11
            k_typing = :FIRE
        when 12
            k_typing = :WATER
        when 13
            k_typing = :GRASS
        when 14
            k_typing = :ELECTRIC
        when 15
            k_typing = :PSYCHIC
        when 16
            k_typing = :ICE
        when 17
            k_typing = :DRAGON
        when 18
            k_typing = :DARK
        when 19
            k_typing = :FAIRY
        end
        if k_typing != nil
            require_typing = true
        end

        $KURAYEGGS_VALIDATE = false
        if require_typing
            if kurayegg_pokemon.type1 != nil
                if kurayegg_pokemon.type1 == k_typing
                    $KURAYEGGS_VALIDATE = true
                end
            end
            if kurayegg_pokemon.type2 != nil
                if kurayegg_pokemon.type2 == k_typing
                    $KURAYEGGS_VALIDATE = true
                end
            end
        else
            $KURAYEGGS_VALIDATE = true
        end
        if $KURAYEGGS_VALIDATE
            found_pokemon = true
            break
        else
            next
        end
    end
    if !found_pokemon
        puts "No valid Pokémon found." if $KURAYEGGS_DEBUG
    end
    if $PokemonSystem.kurayeggs_instanthatch != nil && $PokemonSystem.kurayeggs_instanthatch == 1
        kurayegg_pokemon.name           = _INTL("Egg")
        kurayegg_pokemon.steps_to_hatch = kurayegg_pokemon.species_data.hatch_steps
        kurayegg_pokemon.hatched_map    = 0
        kurayegg_pokemon.obtain_method  = 1
    end
    egg_shiny_odds = $PokemonSystem.shinyodds*10
    if $KURAYEGGS_SPARKLING
        egg_shiny_odds = egg_shiny_odds*4
    end
    if rand(65536) < egg_shiny_odds
        kurayegg_pokemon.shiny = true
    end
    kurayegg_pokemon.time_form_set = nil
    kurayegg_pokemon.form          = 0 if kurayegg_pokemon.isSpecies?(:SHAYMIN)
    kurayegg_pokemon.heal
    # Check where we can place the pokemon
    if $Trainer.party_full?
        # If the player's party is full, the Pokémon is sent to storage.
        pbStorePokemon(kurayegg_pokemon)
    else
        # If the player's party isn't full, the Pokémon is added to the party.
        pbAddToParty(kurayegg_pokemon)
    end
    return 3
end

def kurayeggs_effectfromid(id)
    # This function is used to determine the effect of the egg based on its ID.
    # Normal Egg have Shiny Odds divided by 10
    case id
    when 0
        # Random Egg
        selected_mon = kurayeggs_choose(1, "Random")
    when 1
        # Sparkling Egg (Shiny Odds divided by 40)
        selected_mon = kurayeggs_choose(1, "Random")
    when 2
        # Normal Egg
        selected_mon = kurayeggs_choose(0, "Normal")
    when 3
        # Fighting Egg
        selected_mon = kurayeggs_choose(0, "Fighting")
    when 4
        # Flying Egg
        selected_mon = kurayeggs_choose(0, "Flying")
    when 5
        # Poison Egg
        selected_mon = kurayeggs_choose(0, "Poison")
    when 6
        # Ground Egg
        selected_mon = kurayeggs_choose(0, "Ground")
    when 7
        # Rock Egg
        selected_mon = kurayeggs_choose(0, "Rock")
    when 8
        # Bug Egg
        selected_mon = kurayeggs_choose(0, "Bug")
    when 9
        # Ghost Egg
        selected_mon = kurayeggs_choose(0, "Ghost")
    when 10
        # Steel Egg
        selected_mon = kurayeggs_choose(0, "Steel")
    when 11
        # Fire Egg
        selected_mon = kurayeggs_choose(0, "Fire")
    when 12
        # Water Egg
        selected_mon = kurayeggs_choose(0, "Water")
    when 13
        # Grass Egg
        selected_mon = kurayeggs_choose(0, "Grass")
    when 14
        # Electric Egg
        selected_mon = kurayeggs_choose(0, "Electric")
    when 15
        # Psychic Egg
        selected_mon = kurayeggs_choose(0, "Psychic")
    when 16
        # Ice Egg
        selected_mon = kurayeggs_choose(0, "Ice")
    when 17
        # Dragon Egg
        selected_mon = kurayeggs_choose(0, "Dragon")
    when 18
        # Dark Egg
        selected_mon = kurayeggs_choose(0, "Dark")
    when 19
        # Fairy Egg
        selected_mon = kurayeggs_choose(0, "Fairy")
    when 20
        # Fusion Egg (forced to be a fusion)
        selected_mon = kurayeggs_choose(1, "Random")
    when 21
        # Base Egg (cannot be a fusion)
        selected_mon = kurayeggs_choose(1, "Random")
    end
    return selected_mon
end

def kurayeggs_createmon(eggsymbol)
    # This function creates the Pokémon based on the symbol given.
    # It creates the Pokémon at level 1 as an egg.
    return
end

def kurayeggs_choose(kmode, type)
    # kmode 0 is a typing egg.
    if kmode == 0 || kmode == 1
        # We create the possible symbol by using the type name in uppercase and transforming it into a symbol name.
        if !$KURAYEGGS_LISTS.has_key?(type)
            if kmode == 1
                kurayeggs_randomlookup()
            else
                kurayeggs_typelookup(type.upcase.to_sym, type)
            end
        end
    end
    # We use the array chooser function
    # puts type.inspect if $KURAYEGGS_DEBUG
    # puts $KURAYEGGS_LISTS[type].inspect if $KURAYEGGS_DEBUG
    selected_mon = kurayeggs_arraychooser($KURAYEGGS_LISTS[type])
    puts "Selected Pokémon: #{selected_mon}" if $KURAYEGGS_DEBUG
    return selected_mon
    # kurayeggs_createmon(selected_mon)
end

def kurayeggs_arraychooser(organizedarray)
    if $PokemonSystem.kurayeggs_rarity != nil && $PokemonSystem.kurayeggs_rarity == 1
        # treats all weights as 1
        total_weight = organizedarray.size
        random_weight = rand(total_weight)

        return organizedarray[random_weight][0] # Return a randomly selected symbol
    else
        # Calculate the total weight
        total_weight = organizedarray.inject(0) { |sum, item| sum + item[1] }

        # Generate a random number between 0 and total_weight
        random_weight = rand(total_weight)

        # Iterate over the list to find the selected item
        current_weight = 0
        organizedarray.each do |item|
            current_weight += item[1]
            if random_weight < current_weight
                return item[0]  # Return the symbol (e.g., :CHARIZARD)
            end
        end
    end
end

# def kurayeggs_random()
#     # This choose a random pokemon using their catch_rate as a weight.
#     # The lower the catch rate of the pokemon, the lower the chance of being chosen in the random egg.
#     catch_rates = []
#     for i in 1..NB_POKEMON
#       species = GameData::Species.get(i)
#       catch_rates.push(species.catch_rate)
#     end
    
#     # Debug - Shows the catch_rates array in the console
#     # puts catch_rates.inspect
    
#     # Calculate the total weight
#     total_weight = catch_rates.sum
    
#     # Generate a random number between 0 and total_weight
#     random_weight = rand(0...total_weight)
    
#     # Iterate over the catch_rates to find the chosen index
#     chosen_index = nil
#     current_weight = 0
    
#     catch_rates.each_with_index do |weight, index|
#       current_weight += weight
#       if random_weight < current_weight
#         chosen_index = index + 1  # Since Pokémon indices are 1-based
#         break
#       end
#     end
    
#     # Debug - Shows the chosen_index in the console, with the catch_rate value it had.
#     puts "Chosen index: #{chosen_index} with catch rate: #{catch_rates[chosen_index - 1]}"
# end