
alias challende_mode_getTrainersDataMode getTrainersDataMode
def getTrainersDataMode
	mode = challende_mode_getTrainersDataMode
	if $game_switches && $game_switches[850] && 
		($game_map.map_id == 314 ||  # Pokemon League Lobby
			$game_map.map_id == 315 || # Lorelei
			$game_map.map_id == 316 || # Bruno
			$game_map.map_id == 317 || # Agatha
			$game_map.map_id == 318 || # Lance
			$game_map.map_id == 328 || # Champion Room
			$game_map.map_id == 546 || # Vermillion Fight Arena
			$game_map.map_id == 783 || # Mt. Silver Summit (Cynthia)
			$game_map.map_id == 784 )  # Mt. Silver Summit Future (Gold)
		mode = GameData::TrainerChallenge
	end  
	return mode
end

class PokeBattle_Battler

	alias challenge_pbInitPokemon pbInitPokemon
	def pbInitPokemon(pkmn,idxParty)
		challenge_pbInitPokemon(pkmn,idxParty)
		if $game_switches && $game_switches[850] && 
			($game_map.map_id == 314 ||  # Pokemon League Lobby
				$game_map.map_id == 315 || # Lorelei
				$game_map.map_id == 316 || # Bruno
				$game_map.map_id == 317 || # Agatha
				$game_map.map_id == 318 || # Lance
				$game_map.map_id == 328 || # Champion Room
				$game_map.map_id == 546 || # Vermillion Fight Arena
				$game_map.map_id == 783 || # Mt. Silver Summit (Cynthia)
				$game_map.map_id == 784 )  # Mt. Silver Summit Future (Gold)
		    @moves.each { |move| move.pp*=2 } if !pbOwnedByPlayer?
		end	
	end

end

class PokeBattle_Battle
	
	alias challende_mode_pbEORSwitch pbEORSwitch
	def pbEORSwitch(favorDraws = false)
		@switchStyle=false if $game_switches[850] && trainerBattle?
		challende_mode_pbEORSwitch(favorDraws)
	end	
	
	alias challende_mode_pbItemMenu pbItemMenu
	def pbItemMenu(idxBattler,firstAction)
		if $game_switches[850] && trainerBattle?
		  pbDisplay(_INTL("Items can't be used in this challenge."))
		  return false
		end	
		challende_mode_pbItemMenu(idxBattler,firstAction)
	end	

  alias challende_mode_setBattleMode setBattleMode
  def setBattleMode(mode)
    # default = $game_variables[VAR_DEFAULT_BATTLE_TYPE].is_a?(Array) ? $game_variables[VAR_DEFAULT_BATTLE_TYPE] : [1, 1]
    #KurayX patching battles
	if $game_switches && $game_switches[850] && 
		($game_map.map_id == 314 ||  # Pokemon League Lobby
			$game_map.map_id == 315 || # Lorelei
			$game_map.map_id == 316 || # Bruno
			$game_map.map_id == 317 || # Agatha
			$game_map.map_id == 318 || # Lance
			$game_map.map_id == 328 || # Champion Room
			$game_map.map_id == 546 || # Vermillion Fight Arena
			$game_map.map_id == 783 || # Mt. Silver Summit (Cynthia)
			$game_map.map_id == 784 )  # Mt. Silver Summit Future (Gold)
		@sideSizes = [1, 1]
	else	
		challende_mode_setBattleMode(mode)	
	end	
  end

end

