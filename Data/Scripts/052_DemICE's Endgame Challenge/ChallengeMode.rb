
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

	alias challende_mode_pbCalcDamageMultipliers pbCalcDamageMultipliers
	def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
		if $game_switches[850]
			# Global abilities
			if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
			   (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
			  if @battle.pbCheckGlobalAbility(:AURABREAK)
				multipliers[:base_damage_multiplier] *= 2 / 3.0
			  else
				multipliers[:base_damage_multiplier] *= 4 / 3.0
			  end
			end
			# Ability effects that alter damage
			if user.abilityActive?
			  BattleHandlers.triggerDamageCalcUserAbility(user.ability,
				 user,target,self,multipliers,baseDmg,type)
			end
			if !@battle.moldBreaker
			  # NOTE: It's odd that the user's Mold Breaker prevents its partner's
			  #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
			  #       how it works.
			  user.eachAlly do |b|
				next if !b.abilityActive?
				BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
				   user,target,self,multipliers,baseDmg,type)
			  end
			  if target.abilityActive?
				BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
				   user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
				BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
				   user,target,self,multipliers,baseDmg,type)
			  end
			  target.eachAlly do |b|
				next if !b.abilityActive?
				BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
				   user,target,self,multipliers,baseDmg,type)
			  end
			end
			# Item effects that alter damage
			if user.itemActive?
			  BattleHandlers.triggerDamageCalcUserItem(user.item,
				 user,target,self,multipliers,baseDmg,type)
			end
			if target.itemActive?
			  BattleHandlers.triggerDamageCalcTargetItem(target.item,
				 user,target,self,multipliers,baseDmg,type)
			end
			# Parental Bond's second attack
			if user.effects[PBEffects::ParentalBond]==1
			  multipliers[:base_damage_multiplier] /= 4
			end
			# Other
			if user.effects[PBEffects::MeFirst]
			  multipliers[:base_damage_multiplier] *= 1.5
			end
			if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
			  multipliers[:base_damage_multiplier] *= 1.5
			end
			if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
			  multipliers[:base_damage_multiplier] *= 2
			end
			# Mud Sport
			if type == :ELECTRIC
			  @battle.eachBattler do |b|
				next if !b.effects[PBEffects::MudSport]
				multipliers[:base_damage_multiplier] /= 3
				break
			  end
			  if @battle.field.effects[PBEffects::MudSportField]>0
				multipliers[:base_damage_multiplier] /= 3
			  end
			end
			# Water Sport
			if type == :FIRE
			  @battle.eachBattler do |b|
				next if !b.effects[PBEffects::WaterSport]
				multipliers[:base_damage_multiplier] /= 3
				break
			  end
			  if @battle.field.effects[PBEffects::WaterSportField]>0
				multipliers[:base_damage_multiplier] /= 3
			  end
			end
			# Terrain moves
			case @battle.field.terrain
			when :Electric
			  multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
			when :Grassy
			  multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
			when :Psychic
			  multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
			when :Misty
			  multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
			end
			# Badge multipliers
			if @battle.internalBattle
			  if user.pbOwnedByPlayer?
				if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
				  multipliers[:attack_multiplier] *= 1.1
				elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
				  multipliers[:attack_multiplier] *= 1.1
				end
			  end
			  if target.pbOwnedByPlayer?
				if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
				  multipliers[:defense_multiplier] *= 1.1
				elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
				  multipliers[:defense_multiplier] *= 1.1
				end
			  end
			end
			# Multi-targeting attacks
			if numTargets>1
			  multipliers[:final_damage_multiplier] *= 0.75
			end
			# Weather
			case @battle.pbWeather
			when :Sun, :HarshSun
			  if type == :FIRE
				multipliers[:final_damage_multiplier] *= 1.5
			  elsif type == :WATER
				multipliers[:final_damage_multiplier] /= 2
			  end
			when :Rain, :HeavyRain
			  if type == :FIRE
				multipliers[:final_damage_multiplier] /= 2
			  elsif type == :WATER
				multipliers[:final_damage_multiplier] *= 1.5
			  end
			when :Sandstorm
			  if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
				multipliers[:defense_multiplier] *= 1.5
			  end
			end
			# Critical hits
			if target.damageState.critical
			  if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
				multipliers[:final_damage_multiplier] *= 1.5
			  else
				multipliers[:final_damage_multiplier] *= 2
			  end
			end
			# Random variance
			# if !self.is_a?(PokeBattle_Confusion)
			#   random = 85+@battle.pbRandom(16)
			#   multipliers[:final_damage_multiplier] *= random / 100.0
			# end
			# STAB
			if type && user.pbHasType?(type)
			  if user.hasActiveAbility?(:ADAPTABILITY)
				multipliers[:final_damage_multiplier] *= 2
			  else
				multipliers[:final_damage_multiplier] *= 1.5
			  end
			end
			# Type effectiveness
			multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
			# Burn
			if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
			   !user.hasActiveAbility?(:GUTS)
			  multipliers[:final_damage_multiplier] /= 2
			end
			# Frostbite
			if user.status == :FROZEN && specialMove? && ($PokemonSystem.frostbite && $PokemonSystem.frostbite != 0)
				!user.hasActiveAbility?(:GUTS)
			   multipliers[:final_damage_multiplier] /= 2
			 end
			# Aurora Veil, Reflect, Light Screen
			if !ignoresReflect? && !target.damageState.critical &&
			   !user.hasActiveAbility?(:INFILTRATOR)
			  if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
				if @battle.pbSideBattlerCount(target)>1
				  multipliers[:final_damage_multiplier] *= 2 / 3.0
				else
				  multipliers[:final_damage_multiplier] /= 2
				end
			  elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
				if @battle.pbSideBattlerCount(target)>1
				  multipliers[:final_damage_multiplier] *= 2 / 3.0
				else
				  multipliers[:final_damage_multiplier] /= 2
				end
			  elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
				if @battle.pbSideBattlerCount(target) > 1
				  multipliers[:final_damage_multiplier] *= 2 / 3.0
				else
				  multipliers[:final_damage_multiplier] /= 2
				end
			  end
			end
			# Minimize
			if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
			  multipliers[:final_damage_multiplier] *= 2
			end
			# Move-specific base damage modifiers
			multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
			# Move-specific final damage modifiers
			multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
		else
			challende_mode_pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
		end
	end
	
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
	
	def self.check_existence(moves, tutor_moves, egg_moves, abilities, hidden_abilities, type1, type2, wild_item_common, wild_item_uncommon, wild_item_rare)
		self.check_existence_moves(moves,1)
		self.check_existence_moves(tutor_moves,1)
		self.check_existence_moves(egg_moves,1)
		self.check_existence_moves(abilities,2)
		self.check_existence_moves(hidden_abilities,2)
		if wild_item_common && !GameData::Item.exists?(wild_item_common)
			puts "Item #{wild_item_common} does not exist"
		end
		if wild_item_uncommon && !GameData::Item.exists?(wild_item_uncommon)
			puts "Item #{wild_item_uncommon} does not exist"
		end
		if wild_item_rare && !GameData::Item.exists?(wild_item_rare)
			puts "Item #{wild_item_rare} does not exist"
		end
		if type1 && !GameData::Type.exists?(type1)
			puts "Type #{type1} does not exist"
		end
		if type2 && !GameData::Type.exists?(type2)
			puts "Type #{type2} does not exist"
		end
	end

	def self.check_existence_moves(moves, typecheck=1)
		moves.each do |move|
			if typecheck == 1
				if move[1].is_a?(Symbol)
					if !GameData::Move.exists?(move[1])
						puts "Move #{move[1]} does not exist"
					end
				end
			else
				if move.is_a?(Symbol)
					if typecheck == 1 && !GameData::Move.exists?(move)
				 		puts "Move #{move} does not exist"
					elsif typecheck == 2 && !GameData::Ability.exists?(move)
						puts "Ability #{move} does not exist"
					end
				end
			end
		end
	end
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
		TrainerExpert.load
		TrainerChallenge.load
		Metadata.load
		MapMetadata.load

		# Custom Pokemon
		id_mon = 0

		id_mon += 1
		id = "KURAY" + sprintf("%03d", id_mon)
		name = "Zangfox"
		type1 = :DARK
		type2 = :FIGHTING
		moves = [[1,:SCRATCH],[1,:LEER],[5,:QUICKATTACK],[8,:FURYCUTTER],[12,:HONECLAWS],[15,:AERIALACE],[19,:SLASH],[22,:REVENGE],[26,:CRUSHCLAW],[29,:FALSESWIPE],[33,:FACADE],[36,:DARKPULSE],[40,:XSCISSOR],[43,:TAUNT],[47,:SWORDSDANCE],[50,:CLOSECOMBAT]]
		tutor_moves = [:AERIALACE,:ATTRACT,:BLIZZARD,:BODYSLAM,:BRICKBREAK,:CAPTIVATE,:CONFIDE,:COUNTER,:DEFENSECURL,:DIG,:DOUBLEEDGE,:DOUBLETEAM,:DYNAMICPUNCH,:EMBARGO,:ENDEAVOR,:ENDURE,:FACADE,:FALSESWIPE,:FIREBLAST,:FIREPUNCH,:FLAMETHROWER,:FLING,:FOCUSBLAST,:FOCUSPUNCH,:FRUSTRATION,:FURYCUTTER,:GIGADRAIN,:HEADBUTT,:HIDDENPOWER,:HONECLAWS,:ICEBEAM,:ICEPUNCH,:ICYWIND,:INCINERATE,:IRONTAIL,:KNOCKOFF,:LASTRESORT,:LOWKICK,:MEGAKICK,:MEGAPUNCH,:MIMIC,:MUDSLAP,:NATURALGIFT,:PAYBACK,:POISONJAB,:POWERUPPUNCH,:PROTECT,:RAINDANCE,:REST,:RETALIATE,:RETURN,:ROAR,:ROCKCLIMB,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROLLOUT,:ROUND,:SECRETPOWER,:SEISMICTOSS,:SHADOWBALL,:SHADOWCLAW,:SHOCKWAVE,:SLEEPTALK,:SNORE,:SOLARBEAM,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:SWIFT,:SWORDSDANCE,:TAUNT,:THIEF,:THROATCHOP,:THUNDER,:THUNDERBOLT,:THUNDERPUNCH,:THUNDERWAVE,:WATERPULSE,:WORKUP,:XSCISSOR]
		egg_moves = [:BELLYDRUM,:COUNTER,:CURSE,:DISABLE,:DOUBLEHIT,:DOUBLEKICK,:FEINT,:FINALGAMBIT,:FLAIL,:FURYSWIPES,:METALCLAW,:NIGHTSLASH,:QUICKGUARD]
		abilities = [:IMMUNITY]
		hidden_abilities = [:TOXICBOOST]
		wild_item_common = nil
		wild_item_uncommon = :QUICKCLAW
		wild_item_rare = nil
		height = 1.3*10
		weight = 40.3*10
		self.check_existence(moves, tutor_moves, egg_moves, abilities, hidden_abilities, type1, type2, wild_item_common, wild_item_uncommon, wild_item_rare)
		Species.register({
			:id              => id.to_sym,
			# :species         => "KURAYZANGRATH".to_sym,
			:id_number       => Settings::KURAY_CUSTOM_POKEMONS+id_mon,
			:name            => name,
			:form_name       => nil,
			:category        => "Paradox",
			:pokedex_entry   => "A mysterious outsider from another dimension. It somehow managed to find its way here.",
			:type1           => type1,
			:type2           => type2,
			:base_stats      => {:HP => 73, :ATTACK => 125, :DEFENSE => 60, :SPECIAL_ATTACK => 90, :SPECIAL_DEFENSE => 55, :SPEED => 60},
			:evs             => {:HP => 0, :ATTACK => 2, :DEFENSE => 0, :SPECIAL_ATTACK => 0, :SPECIAL_DEFENSE => 0, :SPEED => 0},
			:base_exp        => 160,
			:growth_rate     => :Erratic,
			:gender_ratio    => :Female50Percent,
			:catch_rate      => 80,
			:happiness       => 50,
			:moves           => moves,
			:tutor_moves     => tutor_moves,
			:egg_moves       => egg_moves,
			:abilities       => abilities,
			:hidden_abilities => hidden_abilities,
			:wild_item_common => wild_item_common,
			:wild_item_uncommon => wild_item_uncommon,
			:wild_item_rare  => wild_item_rare,
			:egg_groups      => [:Undiscovered],
			:hatch_steps     => 5120,
			:evolutions      => [],
			:height          => height,
			:weight          => weight,
			:color           => :Red,
			:shape           => :BipedalTail,
			:habitat         => :Grassland,
			:generation      => 99,
			:back_sprite_x   => 0,
			:back_sprite_y   => 0,
			:front_sprite_x  => 0,
			:front_sprite_y  => 0,
			:front_sprite_altitude => 0,
			:shadow_x        => 0,
			:shadow_size     => 2
		})
		puts "Loaded custom Pokemon: #{id.to_sym} - #{name}"
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
						maxlevel=60 if maxlevel<60
						pkmn.level=maxlevel
					GameData::Stat.each_main do |s|
						pkmn.ev[s.id] = 252
						pkmn.ev[s.id]+= 200 if (s.id==:ATTACK || s.id==:SPECIAL_ATTACK)
						pkmn.ev[s.id] = 0 if (s.id==:SPEED) && pkmn.hasMove?(:TRICKROOM)
					end				
					pkmn.calc_stats
					#Shedproofing
					needfairy=false
					needdark=false
					needfire=false
					needsomething=false
					for i in $Trainer.party
						if i.ability==:WONDERGUARD
							needfairy=true if i.hasType?(:DARK) && i.hasType?(:GHOST) 
							needdark=true if i.hasType?(:NORMAL) && i.hasType?(:GHOST) 
							needfire=true if i.hasType?(:BUG) && i.hasType?(:STEEL) 
							needsomething=true if !needfairy && !needfire && !needdark
						end	
					end	
					partypoopers=0
					partypoopers+=1 if needfairy
					partypoopers+=1 if needdark
					partypoopers+=1 if needfire
					case pkmn.species
					# Lorelei
					when :B135H272
						if partypoopers>1 || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							if needfire 
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HIDDENPOWER)# 31,30,31,30,31,30
								pkmn.iv[:HP]=31
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=31
								pkmn.iv[:SPEED]=30
								pkmn.iv[:SPECIAL_ATTACK]=31
								pkmn.iv[:SPECIAL_DEFENSE]=30
							end
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HIDDENPOWER)# 31,30,30,31,30,31
								pkmn.iv[:HP]=31
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=30
								pkmn.iv[:SPEED]=31
								pkmn.iv[:SPECIAL_ATTACK]=30
								pkmn.iv[:SPECIAL_DEFENSE]=31
							end
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HIDDENPOWER)# 30,30,31,31,30,31
								pkmn.iv[:HP]=30
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=31
								pkmn.iv[:SPEED]=31
								pkmn.iv[:SPECIAL_ATTACK]=30
								pkmn.iv[:SPECIAL_DEFENSE]=31
							end
						end	
					when :B91H130
						if partypoopers>1
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:FIREBLAST)
							end
							if needdark
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:CRUNCH)
							end
							if needfairy
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:HP]=30
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:SPECIAL_ATTACK]=30
							end
						end	
					when :B262H361
						if needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:STEALTHROCK)
						end	
						if partypoopers>1
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:FIREFANG)
							end
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:KNOCKOFF)
							end
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HAIL)
							end
						end	
					when :B121H124
						if partypoopers>1
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							if needfire # 31,30,31,30,31,30
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:HP]=31
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=31
								pkmn.iv[:SPEED]=30
								pkmn.iv[:SPECIAL_ATTACK]=31
								pkmn.iv[:SPECIAL_DEFENSE]=30
							end
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:HIDDENPOWER)# 31,30,30,31,30,31
								pkmn.iv[:HP]=31
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=30
								pkmn.iv[:SPEED]=31
								pkmn.iv[:SPECIAL_ATTACK]=30
								pkmn.iv[:SPECIAL_DEFENSE]=31
							end
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:MOONBLAST)
							end
						end	
					when :B144H367
						if partypoopers>1 || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B144H367
						if partypoopers>1
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:FIREFANG)
							end
							if needdark
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:CRUNCH)
							end
							if needfairy
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:HAIL)
							end
						end	
					# Bruno
					when :B142H106
						if needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:STEALTHROCK)
						end
						if partypoopers>0
							pkmn.item = :REDCARD
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:WHIRLWIND)
							pkmn.forget_move(:FAKEOUT)
							pkmn.learn_move(:STEALTHROCK)
						end	
					when :B107H212
						if partypoopers>1
							pkmn.forget_move(:ROCKTOMB)
							pkmn.learn_move(:SANDSTORM)
							pkmn.forget_move(:MACHPUNCH)
							pkmn.learn_move(:FIREPUNCH)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:BRUTALSWING)
							end
							if needfairy
								pkmn.forget_move_at_index(2)
								pkmn.learn_move(:TOXIC)
							end
						end	
					when :B321H94
						if partypoopers>0 || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:WILLOWISP)
						end		
					when :B208H367
						if partypoopers>0
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B68H293
						if partypoopers>1
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:SANDSTORM)
							pkmn.forget_move(:BULLETPUNCH)
							pkmn.learn_move(:FIREPUNCH)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:KNOCKOFF)
							end
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:TOXIC)
							end
						end	
					# Agatha	
					when :B255H263
						if needdark || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:WILLOWISP)
						end		
					when :B328H197
						if partypoopers>0
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:WILLOWISP)
						end		
					when :B105H373
						if partypoopers>1
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:WILLOWISP)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(1)
								pkmn.learn_move(:FIREPUNCH)
							else
								pkmn.forget_move_at_index(1)
								pkmn.learn_move(:WILLOWISP)
							end
						end	
					when :B289H331
						if needfire
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B94H275
						if needfire
							pkmn.forget_move(:SHADOWBALL)
							pkmn.learn_move(:WILLOWISP)
						end	
						if needfairy
							pkmn.forget_move(:FOCUSBLAST)
							pkmn.learn_move(:DAZZLINGGLEAM)
						end	
					when :B281H94
						if partypoopers>2
							pkmn.forget_move(:SHADOWBALL)
							pkmn.learn_move(:DARKPULSE)
							pkmn.forget_move(:FOCUSBLAST)
							pkmn.learn_move(:DAZZLINGGLEAM)
						elsif partypoopers>1
							if needfire
								if needdark
									pkmn.forget_move(:SHADOWBALL)
									pkmn.learn_move(:DARKPULSE)
								end	
								if needfairy
									pkmn.forget_move(:SHADOWBALL)
									pkmn.learn_move(:DAZZLINGGLEAM)
								end	
							else
								pkmn.forget_move(:FIREBLAST)
								pkmn.learn_move(:DAZZLINGGLEAM)
								pkmn.forget_move(:SHADOWBALL)
								pkmn.learn_move(:DARKPULSE)
							end
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:SHADOWBALL)
								pkmn.learn_move(:DARKPULSE)
							end	
							if needfairy
								pkmn.forget_move(:FOCUSBLAST)
								pkmn.learn_move(:DAZZLINGGLEAM)
							end	
						end	
					#Lance
					when :B299H309
						if needsomething
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:STEALTHROCK)
						end
						if needfairy || needdark
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:SANDSTORM)
						end
					when :B208H130
						if partypoopers>0
							pkmn.item = :REDCARD
							pkmn.forget_move(:POWERWHIP)
							pkmn.learn_move(:ROAR)
							pkmn.forget_move(:THUNDERWAVE)
							pkmn.learn_move(:STEALTHROCK)
						end	
					when :B142H306
						if partypoopers>0
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:SANDSTORM)
						end
					when :B377H269
						if needdark
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:DARKPULSE)
						end
					when :B368H281
						if needdark || needfairy
							pkmn.ability = :MOLDBREAKER
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:DRAGONDANCE)
						end
					when :B149H293
						if partypoopers>1
							pkmn.forget_move_at_index(0)
							pkmn.learn_move(:SANDSTORM)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:FIREPUNCH)
							end	
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:SANDSTORM)
							end	
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:BRUTALSWING)
							end	
						end	
					#Blue
					when :B142H267
						if needsomething
							pkmn.forget_move(:DRAGONDANCE)
							pkmn.learn_move(:STEALTHROCK)
						end
						if partypoopers>0
							pkmn.item = :REDCARD
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:WHIRLWIND)
							pkmn.forget_move(:DRAGONDANCE)
							pkmn.learn_move(:STEALTHROCK)
						end
					when :B265H103
						if partypoopers>0
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B195H268
						if partypoopers>0 || needsomething
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B128H184
						if partypoopers>1
							pkmn.forget_move_at_index(3)
							if needfire
								pkmn.learn_move(:HAIL)
							else
								pkmn.learn_move(:TOXIC)
							end	
						elsif partypoopers>0
							if needfire
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:TOXIC)
							end	
							if needfairy
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:PLAYROUGH)
							end	
							if needdark
								pkmn.forget_move_at_index(3)
								pkmn.learn_move(:KNOCKOFF)
							end	
						end	
					when :B65H275
						if partypoopers>0
							if needfire # 31,30,31,30,31,30
								pkmn.forget_move(:FOCUSBLAST)
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:SPEED]=30
								pkmn.iv[:SPECIAL_DEFENSE]=30
							end	
							if needdark
								pkmn.forget_move(:NASTYPLOT)
								pkmn.learn_move(:DARKPULSE)
							end	
						end
					when :B6H379
						if partypoopers>0
							pkmn.forget_move_at_index(1)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B9H378
						if partypoopers>1
							pkmn.forget_move_at_index(0)
							if needfire
								pkmn.learn_move(:HAIL)
							else	
								pkmn.learn_move(:TOXIC)
							end	
						elsif partypoopers>0
							pkmn.forget_move_at_index(0)
							if needfire
								pkmn.learn_move(:MYSTICWATER)
							end	
							if needfairy
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:HP]=30
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:SPECIAL_ATTACK]=30
							end	
							if needdark
								pkmn.learn_move(:DARKPULSE)
							end	
						end
					when :B348H3
						if partypoopers>0
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:LEECHSEED)
						end
					# Brock
					when :B76H318
						if partypoopers>0
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B142H25
						if needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:STEALTHROCK)
						end
						if partypoopers>0
							pkmn.forget_move(:AQUATAIL)
							pkmn.learn_move(:WHIRLWIND)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:STEALTHROCK)
						end	
					when :B244H302
						if partypoopers>0 || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B208H374
						if partypoopers>0
							pkmn.forget_move_at_index(2)
							pkmn.learn_move(:WILLOWISP)
						end
					# Misty
					when :B309H130
						if needfire
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
						end	
						if needfairy
							pkmn.forget_move(:DRAGONDANCE)
							pkmn.learn_move(:TOXIC)
						end	
						if needdark
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:KNOCKOFF)
						end	
					when :B243H186
						if needfairy || needdark || needsomething
							pkmn.forget_move(:REFLECT)
							pkmn.learn_move(:TOXIC)
						end	
					when :B266H134
						if partypoopers>0 || needsomething
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B299H184
						if needfire
							pkmn.forget_move(:AQUAJET)
							pkmn.learn_move(:FIREFANG)
						end	
						if needfairy
							pkmn.forget_move(:ICEPUNCH)
							pkmn.learn_move(:PLAYROUGH)
						end	
					when :B336H171
						if needfire
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREFANG)
						end	
						if needfairy || needdark
							pkmn.forget_move(:AQUATAIL)
							pkmn.learn_move(:TOXIC)
						end	
					when :B135H121
						if partypoopers>1
							pkmn.forget_move_at_index(3)
							pkmn.learn_move(:CONFUSERAY)
						elsif partypoopers>0
							pkmn.forget_move_at_index(3)
							if needfire
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:SPEED]=30
								pkmn.iv[:SPECIAL_DEFENSE]=30
							end
							if needdark
								pkmn.learn_move(:BITE)
							end
							if needfairy
								pkmn.learn_move(:MOONBLAST)
							end
						end	
					# Surge
					when :B135H124
						if partypoopers>0
							pkmn.forget_move(:FOCUSBLAST)
							pkmn.learn_move(:NIGHTMARE)
						end
					when :B262H267
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>1
							if needfire
								if needdark
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:HAIL)
								end	
							else
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:HAIL)
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:KNOCKOFF)
							end
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:HAIL)
							end	
						end	
					when :B110H181
						if partypoopers>0 || needsomething
							pkmn.forget_move(:THUNDERWAVE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B336H332
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREFANG)
							pkmn.forget_move(:ZINGZAP)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:ZINGZAP)
								pkmn.learn_move(:FIREFANG)
								if needdark
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:CRUNCH)
								end	
								if needfairy
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:CRUNCH)
								pkmn.forget_move(:ZINGZAP)
								pkmn.learn_move(:TOXIC)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:ZINGZAP)
								pkmn.learn_move(:FIREFANG)
							end	
							if needfairy
								pkmn.forget_move(:ZINGZAP)
								pkmn.learn_move(:TOXIC)
							end	
							if needdark
								pkmn.forget_move(:ZINGZAP)
								pkmn.learn_move(:CRUNCH)
							end	
						end	
					when :B348H358
						if needfairy || needdark
							pkmn.item= :FOCUSSASH
							pkmn.forget_move(:TECHNOBLAST)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B142H26
						if needfire
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREFANG)
						end	
						if needfairy
							if needdark
								pkmn.forget_move(:VOLTTACKLE)
								pkmn.learn_move(:TOXIC)
							else	
								pkmn.forget_move(:AQUATAIL)
								pkmn.learn_move(:TOXIC)
							end
						end	
						if needdark
							pkmn.forget_move(:AQUATAIL)
							pkmn.learn_move(:CRUNCH)
						end
					#Erika
					when :B135H278
						if partypoopers>0 || needsomething
							pkmn.forget_move(:DRAGONPULSE)
							pkmn.learn_move(:LEECHSEED)
						end	
					when :B333H318
						if partypoopers>0 || needsomething
							pkmn.forget_move(:FIREPUNCH)
							pkmn.learn_move(:LEECHSEED)
						end	
					when :B368H355
						if partypoopers>0 || needsomething
							pkmn.ability = :MOLDBREAKER
						end	
					when :B364H184
						if partypoopers>0 || needsomething
							pkmn.forget_move(:THUNDERWAVE)
							pkmn.learn_move(:LEECHSEED)
						end	
					when :B271H244
						if partypoopers>0 || needsomething
							pkmn.forget_move(:SWORDSDANCE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B266H143
						if partypoopers>0 || needsomething
							pkmn.forget_move(:ROCKSLIDE)
							pkmn.learn_move(:LEECHSEED)
						end	
					#Koga
					when :B149H89
						if needfairy || needdark
							pkmn.forget_move(:FIREPUNCH)
							pkmn.learn_move(:GASTROACID)
						end	
					when :B49H377
						if partypoopers>1
							pkmn.forget_move(:BATONPASS)
							pkmn.learn_move(:HIDDENPOWER)
							pkmn.iv[:HP]=30
							pkmn.iv[:ATTACK]=30
							pkmn.iv[:SPECIAL_ATTACK]=30
							pkmn.forget_move(:SLEEPPOWDER)
							pkmn.learn_move(:FIREBLAST)
						elsif partypoopers>0
							pkmn.forget_move(:BATONPASS)
							if needfire
								pkmn.learn_move(:FIREBLAST)
							end	
							if needfairy
								pkmn.learn_move(:HIDDENPOWER)
								pkmn.iv[:HP]=30
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:SPECIAL_ATTACK]=30
							end	
						end	
					when :B89H184
						if partypoopers>0
							pkmn.forget_move(:THUNDERPUNCH)
							pkmn.learn_move(:GASTROACID)
						end	
					when :B110H263
						if needfairy || needdark || needsomething
							pkmn.forget_move(:THUNDERWAVE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B309H34
						if partypoopers>1
							pkmn.forget_move(:WATERFALL)
							pkmn.learn_move(:TOXIC)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:KNOCKOFF)
						elsif partypoopers>0
							pkmn.forget_move(:WATERFALL)
							if needdark
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.learn_move(:TOXIC)
							end	
						end	
					# Sabrina
					when :B321H196
						if needfairy || needdark
							pkmn.forget_move(:SHADOWBALL)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B245H103
						if partypoopers>0 || needsomething
							pkmn.forget_move(:BLIZZARD)
							pkmn.learn_move(:LEECHSEED)
						end	
					when :B293H143
						if needfire || needfairy
							pkmn.forget_move(:SLACKOFF)
							pkmn.learn_move(:GASTROACID)
						end	
					when :B331H288
						if partypoopers>0 || needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B36H151
						if needfairy || needdark || needsomething
							pkmn.forget_move(:PHOTONGEYSER)
							pkmn.learn_move(:MOONGEISTBEAM)
						end		
					when :B65H157
						if needfairy || needdark
							pkmn.forget_move(:ERUPTION)
							pkmn.learn_move(:WILLOWISP)
						end	
					# Blaine
					when :B377H268
						if needfairy || needdark
							pkmn.forget_move(:SURF)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B38H352
						if needfairy || needdark
							pkmn.forget_move(:SLEEPPOWDER)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B278H6
						if needfairy || needdark || needsomething
							pkmn.forget_move(:DRAGONPULSE)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end	
					when :B135H157
						if needfairy || needdark
							pkmn.forget_move(:ERUPTION)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B244H334
						if needfairy || needdark
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end	
					when :B142H59
						if needfairy || needdark || needsomething
							pkmn.species=:B142H78
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end	
					# Giovanni
					when :B38H334
						if needfairy || needdark || needsomething
							pkmn.forget_move(:DRAGONPULSE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B34H374
						if partypoopers>0
							pkmn.forget_move(:THUNDERBOLT)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B232H184
						if partypoopers>1
							pkmn.forget_move(:ICESHARD)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							pkmn.forget_move(:ICESHARD)
							if needfire
								pkmn.learn_move(:HAIL)
							end	
							if needfairy
								pkmn.learn_move(:SANDSTORM)
							end	
							if needdark
								pkmn.learn_move(:KNOCKOFF)
							end	
						end
					when :B262H51
						if partypoopers>1
							pkmn.forget_move(:ICESHARD)
							pkmn.learn_move(:HAIL)
						elsif partypoopers>0
							pkmn.forget_move(:ICESHARD)
							if needfire
								pkmn.learn_move(:HAIL)
							end	
							if needfairy
								pkmn.learn_move(:SANDSTORM)
							end	
							if needdark
								pkmn.learn_move(:KNOCKOFF)
							end	
						end
					when :B265H110
						if needsomething
							pkmn.forget_move(:THUNDERPUNCH)
							pkmn.learn_move(:WILLOWISP)
						end	
						if partypoopers>1
							pkmn.forget_move(:THUNDERPUNCH)
							pkmn.learn_move(:WILLOWISP)
						elsif partypoopers>0
							pkmn.forget_move(:THUNDERPUNCH)
							if needfire
								pkmn.learn_move(:FIREPUNCH)
							end	
							if needfairy || needdark
								pkmn.learn_move(:WILLOWISP)
							end	
						end
					# Whitney	
					when :B254H214
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
							pkmn.forget_move(:ROCKBLAST)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
								if needdark
									pkmn.forget_move(:ROCKBLAST)
									pkmn.learn_move(:THIEF)
								end	
								if needfairy
									pkmn.forget_move(:ROCKBLAST)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:ROCKBLAST)
								pkmn.learn_move(:TOXIC)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:ROCKBLAST)
								pkmn.learn_move(:THIEF)
							end	
							if needfairy
								pkmn.forget_move(:ROCKBLAST)
								pkmn.learn_move(:TOXIC)
							end	
						end	
					when :B151H383
						if needsomething
							pkmn.forget_move(:DRAINPUNCH)
							pkmn.learn_move(:MOONGEISTBEAM)
						end
						if partypoopers>1
							if needfire && needdark
								pkmn.forget_move(:DRAINPUNCH)
								pkmn.learn_move(:MOONGEISTBEAM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:DRAINPUNCH)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:DRAINPUNCH)
								pkmn.learn_move(:MOONGEISTBEAM)
							end	
						end
					when :B273H143
						if partypoopers>0
							pkmn.forget_move(:BATONPASS)
							pkmn.learn_move(:GASTROACID)
						end
					when :B289H217
						if partypoopers>0 || needsomething
							pkmn.forget_move(:TOXIC)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B309H184
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
							pkmn.forget_move(:FRUSTRATION)
							pkmn.learn_move(:PLAYROUGH)
							pkmn.forget_move(:AQUAJET)
							pkmn.learn_move(:KNOCKOFF)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
								if needdark
									pkmn.forget_move(:FRUSTRATION)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:FRUSTRATION)
									pkmn.learn_move(:PLAYROUGH)
								end	
							else
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
								pkmn.forget_move(:AQUAJET)
								pkmn.learn_move(:PLAYROUGH)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:AQUAJET)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end	
					when :B275H374
						if partypoopers>2
							pkmn.forget_move(:FIREBLAST)
							pkmn.learn_move(:WILLOWISP)
						elsif partypoopers>1
							if needdark || needfairy
								pkmn.forget_move(:TECHNOBLAST)
								pkmn.learn_move(:WILLOWISP)
							end	
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:FIREBLAST)
								pkmn.learn_move(:DARKPULSE)
							end	
							if needfairy
								pkmn.forget_move(:TECHNOBLAST)
								pkmn.learn_move(:WILLOWISP)
							end	
						end	
					# Kurt
					when :B309H214
						if partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:FRUSTRATION)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:STONEEDGE)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end	
					when :B123H142
						if needsomething
							pkmn.ability = :STEALTHROCK
						end	
						if partypoopers>0
							pkmn.item = :REDCARD
							pkmn.forget_move(:SWORDSDANCE)
							pkmn.learn_move(:WHIRLWIND)
							pkmn.forget_move(:AQUATAIL)
							pkmn.learn_move(:STEALTHROCK)
						end	
					when :B127H229
						if partypoopers>0
							pkmn.ability = :MOLDBREAKER
						end	
					when :B304H184
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
							pkmn.forget_move(:XSCISSOR)
							pkmn.learn_move(:PLAYROUGH)
							pkmn.forget_move(:ACCELEROCK)
							pkmn.learn_move(:KNOCKOFF)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
								if needdark
									pkmn.forget_move(:XSCISSOR)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:XSCISSOR)
									pkmn.learn_move(:PLAYROUGH)
								end	
							else
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
								pkmn.forget_move(:XSCISSOR)
								pkmn.learn_move(:PLAYROUGH)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:XSCISSOR)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:XSCISSOR)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end	
					when :B296H289
						if partypoopers>0 || needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B348H374
						if partypoopers>0
							pkmn.forget_move(:FLASHCANNON)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end
					# Falkner
					when :B169H25
						if needdark && needfairy
							pkmn.forget_move(:IRONTAIL)
							pkmn.learn_move(:TOXIC)
						else
							if needdark
								pkmn.forget_move(:IRONTAIL)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:IRONTAIL)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end	
					when :B142H281
						if needdark || needfairy
							pkmn.forget_move(:SWORDSDANCE)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B269H324
						if needdark && needfairy
							pkmn.forget_move(:FLASHCANNON)
							if needfire 
								pkmn.forget_move(:AIRSLASH)
							else
								pkmn.forget_move(:FIREBLAST)
							end	
							pkmn.learn_move(:HIDDENPOWER) # 31,30,30,31,30,31
							pkmn.iv[:ATTACK]=30
							pkmn.iv[:DEFENSE]=30
							pkmn.iv[:SPECIAL_ATTACK]=30
							pkmn.learn_move(:MOONBLAST)
						else
							if needdark
								pkmn.forget_move(:FLASHCANNON)
								pkmn.learn_move(:HIDDENPOWER) # 31,30,30,31,30,31
								pkmn.iv[:ATTACK]=30
								pkmn.iv[:DEFENSE]=30
								pkmn.iv[:SPECIAL_ATTACK]=30
							end	
							if needfairy
								pkmn.forget_move(:FLASHCANNON)
								pkmn.learn_move(:MOONBLAST)
							end	
						end	
					when :B270H381
						if needdark || needfairy || needsomething
							pkmn.forget_move(:IRONDEFENSE)
							pkmn.learn_move(:TOXIC)
						elsif needfire	
							pkmn.forget_move(:IRONDEFENSE)
							pkmn.learn_move(:FIREPUNCH)
						end
					when :B336H334
						if partypoopers>2
							pkmn.forget_move(:BRICKBREAK)
							pkmn.learn_move(:FIREPUNCH)
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:SANDSTORM)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:BRICKBREAK)
								pkmn.learn_move(:FIREPUNCH)
								if needdark
									pkmn.forget_move(:STONEEDGE)
									pkmn.learn_move(:CRUNCH)
								end	
								if needfairy
									pkmn.forget_move(:STONEEDGE)
									pkmn.learn_move(:SANDSTORM)
								end	
							else
								pkmn.forget_move(:BRICKBREAK)
								pkmn.learn_move(:CRUNCH)
								pkmn.forget_move(:STONEEDGE)
								pkmn.learn_move(:SANDSTORM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:BRICKBREAK)
								pkmn.learn_move(:FIREPUNCH)
							end
							if needdark
								pkmn.forget_move(:BRICKBREAK)
								pkmn.learn_move(:CRUNCH)
							end	
							if needfairy
								pkmn.forget_move(:BRICKBREAK)
								pkmn.learn_move(:SANDSTORM)
							end	
						end	
					when :B273H171
						if partypoopers>1
							pkmn.forget_move(:SWORDSDANCE)
							pkmn.learn_move(:TAILGLOW)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:SOAK)
							pkmn.forget_move(:CRABHAMMER)
							pkmn.learn_move(:THUNDER)
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREFANG)
							end
							if needdark
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:TOXIC)
							end	
						end	
					# Clair
					when :B299H130
						if partypoopers>2
							pkmn.forget_move(:THUNDERWAVE)
							pkmn.learn_move(:FIREFANG)
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:SANDSTORM)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:THUNDERWAVE)
								pkmn.learn_move(:FIREFANG)
								if needdark
									pkmn.forget_move(:STONEEDGE)
									pkmn.learn_move(:CRUNCH)
								end	
								if needfairy
									pkmn.forget_move(:STONEEDGE)
									pkmn.learn_move(:SANDSTORM)
								end	
							else
								pkmn.forget_move(:THUNDERWAVE)
								pkmn.learn_move(:SANDSTORM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:THUNDERWAVE)
								pkmn.learn_move(:FIREFANG)
							end
							if needdark
								pkmn.forget_move(:THUNDERWAVE)
								pkmn.learn_move(:CRUNCH)
							end	
							if needfairy
								pkmn.forget_move(:THUNDERWAVE)
								pkmn.learn_move(:SANDSTORM)
							end	
						end	
					when :B368H212
						if partypoopers>0 || needsomething
							pkmn.ability = :MOLDBREAKER
							pkmn.forget_move(:BULLETPUNCH)
							pkmn.learn_move(:IRONHEAD)
							pkmn.forget_move(:BULLDOZE)
							pkmn.learn_move(:EARTHQUAKE)
						end	
					when :B377H146
						if needdark || needfairy || needsomething
							pkmn.forget_move(:FLASHCANNON)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B309H336
						if partypoopers>2
							pkmn.forget_move(:DRAGONDANCE)
							pkmn.learn_move(:FIREBLAST)
							pkmn.forget_move(:DRAGONRUSH)
							pkmn.learn_move(:PLAYROUGH)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:KNOCKOFF)
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:DRAGONRUSH)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:FRUSTRATION)
								pkmn.learn_move(:PLAYROUGH)
							end	
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end
						end	
					when :B149H184
						if needfire
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
						end	
						if needfairy
							pkmn.forget_move(:DRAGONRUSH)
							pkmn.learn_move(:PLAYROUGH)
						end	
					when :B230H269
						if needdark
							pkmn.forget_move(:AURASPHERE)
							pkmn.learn_move(:HIDDENPOWER) # 31,30,30,31,30,31
							pkmn.iv[:ATTACK]=30
							pkmn.iv[:DEFENSE]=30
							pkmn.iv[:SPECIAL_ATTACK]=30
					    end
					# Morty
					when :B94H377
						if needfire
							pkmn.forget_move(:FOCUSBLAST)
							pkmn.learn_move(:FIREBLAST)
						end	
						if needfairy
							pkmn.forget_move(:SHADOWBALL)
							pkmn.learn_move(:DAZZLINGGLEAM)
						end	
					when :B321H255
						if needdark
							pkmn.forget_move(:FIREBLAST)
							pkmn.learn_move(:DARKPULSE)
						end
					when :B309H373
						if partypoopers>1
							pkmn.forget_move(:SHADOWSNEAK)
							pkmn.learn_move(:WILLOWISP)
						elsif partypoopers>0
							if needfairy
								pkmn.forget_move(:SHADOWSNEAK)
								pkmn.learn_move(:PLAYROUGH)
							end	
							if needfire
								pkmn.forget_move(:SHADOWSNEAK)
								pkmn.learn_move(:FIREPUNCH)
							end
						end	
					when :B312H242
						if partypoopers>0
							pkmn.forget_move(:SOFTBOILED)
							pkmn.learn_move(:REST)
							pkmn.forget_move(:NIGHTSHADE)
							pkmn.learn_move(:SPITE)
							pkmn.forget_move(:TOXIC)
							pkmn.learn_move(:SLEEPTALK)
						end	
					when :B289H310
						if needfire || needsomething
							pkmn.forget_move(:SHADOWSNEAK)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B348H367
						if needdark || needfairy || needsomething
							pkmn.forget_move(:BUGBUZZ)
							pkmn.learn_move(:WILLOWISP)
						end	
					# Pryce	
					when :B262H321
						if needdark || needfairy
							pkmn.forget_move(:CLOSECOMBAT)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B262H184
						if partypoopers>0 || needsomething
							pkmn.forget_move(:BRICKBREAK)
							pkmn.learn_move(:HAIL)
						end	
					when :B157H124
						if needdark || needfairy
							pkmn.forget_move(:BLIZZARD)
							pkmn.learn_move(:HAIL)
						end	
					when :B272H367
						if needdark || needfairy
							pkmn.forget_move(:FREEZEDRY)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B91H245
						if partypoopers>0
							pkmn.forget_move(:ROCKBLAST)
							pkmn.learn_move(:HAIL)
						end	
					when :B299H274
						if partypoopers>0
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:HAIL)
						end	
					# Jasmine
					when :B94H263
						if partypoopers>0 || needsomething
							pkmn.forget_move(:GIGADRAIN)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B377H263
						if needdark && needfairy
							pkmn.forget_move(:SURF)
							pkmn.learn_move(:DARKPULSE)
							pkmn.forget_move(:DRAGONPULSE)
							pkmn.learn_move(:SANDSTORM)
						end	
					when :B336H324
						if partypoopers>2
							pkmn.forget_move(:AQUATAIL)
							pkmn.learn_move(:FIREFANG)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:SANDSTORM)
						elsif partypoopers>1
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREFANG)
								if needdark
									pkmn.forget_move(:AQUATAIL)
									pkmn.learn_move(:CRUNCH)
								end	
								if needfairy
									pkmn.forget_move(:AQUATAIL)
									pkmn.learn_move(:SANDSTORM)
								end	
							else
								pkmn.forget_move(:AQUATAIL)
								pkmn.learn_move(:SANDSTORM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREFANG)
							end
							if needdark
								pkmn.forget_move(:AQUATAIL)
								pkmn.learn_move(:CRUNCH)
							end	
							if needfairy
								pkmn.forget_move(:AQUATAIL)
								pkmn.learn_move(:SANDSTORM)
							end	
						end
					when :B205H184
						if partypoopers>2
							pkmn.item = :MENTALHERB
							pkmn.forget_move(:ICEPUNCH)
							pkmn.learn_move(:STEALTHROCK)
							pkmn.forget_move(:SHELLSMASH)
							pkmn.learn_move(:SANDSTORM)
						elsif partypoopers>1
							if needfire
								pkmn.item = :MENTALHERB
								pkmn.forget_move(:SHELLSMASH)
								pkmn.learn_move(:STEALTHROCK)
								if needdark
									pkmn.forget_move(:ICEPUNCH)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:ICEPUNCH)
									pkmn.learn_move(:PLAYROUGH)
								end	
							else
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:SANDSTORM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:STEALTHROCK)
							end
							if needdark
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:CRUNCH)
							end	
							if needfairy
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end
					when :B326H335
						if needfire
							pkmn.forget_move(:EARTHPOWER)
							pkmn.learn_move(:SANDSTORM)
						end
					when :B208H378
						if partypoopers>0
							if needfire
								pkmn.forget_move(:DRAGONPULSE)
								pkmn.learn_move(:FLASHCANNON)
								pkmn.forget_move(:EARTHPOWER)
								pkmn.learn_move(:MYSTICALFIRE)
							else
								pkmn.forget_move(:DRAGONPULSE)
								pkmn.learn_move(:FLASHCANNON)
								pkmn.forget_move(:EARTHPOWER)
								pkmn.learn_move(:TOXIC)
							end	
						end	
					# Chuck	
					when :B169H106
						if partypoopers>2
							pkmn.forget_move(:FAKEOUT)
							pkmn.learn_move(:BLAZEKICK)
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								pkmn.forget_move(:FAKEOUT)
								pkmn.learn_move(:BLAZEKICK)
								if needdark
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:EARTHQUAKE)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:FAKEOUT)
								pkmn.learn_move(:TOXIC)
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:FAKEOUT)
								pkmn.learn_move(:BLAZEKICK)
							end
							if needdark
								pkmn.forget_move(:FAKEOUT)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:FAKEOUT)
								pkmn.learn_move(:TOXIC)
							end	
						end
					when :B135H296
						if partypoopers>2
							pkmn.forget_move(:THUNDER)
							pkmn.learn_move(:BLAZEKICK)
							pkmn.forget_move(:FLASHCANNON)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1 
							if needfire && needfairy
								pkmn.forget_move(:THUNDER)
								pkmn.learn_move(:BLAZEKICK)
								pkmn.forget_move(:DARKPULSE)
								pkmn.learn_move(:TOXIC)
							else
								if needfire
									pkmn.forget_move(:THUNDER)
									pkmn.learn_move(:BLAZEKICK)
								end
								if needfairy
									pkmn.forget_move(:THUNDER)
									pkmn.learn_move(:TOXIC)
								end	
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:THUNDER)
								pkmn.learn_move(:BLAZEKICK)
							end
							if needfairy
								pkmn.forget_move(:THUNDER)
								pkmn.learn_move(:TOXIC)
							end	
						end
					when :B321H377
						if partypoopers>1
							pkmn.item = :LIFEORB
							pkmn.forget_move(:SWORDSDANCE)
							pkmn.learn_move(:WILLOWISP)
						elsif partypoopers>0
							if needfire
								pkmn.item = :LIFEORB
								pkmn.forget_move(:SWORDSDANCE)
								pkmn.learn_move(:FLAREBLITZ)
							end
							if needfairy
								pkmn.item = :LIFEORB
								pkmn.forget_move(:SWORDSDANCE)
								pkmn.learn_move(:WILLOWISP)
							end	
						end	
					when :B337H237
						if needdark && needfairy
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:TOXIC)
						else
							if needdark
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:THIEF)
							end
							if needfairy
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:TOXIC)
							end	
						end
					when :B355H212
						if partypoopers>0 || needsomething
							pkmn.forget_move(:MACHPUNCH)
							pkmn.learn_move(:LEECHSEED)
						end	
					when :B267H62
						if partypoopers>2
							pkmn.forget_move(:ICEPUNCH)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								if needdark
									pkmn.forget_move(:ICEPUNCH)
									pkmn.learn_move(:DARKESTLARIAT)
								end	
								if needfairy
									pkmn.forget_move(:ICEPUNCH)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:TOXIC)
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:DARKESTLARIAT)
							end
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:DARKESTLARIAT)
							end	
							if needfairy
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:TOXIC)
							end	
						end
					# Gold
					when :B150H275
						if partypoopers>2
							pkmn.forget_move(:PSYSTRIKE)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								if needdark
									pkmn.forget_move(:PSYSTRIKE)
									pkmn.learn_move(:DARKPULSE)
								end	
								if needfairy
									pkmn.forget_move(:PSYSTRIKE)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:FIREBLAST)
								pkmn.learn_move(:TOXIC)
								pkmn.forget_move(:PSYSTRIKE)
								pkmn.learn_move(:DARKPULSE)
							end
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:PSYSTRIKE)
								pkmn.learn_move(:DARKPULSE)
							end	
							if needfairy
								pkmn.forget_move(:PSYSTRIKE)
								pkmn.learn_move(:TOXIC)
							end	
						end
					when :B245H154
						if partypoopers>0 || needsomething
							pkmn.forget_move(:BLIZZARD)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B244H160
						if needdark || needfairy || needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end	
					when :B243H157
						if needdark || needfairy
							pkmn.item == :LIFEORB
							pkmn.forget_move(:ERUPTION)
							pkmn.learn_move(:WILLOWISP)
						end	
					when :B142H250
						if needdark || needfairy || needsomething
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end	
					# Dem
					when :B135H94
						if partypoopers>0 || needsomething
							pkmn.forget_move(:ENERGYBALL)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B309H242
						if partypoopers>2
							pkmn.forget_move(:BULKUP)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								if needdark
									pkmn.forget_move(:DRAINPUNCH)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:DRAINPUNCH)
									pkmn.learn_move(:PLAYROUGH)
								end	
							else
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:KNOCKOFF)
								pkmn.forget_move(:DRAINPUNCH)
								pkmn.learn_move(:PLAYROUGH)
							end
						elsif partypoopers>0
							if needdark
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:FIREPUNCH)
								pkmn.learn_move(:PLAYROUGH)
							end	
						end
					#when :B169H106 see chuck
					when :B254H381
						if needfairy
							pkmn.forget_move(:AGILITY)
							pkmn.learn_move(:PLAYROUGH)
						end	
					when :B262H288
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREPUNCH)
							pkmn.forget_move(:ZENHEADBUTT)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
								if needdark
									pkmn.forget_move(:ZENHEADBUTT)
									pkmn.learn_move(:KNOCKOFF)
								end	
								if needfairy
									pkmn.forget_move(:ZENHEADBUTT)
									pkmn.learn_move(:DAZZLINGGLEAM)
								end	
							else
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
								pkmn.forget_move(:ZENHEADBUTT)
								pkmn.learn_move(:DAZZLINGGLEAM)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREPUNCH)
							end	
							if needdark
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:KNOCKOFF)
							end	
							if needfairy
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:DAZZLINGGLEAM)
							end	
						end
					when :B208H184
						if partypoopers>2
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:FIREFANG)
							pkmn.forget_move(:ICEPUNCH)
							pkmn.learn_move(:KNOCKOFF)
						elsif partypoopers>1
							if needfire	
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREFANG)
								if needdark
									pkmn.forget_move(:ICEPUNCH)
									pkmn.learn_move(:KNOCKOFF)
								end	
							else
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:KNOCKOFF)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:EARTHQUAKE)
								pkmn.learn_move(:FIREFANG)
							end	
							if needdark
								pkmn.forget_move(:ICEPUNCH)
								pkmn.learn_move(:KNOCKOFF)
							end	
						end
					when :B195H250
						if needdark || needfairy
							pkmn.forget_move(:STONEEDGE)
							pkmn.learn_move(:WILLOWISP)
						end
					# Final Dem
					when :B150H340
						if partypoopers>0 || needsomething
							pkmn.forget_move(:THUNDER)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B350H242
						if partypoopers>0 || needsomething
							pkmn.ability = :TERAVOLT
							pkmn.forget_move(:HEADBUTT)
							pkmn.learn_move(:FRUSTRATION)
						end
					when :B315H184
						if partypoopers>0
							pkmn.forget_move(:EARTHQUAKE)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B249H343
						if partypoopers>0
							pkmn.item = :LEPPABERRY
							pkmn.forget_move(:AURASPHERE)
							pkmn.learn_move(:HAIL)
						end
					when :B341H250
						if needdark || needfairy || needsomething
							pkmn.forget_move(:ROCKPOLISH)
							pkmn.learn_move(:SUNSTEELSTRIKE)
						end
					# Cynthia
					when :B269H347
						if partypoopers>0
							pkmn.ability == :BADDREAMS
						end
					when :B352H343
						if partypoopers>0 || needsomething
							pkmn.forget_move(:SLUDGEBOMB)
							pkmn.learn_move(:FLASHCANNON)
							pkmn.forget_move(:BLIZZARD)
							pkmn.learn_move(:LEECHSEED)
						end
					when :B275H344
						if partypoopers>2
							pkmn.forget_move(:AGILITY)
							pkmn.learn_move(:FLAMETHROWER)
							pkmn.forget_move(:CALMMIND)
							pkmn.learn_move(:TOXIC)
						elsif partypoopers>1
							if needfire	
								pkmn.forget_move(:AGILITY)
								pkmn.learn_move(:FLAMETHROWER)
								if needdark
									pkmn.forget_move(:CALMMIND)
									pkmn.learn_move(:DARKPULSE)
								end	
								if needfairy
									pkmn.forget_move(:CALMMIND)
									pkmn.learn_move(:TOXIC)
								end	
							else
								pkmn.forget_move(:AGILITY)
								pkmn.learn_move(:DARKPULSE)
								pkmn.forget_move(:CALMMIND)
								pkmn.learn_move(:TOXIC)
							end
						elsif partypoopers>0
							if needfire
								pkmn.forget_move(:AGILITY)
								pkmn.learn_move(:FLAMETHROWER)
							end
							if needdark
								pkmn.forget_move(:AGILITY)
								pkmn.learn_move(:DARKPULSE)
							end	
							if needfairy
								pkmn.forget_move(:AGILITY)
								pkmn.learn_move(:TOXIC)
							end	
						end
					when :B345H335
						if partypoopers>0
							pkmn.forget_move(:CALMMIND)
							pkmn.learn_move(:WILLOWISP)
						end
					when :B299H315
						if partypoopers>0
							pkmn.forget_move(:THUNDER)
							pkmn.learn_move(:WILLOWISP)
						end
					
					# Pokemon specific Shedproofing End
					end
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