class HallOfFame_Scene

  alias challende_mode_writeGameMode writeGameMode
  def writeGameMode(overlay, x, y)
	if $game_switches[850]
		gameMode = "Endgame Challenge"
		gameMode = "Endgame Challenge Completed!" if $game_map.map_id == 314
		subMode = ""  # Might make an All Ability Mutation mode in the future.
		pbDrawTextPositions(overlay, [[_INTL("{1} {2}", gameMode, subMode), x, y, 2, BASECOLOR, SHADOWCOLOR]])
	else
		challende_mode_writeGameMode(overlay, x, y)
	end	
  end

  def writeTrainerData
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    pubid = sprintf("%05d", $Trainer.public_ID)
    lefttext = _INTL("Name<r>{1}<br>", $Trainer.name)
    lefttext += _INTL("IDNo.<r>{1}<br>", pubid)
    lefttext += _ISPRINTF("Time<r>{1:02d}:{2:02d}<br>", hour, min)
    lefttext += _INTL("Pokédex<r>{1}/{2}<br>",
                      $Trainer.pokedex.owned_count, $Trainer.pokedex.seen_count)
    lefttext += _INTL("Difficulty<r>{1}<br>", getDifficulty())
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
	if $game_switches[850] && $game_map.map_id == 314
   	 pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("You completed the challenge!\nCongratulations!\\^"))
	else
   	 pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("League champion!\nCongratulations!\\^"))
	end				 
  end

end

class PokeBattle_Move

	
	def pbAccuracyCheck(user,target)
		# "Always hit" effects and "always hit" accuracy
		return true if target.effects[PBEffects::Telekinesis]>0
		return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
		baseAcc = pbBaseAccuracy(user,target)
		return true if baseAcc==0
		# Calculate all multiplier effects
		modifiers = {}
		modifiers[:base_accuracy]  = baseAcc
		modifiers[:accuracy_stage] = user.stages[:ACCURACY]
		modifiers[:evasion_stage]  = target.stages[:EVASION]
		modifiers[:accuracy_multiplier] = 1.0
		modifiers[:evasion_multiplier]  = 1.0
		pbCalcAccuracyModifiers(user,target,modifiers)
		# Check if move can't miss
		return true if modifiers[:base_accuracy] == 0
		# Calculation
		accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
		evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
		stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
		stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
		accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
		if $game_switches[850] # You can now hit your Focus Blasts my dear AI
			if user.pbOwnedByPlayer?
				accuracy*=1.2  if @baseDamage>0
			else
				accuracy*=1.3 
			end
		end			
		evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
		accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
		evasion  = (evasion  * modifiers[:evasion_multiplier]).round
		evasion = 1 if evasion < 1
		# Calculation
		return @battle.pbRandom(100) < modifiers[:base_accuracy] * accuracy / evasion
	end
	
end  

#===============================================================================
# Hits 2-5 times.
#===============================================================================
class PokeBattle_Move_0C0 < PokeBattle_Move
  
	def pbNumHits(user,targets)
	  if @id == :WATERSHURIKEN && user.isSpecies?(:GRENINJA) && user.form == 2
		return 3
	  end
	  hitChances = [3,3,4,4,5,5]
	  r = @battle.pbRandom(hitChances.length)
	  r = hitChances.length-1 if user.hasActiveAbility?(:SKILLLINK)
	  return hitChances[r]
	end
  end

module GameData
	
	#=============================================================================
	# A bulk loader method for all data stored in .dat files in the Data folder.
	#=============================================================================
	def self.load_all
		Type.load
		Ability.load
		Move.load
		Item.load
		BerryPlant.load
		Species.load
		Ribbon.load
		Encounter.load
		EncounterModern.load
		EncounterRandom.load
		TrainerType.load
		Trainer.load
		TrainerModern.load
		TrainerChallenge.load
		Metadata.load
		MapMetadata.load
	end
	
	class TrainerType
		
		alias challenge_initialize initialize
		def initialize(hash)
			challenge_initialize(hash)
			if $game_switches[850]
				@skill_level = 100 || @base_money
			end	
		end
		
	end
	
	class Trainer	  
				
				
		alias challenge_mode_to_trainer to_trainer
		def to_trainer
			if $game_switches && $game_switches[850] && 
				($game_map.map_id == 314 ||  # Pokemon League Lobby
					$game_map.map_id == 315 || # Lorelei
					$game_map.map_id == 316 || # Bruno
					$game_map.map_id == 317 || # Agatha
					$game_map.map_id == 318 || # Lance
					$game_map.map_id == 328 || # Champion Room
					$game_map.map_id == 546 || # Vermillion Fight Arena
					$game_map.map_id == 783 || # Mt. Silver Summit (Cynthia)
					$game_map.map_id == 784 )  # Mt. Silver Summit Future (Gold)
					  randovar=$game_switches[987]
					  reversevar=$game_switches[47]
					  rematch=$game_switches[SWITCH_IS_REMATCH]
					  $game_switches[987]=false
					  $game_switches[47]=false
					  $game_switches[SWITCH_IS_REMATCH]=false
			end		  
		  trainer = challenge_mode_to_trainer
			if $game_switches && $game_switches[850] && 
				($game_map.map_id == 314 ||  # Pokemon League Lobby
					$game_map.map_id == 315 || # Lorelei
					$game_map.map_id == 316 || # Bruno
					$game_map.map_id == 317 || # Agatha
					$game_map.map_id == 318 || # Lance
					$game_map.map_id == 328 || # Champion Room
					$game_map.map_id == 546 || # Vermillion Fight Arena
					$game_map.map_id == 783 || # Mt. Silver Summit (Cynthia)
					$game_map.map_id == 784 )  # Mt. Silver Summit Future (Gold)		  
				trainer.party.each_with_index do |pkmn, i|
					pkmn_data = @pokemon[i]
					pkmn.abilityMutation = true if pkmn_data[:abilityMutation]					
						maxlevel=0
						for i in $Trainer.party
							if i.level>maxlevel
								maxlevel=i.level
							end    
						end 
						pkmn.level=maxlevel
					GameData::Stat.each_main do |s|
						pkmn.ev[s.id] = 252
						pkmn.ev[s.id]+=200 if (s.id==:ATTACK || s.id==:SPECIAL_ATTACK)
					end				
					pkmn.calc_stats
				end
				$game_switches[987]=randovar
				$game_switches[47]=reversevar  
				$game_switches[SWITCH_IS_REMATCH]=rematch
			end	
		  return trainer
		end				
		
	end
	
	
	class TrainerChallenge
		attr_reader :id
		attr_reader :id_number
		attr_reader :trainer_type
		attr_reader :real_name
		attr_reader :version
		attr_reader :items
		attr_reader :real_lose_text
		attr_reader :pokemon
		
		DATA = {}
		DATA_FILENAME = "trainers_challenge.dat"
		
		SCHEMA = {
			"Items" => [:items, "*e", :Item],
			"LoseText" => [:lose_text, "s"],
			"Pokemon" => [:pokemon, "ev", :Species], # Species, level
			"Form" => [:form, "u"],
			"Name" => [:name, "s"],
			"Moves" => [:moves, "*e", :Move],
			"Ability" => [:ability, "s"],
			"AbilityIndex" => [:ability_index, "u"],
			"Item" => [:item, "e", :Item],
			"Gender" => [:gender, "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
					"F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
			"Nature" => [:nature, "e", :Nature],
			"IV" => [:iv, "uUUUUU"],
			"EV" => [:ev, "uUUUUU"],
			"Happiness" => [:happiness, "u"],
			"Shiny" => [:shininess, "b"],
			"Shadow" => [:shadowness, "b"],
			"Ball" => [:poke_ball, "s"],
		}
		
		extend ClassMethods
		include InstanceMethods
		
		# @param tr_type [Symbol, String]
		# @param tr_name [String]
		# @param tr_version [Integer, nil]
		# @return [Boolean] whether the given other is defined as a self
		def self.exists?(tr_type, tr_name, tr_version = 0)
			validate tr_type => [Symbol, String]
			validate tr_name => [String]
			key = [tr_type.to_sym, tr_name, tr_version]
			return !self::DATA[key].nil?
		end
		
		# @param tr_type [Symbol, String]
		# @param tr_name [String]
		# @param tr_version [Integer, nil]
		# @return [self]
		def self.get(tr_type, tr_name, tr_version = 0)
			validate tr_type => [Symbol, String]
			validate tr_name => [String]
			key = [tr_type.to_sym, tr_name, tr_version]
			raise "Unknown trainer #{tr_type} #{tr_name} #{tr_version}." unless self::DATA.has_key?(key)
			return self::DATA[key]
		end
		
		# @param tr_type [Symbol, String]
		# @param tr_name [String]
		# @param tr_version [Integer, nil]
		# @return [self, nil]
		def self.try_get(tr_type, tr_name, tr_version = 0)
			validate tr_type => [Symbol, String]
			validate tr_name => [String]
			key = [tr_type.to_sym, tr_name, tr_version]
			return (self::DATA.has_key?(key)) ? self::DATA[key] : nil
		end
		
		def self.list_all()
			return self::DATA
		end
		
		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@trainer_type = hash[:trainer_type]
			@real_name = hash[:name] || "Unnamed"
			@version = hash[:version] || 0
			@items = hash[:items] || []
			@real_lose_text = hash[:lose_text] || "..."
			@pokemon = hash[:pokemon] || []
			@pokemon.each do |pkmn|
				GameData::Stat.each_main do |s|
					pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
					pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
				end
			end
		end
		
		# @return [String] the translated name of this trainer
		def name
			return pbGetMessageFromHash(MessageTypes::TrainerNames, @real_name)
		end
		
		# @return [String] the translated in-battle lose message of this trainer
		def lose_text
			return pbGetMessageFromHash(MessageTypes::TrainerLoseText, @real_lose_text)
		end
		
		def replace_species_with_placeholder(species)
			case species
			when Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES
				return pbGet(Settings::RIVAL_STARTER_PLACEHOLDER_VARIABLE)
			when Settings::VAR_1_PLACEHOLDER_SPECIES
				return pbGet(1)
			when Settings::VAR_2_PLACEHOLDER_SPECIES
				return pbGet(2)
			when Settings::VAR_3_PLACEHOLDER_SPECIES
				return pbGet(3)
			end
		end
		
		def generateRandomChampionSpecies(old_species)
			customsList = getCustomSpeciesList()
			bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)
			new_species = $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? getSpecies(getNewCustomSpecies(old_species, customsList, bst_range)) : getSpecies(getNewSpecies(old_species, bst_range))
			#every pokemon should be fully evolved
			evolved_species_id = getEvolution(new_species)
			evolved_species_id = getEvolution(evolved_species_id)
			evolved_species_id = getEvolution(evolved_species_id)
			evolved_species_id = getEvolution(evolved_species_id)
			return getSpecies(evolved_species_id)
		end
		
		def generateRandomGymSpecies(old_species)
			gym_index = pbGet(VAR_CURRENT_GYM_TYPE)
			return old_species if gym_index == -1
			return generateRandomChampionSpecies(old_species) if gym_index == 999
			type_id = pbGet(VAR_GYM_TYPES_ARRAY)[gym_index]
			return old_species if type_id == -1
			
			customsList = getCustomSpeciesList()
			bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)
			gym_type = GameData::Type.get(type_id)
			while true
				new_species = $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? getSpecies(getNewCustomSpecies(old_species, customsList, bst_range)) : getSpecies(getNewSpecies(old_species, bst_range))
				if new_species.hasType?(gym_type)
					return new_species
				end
			end
		end
		
		def replace_species_to_randomized_gym(species, trainerId, pokemonIndex)
			if $PokemonGlobal.randomGymTrainersHash == nil
				$PokemonGlobal.randomGymTrainersHash = {}
			end
			if $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] && $PokemonGlobal.randomGymTrainersHash != nil
				if $PokemonGlobal.randomGymTrainersHash[trainerId] != nil && $PokemonGlobal.randomGymTrainersHash[trainerId].length >= $PokemonGlobal.randomTrainersHash[trainerId].length
					return getSpecies($PokemonGlobal.randomGymTrainersHash[trainerId][pokemonIndex])
				end
			end
			new_species = generateRandomGymSpecies(species)
			if $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS]
				add_generated_species_to_gym_array(new_species, trainerId)
			end
			return new_species
		end
		
		def add_generated_species_to_gym_array(new_species, trainerId)
			if (new_species.is_a?(Symbol))
				id = new_species
			else
				id = new_species.id_number
			end
			
			expected_team_length = 1
			expected_team_length = $PokemonGlobal.randomTrainersHash[trainerId].length if $PokemonGlobal.randomTrainersHash[trainerId]
			new_team = []
			if $PokemonGlobal.randomGymTrainersHash[trainerId]
				new_team = $PokemonGlobal.randomGymTrainersHash[trainerId]
			end
			if new_team.length < expected_team_length
				new_team << id
			end
			$PokemonGlobal.randomGymTrainersHash[trainerId] = new_team
		end
		
		def replace_species_to_randomized_regular(species, trainerId, pokemonIndex)
			if $PokemonGlobal.randomTrainersHash[trainerId] == nil
				Kernel.pbMessage(_INTL("The trainers need to be re-shuffled."))
				Kernel.pbShuffleTrainers()
			end
			new_species_dex = $PokemonGlobal.randomTrainersHash[trainerId][pokemonIndex]
			return getSpecies(new_species_dex)
		end
		
		def isGymBattle
			return ($game_switches[SWITCH_RANDOM_TRAINERS] && ($game_variables[VAR_CURRENT_GYM_TYPE] != -1) || ($game_switches[SWITCH_FIRST_RIVAL_BATTLE] && $game_switches[SWITCH_RANDOM_STARTERS]))
		end
		
		def replace_species_to_randomized(species, trainerId, pokemonIndex)
			return species if $game_switches[SWITCH_FIRST_RIVAL_BATTLE]
			if isGymBattle() && $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY]
				return replace_species_to_randomized_gym(species, trainerId, pokemonIndex)
			end
			return replace_species_to_randomized_regular(species, trainerId, pokemonIndex)
			
		end
		
		def replaceSingleSpeciesModeIfApplicable(species)
			if $game_switches[SWITCH_SINGLE_POKEMON_MODE]
				if $game_switches[SWITCH_SINGLE_POKEMON_MODE_HEAD]
					return replaceFusionsHeadWithSpecies(species)
				elsif $game_switches[SWITCH_SINGLE_POKEMON_MODE_BODY]
					return replaceFusionsBodyWithSpecies(species)
				elsif $game_switches[SWITCH_SINGLE_POKEMON_MODE_RANDOM]
					if (rand(2) == 0)
						return replaceFusionsHeadWithSpecies(species)
					else
						return replaceFusionsBodyWithSpecies(species)
					end
				end
			end
			return species
		end
		
		def replaceFusionsHeadWithSpecies(species)
			speciesId = getDexNumberForSpecies(species)
			if speciesId > NB_POKEMON
				bodyPoke = getBodyID(speciesId)
				headPoke = pbGet(VAR_SINGLE_POKEMON_MODE)
				newSpecies = bodyPoke * NB_POKEMON + headPoke
				return getPokemon(newSpecies)
			end
			return species
		end
		
		def replaceFusionsBodyWithSpecies(species)
			speciesId = getDexNumberForSpecies(species)
			if speciesId > NB_POKEMON
				bodyPoke = pbGet(VAR_SINGLE_POKEMON_MODE)
				headPoke = getHeadID(species)
				newSpecies = bodyPoke * NB_POKEMON + headPoke
				return getPokemon(newSpecies)
			end
			return species
		end
		
		def to_trainer
			placeholder_species = [Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES,
				Settings::VAR_1_PLACEHOLDER_SPECIES,
				Settings::VAR_2_PLACEHOLDER_SPECIES,
				Settings::VAR_3_PLACEHOLDER_SPECIES]
			# Determine trainer's name
			tr_name = self.name
			Settings::RIVAL_NAMES.each do |rival|
				next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
				tr_name = $game_variables[rival[1]]
				break
			end
			# Create trainer object
			trainer = NPCTrainer.new(tr_name, @trainer_type)
			trainer.id = $Trainer.make_foreign_ID
			trainer.items = @items.clone
			trainer.lose_text = self.lose_text
			
			isRematch = $game_switches[SWITCH_IS_REMATCH]
			isPlayingRandomized = $game_switches[SWITCH_RANDOM_TRAINERS] && !$game_switches[SWITCH_FIRST_RIVAL_BATTLE]
			rematchId = getRematchId(trainer.name, trainer.trainer_type)
			
			# Create each Pokémon owned by the trainer
			index = 0
			@pokemon.each do |pkmn_data|
				#replace placeholder species infinite fusion edit
				species = GameData::Species.get(pkmn_data[:species]).species
				original_species = species
				if placeholder_species.include?(species)
					species = replace_species_with_placeholder(species)
				else
					species = replace_species_to_randomized(species, self.id, index) if isPlayingRandomized
				end
				species = replaceSingleSpeciesModeIfApplicable(species)
				if $game_switches[SWITCH_REVERSED_MODE]
					species = reverseFusionSpecies(species)
				end
				level = pkmn_data[:level]
				if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
					level = (level * Settings::HARD_MODE_LEVEL_MODIFIER).ceil
					if level > Settings::MAXIMUM_LEVEL
						level = Settings::MAXIMUM_LEVEL
					end
				end
				
				if $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH]
					override_level = $game_variables[Settings::OVERRIDE_BATTLE_LEVEL_VALUE_VAR]
					if override_level.is_a?(Integer)
						level = override_level
					end
				end
				####
				
				#trainer rematch infinite fusion edit
				if isRematch
					nbRematch = getNumberRematch(rematchId)
					level = getRematchLevel(level, nbRematch)
					species = evolveRematchPokemon(nbRematch, species)
				end
				
				maxlevel=0
				for i in $Trainer.party
					if i.level>maxlevel
						maxlevel=i.level
					end    
				end 
				level=maxlevel
				
				pkmn = Pokemon.new(species, level, trainer, false)
				
				trainer.party.push(pkmn)
				# Set Pokémon's properties if defined
				if pkmn_data[:form]
					pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
					pkmn.form_simple = pkmn_data[:form]
				end
				
				if $game_switches[SWITCH_RANDOM_HELD_ITEMS]
					pkmn.item = pbGetRandomHeldItem().id
				else
					pkmn.item = pkmn_data[:item]
				end
				if pkmn_data[:moves] && pkmn_data[:moves].length > 0 && original_species == species
					pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
					pkmn.moves.each { |move| move.pp*=2 }
				else
					pkmn.reset_moves
				end
				pkmn.ability_index = pkmn_data[:ability_index]
				pkmn.ability = pkmn_data[:ability]
				pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
				pkmn.shiny = (pkmn_data[:shininess]) ? true : false
				if pkmn_data[:nature]
					pkmn.nature = pkmn_data[:nature]
				else
					nature = pkmn.species_data.id_number + GameData::TrainerType.get(trainer.trainer_type).id_number
					pkmn.nature = nature % (GameData::Nature::DATA.length / 2)
				end
				GameData::Stat.each_main do |s|
					if pkmn_data[:iv]
						pkmn.iv[s.id] = pkmn_data[:iv][s.id]
					else
						pkmn.iv[s.id] = [pkmn_data[:level] / 2, Pokemon::IV_STAT_LIMIT].min
					end
					if pkmn_data[:ev]
						pkmn.ev[s.id] = pkmn_data[:ev][s.id]
					else
						pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, Pokemon::EV_LIMIT / 6].min
					end
				end
				pkmn.happiness = pkmn_data[:happiness] if pkmn_data[:happiness]
				pkmn.name = pkmn_data[:name] if pkmn_data[:name] && !pkmn_data[:name].empty?
				if pkmn_data[:shadowness]
					pkmn.makeShadow
					pkmn.update_shadow_moves(true)
					pkmn.shiny = false
				end
				pkmn.poke_ball = pkmn_data[:poke_ball] if pkmn_data[:poke_ball]
				pkmn.calc_stats
				
				index += 1
			end
			return trainer
		end
	end
end