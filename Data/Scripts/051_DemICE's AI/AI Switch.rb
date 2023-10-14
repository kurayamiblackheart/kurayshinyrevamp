class PokeBattle_AI
	
	def pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
		party = @battle.pbParty(idxBattler)
		return false if party.length == 1
		return false if @battle.wildBattle?
		return false if !@battle.pbCanSwitch?(idxBattler)
		shouldSwitch = forceSwitch
		batonPass = -1
		moveType = nil
		skill = 100#@battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
		battler = @battle.battlers[idxBattler]
		if $PokemonSystem.autobattler && $PokemonSystem.autobattler != 0 && @battle.turnCount>0
			if battler.turnCount == 0
				echo("\nSwitch prevented due to the battler being on its first turn out, during auto-battling.\n")
				return false 
			end
		end
		# If Pokémon is within 6 levels of the foe, and foe's last move was
		# super-effective and powerful
		if !shouldSwitch && battler.turnCount > 0 && skill >= PBTrainerAI.highSkill
			target = battler.pbDirectOpposing(true)
			if !target.fainted? && target.lastMoveUsed &&
				(target.level - battler.level).abs <= 6
				moveData = GameData::Move.get(target.lastMoveUsed)
				moveType = moveData.type
				typeMod = pbCalcTypeMod(moveType, target, battler)
				if Effectiveness.super_effective?(typeMod) && moveData.base_damage > 50
					switchChance = (moveData.base_damage > 70) ? 30 : 20
					if switchChance>80 #(pbAIRandom(100) < switchChance) # DemICE removing randomness
						shouldSwitch = true 
						echo("If you ever see this message, you are witnessing a miracle. Start praying.\n")
					end	
				end
			end
		end
		tickdamage=false
		maxdam=0
		maxdampercent=0
		maxspeed=0
		aspeed = pbRoughStat(battler,:SPEED,100)
		battler.eachOpposing do |b|
			ospeed = pbRoughStat(b,:SPEED,100)
			maxspeed = ospeed if ospeed>maxspeed
			for j in battler.moves
				if (j.function=="006" && b.pbCanPoison?(battler,false,j)) ||# Toxic
					(j.name=="Will-O-Wisp" && b.pbCanBurn?(battler,false,j)) ||# Willo
					(j.function=="0DC" && !b.pbHasType?(:GRASS) && b.effects[PBEffects::Substitute]<=0) # Leech Seed
					tickdamage=true
				end	
				if b.hp==1
					tickdamage=true if j.function=="102" && !b.pbHasType?(:ICE)
					tickdamage=true if j.function=="101" && !b.pbHasType?(:ROCK) && !b.pbHasType?(:GROUND) && !b.pbHasType?(:STEEL)
					tickdamage=true if j.function=="105" && !battler.pbOpposingSide.effects[PBEffects::StealthRock]
					tickdamage=true if j.function=="0EB" && !b.effects[PBEffects::Ingrain]
					tickdamage=true if j.function=="067"
					tickdamage=true if j.function=="068"
					tickdamage=true if j.function=="10E"
					tickdamage=true if j.function=="061"
					tickdamage=true if j.function=="10F" && battler.pbHasMoveFunction?("003","004") && b.pbCanSleep?(battler,false,j)
				end	
				tempdam = pbRoughDamage(j,battler,b,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,battler,b,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			opphpchange=(EndofTurnHPChanges(b,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
			tickdamage=true if opphpchange<1 || b.status == :POISON
			maxdampercent = maxdam *100.0 / b.hp
		end	
		mindamage=10
		if battler.effects[PBEffects::LeechSeed]>=0 && (battler.hp > battler.totalhp*0.66)
			mindamage=33 
			if battler.status==:SLEEP && battler.statusCount>1
				mindamage=50
				mindamage=100 if ((maxspeed>aspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			end	
		end	
		if maxdampercent<mindamage && !tickdamage
			shouldSwitch=true 
			echo("Switching because of dealing little to no direct or indirect damage.\n")
		end	
		# Pokémon can't do anything (must have been in battle for at least 5 rounds)
		if !@battle.pbCanChooseAnyMove?(idxBattler) &&
			battler.turnCount && battler.turnCount >= 5
			shouldSwitch = true
			echo("Switching because 5 turns of nothing.\n")
		end
		# Pokémon is Perish Songed and has Baton Pass
		if skill >= PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong] == 1
			battler.eachMoveWithIndex do |m, i|
				next if m.function != "0ED"   # Baton Pass
				next if !@battle.pbCanChooseMove?(idxBattler, i, false)
				batonPass = i
				shouldSwitch = true
				echo("Switching because of perish song.\n")
				break
			end
		end
		# Pokémon will faint because of bad poisoning at the end of this round, but
		# would survive at least one more round if it were regular poisoning instead
		#   if battler.status == :POISON && battler.statusCount > 0 &&
		#      skill >= PBTrainerAI.highSkill
		#     toxicHP = battler.totalhp / 16
		#     nextToxicHP = toxicHP * (battler.effects[PBEffects::Toxic] + 1)
		#     if battler.hp <= nextToxicHP && battler.hp > toxicHP * 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
		#       shouldSwitch = true
		#     end
		#   end
		# Pokémon is Encored into an unfavourable move
		if battler.effects[PBEffects::Encore] > 0 && skill >= PBTrainerAI.mediumSkill
			idxEncoredMove = battler.pbEncoredMoveIndex
			if idxEncoredMove >= 0
				scoreSum   = 0
				scoreCount = 0
				battler.allOpposing.each do |b|
					scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove], battler, b, skill)
					scoreCount += 1
				end
				if scoreCount > 0 && scoreSum / scoreCount <= 120 #&& pbAIRandom(100) < 80 # DemICE removing randomness
					shouldSwitch = true if battler.hp>battler.totalhp/2
					echo("Switching because of being encored into a bad move.\n")
				end
			end
		end
		if battler.effects[PBEffects::ChoiceBand] &&
			battler.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
			if battler.lastMoveUsed && battler.pbHasMove?(battler.lastMoveUsed)
				choicedmove=nil
				for choice in battler.moves
					next if choice.id!=battler.lastMoveUsed
					choicedmove=choice
				end
				scoreSum   = 0
				scoreCount = 0
				battler.allOpposing.each do |b|
					scoreSum += pbGetMoveScore(choicedmove, battler, b, skill)
					scoreCount += 1
				end
				if scoreCount > 0 && scoreSum / scoreCount <= 120 #&& pbAIRandom(100) < 80 # DemICE removing randomness
					shouldSwitch = true if battler.hp>battler.totalhp/3
					echo("Switching because of being choice locked into a bad move.\n")
				end
			end
		end
		# If there is a single foe and it is resting after Hyper Beam or is
		# Truanting (i.e. free turn)
		# if @battle.pbSideSize(battler.index + 1) == 1 &&
		# 	!battler.pbDirectOpposing.fainted? && skill >= PBTrainerAI.highSkill
		# 	opp = battler.pbDirectOpposing
		# 	if (opp.effects[PBEffects::HyperBeam] > 0 ||
		# 			(opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])) #&& pbAIRandom(100) < 80 # DemICE removing randomness
		# 		shouldSwitch = false
		# 	end
		# end
		# Sudden Death rule - I'm not sure what this means
		if @battle.rules["suddendeath"] && battler.turnCount > 0
			if battler.hp <= battler.totalhp / 4 #&& pbAIRandom(100) < 30 # DemICE removing randomness
				shouldSwitch = true
				echo("The fuck's a sudden death\n")
			elsif battler.hp <= battler.totalhp / 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
				shouldSwitch = true
				echo("The fuck's a sudden death\n")
			end
		end
		# Pokémon is about to faint because of Perish Song
		if battler.effects[PBEffects::PerishSong] == 1
			shouldSwitch = true
			echo("Switching because of perish song.\n")
		end
		#incoming = [nil,0]
		incoming = nil
		weight = 1
		canheswitch=false
		party.each_with_index do |_pkmn, i|
			canheswitch=true if @battle.pbCanHardSwitchLax?(idxBattler, i)
		end
		shouldSwitch=false if !canheswitch
		newindex=pbHardSwitchChooseNewEnemy(idxBattler,party,true) if shouldSwitch
		if newindex
			if newindex.is_a?(Array)
				swapper=newindex[0]
			else
				swapper=newindex
			end
			if swapper==battler.pokemonIndex && shouldSwitch	
				echo("\nRegretting the switch because there is no good pokmon to hard switch in.\n")
				shouldSwitch=false 
			end
		else
			shouldSwitch=false 	
		end
		if shouldSwitch
			incoming=swapper
			# idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
			# @battle.pbParty(idxBattler).each_with_index do |pkmn, i|
			# 	next if i == idxPartyEnd - 1   # Don't choose to switch in ace
			# 	next if !@battle.pbCanSwitch?(idxBattler, i)
			# 	# If perish count is 1, it may be worth it to switch
			# 	# even with Spikes, since Perish Song's effect will end
			# 	if battler.effects[PBEffects::PerishSong] != 1
			# 		# Will contain effects that recommend against switching
			# 		spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
			# 		# Don't switch to this if too little HP
			# 		if spikes > 0
			# 			spikesDmg = [8, 6, 4][spikes - 1]
			# 			next if pkmn.hp <= pkmn.totalhp / spikesDmg &&
			# 			!pkmn.hasType?(:FLYING) && !pkmn.hasActiveAbility?(:LEVITATE)
			# 		end
			# 	end
			# 	# moveType is the type of the target's last used move
			# 	if moveType && Effectiveness.ineffective?(pbCalcTypeMod(moveType, battler, battler))
			# 		weight = 65
			# 		typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
			# 		if Effectiveness.super_effective?(typeMod)
			# 			# Greater weight if new Pokemon's type is effective against target
			# 			weight = 85
			# 		end
			# 		#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
			# 	elsif moveType && Effectiveness.resistant?(pbCalcTypeMod(moveType, battler, battler))
			# 		weight = 40
			# 		typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
			# 		if Effectiveness.super_effective?(typeMod)
			# 			# Greater weight if new Pokemon's type is effective against target # DemICE removing randomness
			# 			weight = 60
			# 		end
			# 		#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
			# 	else
			# 		#list.push(i)   # put this Pokemon last # DemICE removing randomness
			# 	end
			# 	incoming=[i,weight] if weight > incoming[1] # DemICE new way of determining what pokemon to switch in
			#end
			#if list.length > 0 # DemICE removing randomness
			if batonPass >= 0 && @battle.pbRegisterMove(idxBattler, batonPass, false)
				PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
				return true
			end
			if @battle.pbRegisterSwitch(idxBattler, incoming)#[0]) # DemICE Applying the new way to determine the next switch-in
				PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
					@battle.pbParty(idxBattler)[incoming].name)#[incoming[0]].name)
				return true
			end
			#end
		end
		return false
	end
	
	#=============================================================================
	# Choose a replacement Pokémon
	#=============================================================================
	def pbHardSwitchChooseNewEnemy(idxBattler,party,sack=false,batonpasscheck=false)
		enemies = []
		activemon=-1
		party.each_with_index do |_p,i|
			activemon=i if i==@battle.battlers[idxBattler].pokemonIndex && sack
			enemies.push(i) if @battle.pbCanHardSwitchLax?(idxBattler,i)
		end
		return -1 if enemies.length==0
		return pbChooseBestNewEnemy(idxBattler,party,enemies,sack,activemon,batonpasscheck)
	end
	
	
	#=============================================================================
	# Choose a replacement Pokémon
	#=============================================================================
	def pbChooseBestNewEnemy(idxBattler, party, enemies, sack=false, activemon=-1, batonpasscheck=false)
		return -1 if !enemies || enemies.length == 0
		best    = -1
		bestSum = 0
		enemies.each do |i|
			#pokmon = party[i]
			pokmon = @battle.pbMakeFakeBattler(party[i],batonpasscheck,@battle.battlers[idxBattler]) 
			#if $consoleenabled
				echo("\nSwitch score for: "+pokmon.name)
				echo("\n----------------------------------------\n")
			#end	
			sum  = 0
			if PluginManager.installed?("Mid Battle Dialogue")
				if BattleScripting.hasAceData?
					aceId = BattleScripting.getAceOf(idxBattler)
					next if aceId > -1 && i == aceId && @battle.pbAbleCount(idxBattler) != 1
				end
			end
			maxdam=0
			aspeed = pbRoughStat(pokmon,:SPEED,100)
			maxspeed = 0
			hasprio=0
			priodamage=0
			damagetakenPercent=0
			priodamagepercent=0
			death=false	
			roomturn=0
			roomturn=1 if sack
			pokmon.eachOpposing do |newenemy|
				ospeed = pbRoughStat(newenemy,:SPEED,100)
				if pokmon.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain
					ospeed *= 2 if newenemy.hasActiveAbility?(:SWIFTSWIM)
				end
				if pokmon.hasActiveAbility?([:DROUGHT,:ORICHALCUMPULSE]) && @battle.pbWeather != :Sun
					ospeed *= 2 if newenemy.hasActiveAbility?([:CHLOROPHYLL,:PROTOSYNTHESIS])
				end
				if pokmon.hasActiveAbility?(:SANDSTREAM) && @battle.pbWeather != :Sandstorm 
					ospeed *= 2 if newenemy.hasActiveAbility?(:SANDRUSH)
				end
				if pokmon.hasActiveAbility?(:SNOWWARNING) && @battle.pbWeather != :Hail 
					ospeed *= 2 if newenemy.hasActiveAbility?(:SLUSHRUSH)
				end
				if pokmon.hasActiveAbility?([:ELECTRICSURGE,:HADRONENGINE]) && @battle.field.terrain != :Electric
					ospeed *= 2 if newenemy.hasActiveAbility?(:SURGESURFER)
				end
				for j in newenemy.moves
					mold_broken=moldbroken(newenemy,pokmon,j.function)
					if moveLocked(newenemy)
						if newenemy.lastMoveUsed && newenemy.pbHasMove?(newenemy.lastMoveUsed)
							next if j.id!=newenemy.lastMoveUsed
						end
					end	
					if (j.function=="006" && pokmon.pbCanPoison?(newenemy,false,j)) ||# Toxic
						(j.name=="Will-O-Wisp" && pokmon.pbCanBurn?(newenemy,false,j)) ||# Willo
						(j.function=="0DC" && !pokmon.pbHasType?(:GRASS) && pokmon.effects[PBEffects::Substitute]<=0) # Leech Seed
						death=true	
					end	
					tempdam = pbRoughDamage(j,newenemy,pokmon,100)
					if pbCheckMoveImmunity(1,j,newenemy,pokmon,100) || 
						(newenemy.status==:SLEEP && newenemy.statusCount>1 && !newenemy.pbHasMoveFunction?("0B4", "011"))
						tempdam = 0 
					else
						if !mold_broken && pokmon.hasActiveAbility?(:DISGUISE) && pokmon.turnCount==0	
							if ["0C0", "0BD", "175", "0BF"].include?(j.function)
								tempdam*=0.6
							else
								tempdam=1
							end
						end	
						if pokmon.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain 
							tempdam*=1.5 if j.type == :WATER
							tempdam*=0.5 if j.type == :FIRE
						end
						if pokmon.hasActiveAbility?([:DROUGHT,:ORICHALCUMPULSE]) && @battle.pbWeather != :Sun
							tempdam*=1.5 if j.type == :FIRE
							tempdam*=0.5 if j.type == :WATER
							tempdam*=1.33 if newenemy.hasActiveAbility?(:ORICHALCUMPULSE) && j.physicalMove?
							tempdam*=1.5 if newenemy.hasActiveAbility?(:SOLARPOWER) && j.specialMove?
						end
						if pokmon.hasActiveAbility?(:SANDSTREAM) && @battle.pbWeather != :Sandstorm 
							tempdam*=0.67 if pokmon.pbHasType?(:ROCK) && j.specialMove?
							tempdam*=1.3 if [:GROUND,:ROCK,:STEEL].include?(j.type) && newenemy.hasActiveAbility?(:SANDFORCE)
						end
						if pokmon.hasActiveAbility?([:ELECTRICSURGE,:HADRONENGINE]) && @battle.field.terrain != :Electric
							if j.type == :ELECTRIC && newenemy.affectedByTerrain?
								tempdam*=1.5 
								tempdam*=1.33 if newenemy.hasActiveAbility?(:HADRONENGINE) && j.specialMove?
							end
							tempdam*=1.6 if j.function=="DoublePowerInElectricTerrain"
							tempdam*=0.67 if pokmon.hasActiveItem?(:ELECTRICSEED) && j.physicalMove?
						end
						if pokmon.hasActiveAbility?(:GRASSYSURGE) && @battle.field.terrain != :Grassy
							if j.type == :GRASS && newenemy.affectedByTerrain?
								tempdam*=1.5 
							end
							if ["076","095","044"].include?(j.function)
								tempdam*=0.5
							end
							tempdam*=0.67 if pokmon.hasActiveItem?(:GRASSYSEED) && j.physicalMove?
						end
						if pokmon.hasActiveAbility?(:PSYCHICSURGE) && @battle.field.terrain != :Psychic
							if j.type == :PSYCHIC && newenemy.affectedByTerrain?
								tempdam*=1.5 
							end
							tempdam*=1.3 if j.function=="HitsAllFoesAndPowersUpInPsychicTerrain"
							tempdam*=0.67 if pokmon.hasActiveItem?(:PSYCHICSEED) && j.specialMove?
						end
						if pokmon.hasActiveAbility?(:MISTYSURGE) && @battle.field.terrain != :Misty
							if j.type == :DRAGON && pokmon.affectedByTerrain?
								tempdam*=0.5 
							end
							tempdam*=0.67 if pokmon.hasActiveItem?(:MISTYSEED) && j.specialMove?
						end
						if pokmon.hasActiveAbility?(:INTIMIDATE) && 
							newenemy.pbCanLowerAttackStatStageIntimidateAI(pokmon)
							if j.physicalMove?
								if newenemy.hasActiveAbility?([:DEFIANT,:CONTRARY])
									tempdam*=1.5
								else
									tempdam*=0.67 
								end
							end
							if j.specialMove? && newenemy.hasActiveAbility?(:COMPETITIVE)
								tempdam*=2
							end
						end
						thisprio = priorityAI(newenemy,j)
						if thisprio>0 
							tempdam=0 if pokmon.hasActiveAbility?(:PSYCHICSURGE) && pokmon.affectedByTerrain?
							hasprio=thisprio
							priodamage=tempdam if tempdam>priodamage
						end		
						maxdam=tempdam if tempdam>maxdam
					end 
					maxspeed = ospeed if ospeed>maxspeed
				end	
			end
			damagetakenPercent = maxdam *100.0 / pokmon.hp
			priodamagepercent = priodamage *100.0 / pokmon.hp
			if damagetakenPercent>100
				damagetakenPercent =100 
				damagetakenPercent =99 if (pokmon.hasActiveItem?(:FOCUSSASH) || pokmon.hasActiveAbility?(:STURDY)) && (pokmon.hp==pokmon.totalhp)
			end	
			damagetakenPercent = 100 if pokmon.hasActiveAbility?(:WONDERGUARD) && death
			maxscore=0
			scoresum=0
			damagesum=0
			ownmaxdmg=0
			ownmaxmove=nil
			tickdamage=false
			maxprio=0
			fakedmg=0
			damagedealtPercent=0
			pokmon.moves.each do |m|
				pokmon.eachOpposing do |b|
					mold_broken=moldbroken(pokmon,b,m.function)
					if (m.function=="006" && b.pbCanPoison?(pokmon,false,m)) ||# Toxic
						(m.name=="Will-O-Wisp" && b.pbCanBurn?(pokmon,false,m)) ||# Willo
						(m.function=="0DC" && !b.pbHasType?(:GRASS) && b.effects[PBEffects::Substitute]<=0) # Leech Seed
						tickdamage=true
						sum+=150
						if pokmon.pbHasMoveFunction?(
								"0D5", "0D6",  #  Recovery
								"0D8", "16D", "0D9")  # Synthesis, Shore up , Rest
							if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn))
								sum+=40 if damagetakenPercent<50
							else	
								sum+=40 if damagetakenPercent<33
							end	
						end		
					end		
					#  Recovery
					if ["0D5", "0D6", "0D8", "16D", "0D9"].include?(m.function)
						if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn))
							sum+=80 if damagetakenPercent<50
						else	
							sum+=80 if damagetakenPercent<33
						end	
					end
					#  Sleep
					# if m.function=="003" && b.pbCanSleep?(pokmon,false,m) && !(m.powderMove? && b.pbHasType?(:GRASS)) && i!=party.length-1
					# 	willwakeup=false
					# 	willwakeup=true if  (b.hasActiveItem?(:LUMBERRY) && b.hasActiveItem?(:CHESTOBERRY))
					# 	if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn))
					# 		if willwakeup
					# 			sum+=100 if damagetakenPercent<50
					# 		else
					# 			sum+=100
					# 		end		
					# 	else	
					# 		if willwakeup
					# 			sum+=100 if damagetakenPercent<33
					# 		else
					# 			sum+=100 if damagetakenPercent<50
					# 		end	
					# 	end	
					# end
					#next if m.baseDamage == 0
					tempdam = pbRoughDamage(m,pokmon,b,100)
					thisprio = priorityAI(pokmon,m,true)
					tempdam = 0 if thisprio>0 && pokmon.hasActiveAbility?(:PSYCHICSURGE) && b.affectedByTerrain?
					maxprio=thisprio if tempdam>=b.hp && thisprio>0
					tempdam = 0 if pbCheckMoveImmunity(1,m,pokmon,b,100)
					if pokmon.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain 
						tempdam*=1.5 if m.type == :WATER
						tempdam*=0.5 if m.type == :FIRE
					end
					if pokmon.hasActiveAbility?([:DROUGHT,:ORICHALCUMPULSE]) && @battle.pbWeather != :Sun 
						tempdam*=1.5 if m.type == :FIRE
						tempdam*=0.5 if m.type == :WATER
						tempdam*=1.33 if pokmon.hasActiveAbility?(:ORICHALCUMPULSE) && m.physicalMove?
						tempdam*=1.5 if pokmon.hasActiveAbility?(:SOLARPOWER) && m.specialMove?
					end
					if pokmon.hasActiveAbility?(:SANDSTREAM) && @battle.pbWeather != :Sandstorm 
						tempdam*=0.67 if b.pbHasType?(:ROCK) && m.specialMove?
						tempdam*=1.3 if [:GROUND,:ROCK,:STEEL].include?(m.type) && pokmon.hasActiveAbility?(:SANDFORCE)
					end
					if pokmon.hasActiveAbility?([:ELECTRICSURGE,:HADRONENGINE]) && @battle.field.terrain != :Electric
						if m.type == :ELECTRIC && pokmon.affectedByTerrain?
							tempdam*=1.5 
							tempdam*=1.33 if newenemy.hasActiveAbility?(:HADRONENGINE) && m.specialMove?
						end
						tempdam*=1.6 if m.function=="DoublePowerInElectricTerrain"
						tempdam*=0.67 if b.hasActiveItem?(:ELECTRICSEED) && m.physicalMove?
					end
					if pokmon.hasActiveAbility?(:GRASSYSURGE) && @battle.field.terrain != :Grassy
						if m.type == :GRASS && pokmon.affectedByTerrain?
							tempdam*=1.5 
						end
						if ["076","095","044"].include?(m.function)
							tempdam*=0.5
						end
						tempdam*=0.67 if b.hasActiveItem?(:GRASSYSEED) && m.physicalMove?
						tempdam*=0.67 if b.hasActiveAbility?(:GRASSPELT) && m.physicalMove?
					end
					if pokmon.hasActiveAbility?(:PSYCHICSURGE) && @battle.field.terrain != :Psychic
						if m.type == :PSYCHIC && pokmon.affectedByTerrain?
							tempdam*=1.5 
						end
						tempdam*=1.3 if m.function=="HitsAllFoesAndPowersUpInPsychicTerrain"
						tempdam*=0.67 if b.hasActiveItem?(:PSYCHICSEED) && m.specialMove?
					end
					if pokmon.hasActiveAbility?(:MISTYSURGE) && @battle.field.terrain != :Misty
						if m.type == :DRAGON && newenemy.affectedByTerrain?
							tempdam*=0.5 
						end
						tempdam*=0.67 if b.hasActiveItem?(:MISTYSEED) && m.specialMove?
					end
					if !mold_broken && b.hasActiveAbility?(:DISGUISE) && b.turnCount==0	
						if ["0C0", "0BD", "175", "0BF"].include?(m.function)
							tempdam*=2.2
						end
					end	
					if m.function=="012" && tempdam>1 && !b.hasActiveAbility?(:INNERFOCUS) && (b.effects[PBEffects::Substitute] == 0)
						fakedmg = tempdam *100.0 / b.hp
						fakedmg =100 if fakedmg>100
					end
					ownmaxdmg=tempdam if tempdam>ownmaxdmg
					ownmaxmove=m
					damagedealtPercent = ownmaxdmg *100.0 / b.hp
					if m.function=="0ED"
						score=120
					else	
						score=pbGetMoveScore(m, pokmon, b, 100)
					end	
					maxscore=score if score>maxscore
					scoresum+=score
					damagesum+=tempdam 
					#   bTypes = b.pbTypes(true)
					#   sum += Effectiveness.calculate(m.type, bTypes[0], bTypes[1], bTypes[2]) if !pbCheckMoveImmunity(1,m,pokmon,b,100)
				end
				damagedealtPercent+=fakedmg
				damagedealtPercent =100 if damagedealtPercent>100
				if damagesum<=5 || tickdamage
					maxscore=0
					maxscore=0
				end
			end
			sum+=maxscore+(scoresum*0.01) #if damagesum>0 || tickdamage
			if $consoleenabled
				echo("\nScore after factoring offense: "+sum.to_s+" (Maximum potential damage dealt: "+damagedealtPercent.to_s+" percent)")
			end	
			if ownmaxmove
				sum-=100 if (ownmaxmove.physicalMove? && pokmon.stages[:SPECIAL_ATTACK]>0) || (ownmaxmove.specialMove? && pokmon.stages[:ATTACK]>0)
			end	
			willtakedamage=false
			pokmon.eachOpposing do |b|
				if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn)) && (damagedealtPercent>=100 || maxprio>0)
					if hasprio>maxprio
						willtakedamage=true
						damagetakenPercent = priodamagepercent
					else	
						damagetakenPercent = 0
					end	
				else
					if maxprio>hasprio
						damagetakenPercent = 0
					else	
						willtakedamage=true	
					end	
				end	
				
				sum*=(100.1-damagetakenPercent)*0.01
				if pokmon.hasActiveItem?(:AIRBALLOON) && willtakedamage
					othersideindex=pokmon.pbDirectOpposing(true).index
					playerparty = @battle.pbParty(othersideindex)
					groundvar=false
					playerparty.each_with_index do |pkmn, idxParty|
						next if !pkmn ||!pkmn.able?
						next if idxParty==b.pokemonIndex
						pkmn.eachMove do |m|
							next if m.base_damage==0 || m.type != :GROUND
							groundvar=true
						end 
					end 	
					sum-=20 if groundvar  
				end	
			end	
			#if $consoleenabled
				echo("\nScore after factoring defense: "+sum.to_s+" (Maximum expected damage taken: "+damagetakenPercent.to_s+" percent)")
			#end	
			ownparty = @battle.pbParty(1)
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if pkmn==pokmon
				if pokmon.ability==:DROUGHT
					sum+=20 if pkmn.ability == :CHLOROPHYLL
					sum+=10 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER || pkmn.ability == :PROTOSYNTHESIS
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :FIRE
						sum += 10
					end   
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :WATER
						sum -= 5
					end   
					sum+=5 if pkmn.pbHasMoveFunction?("0D8", "028") # Synthesis, Growth
					sum+=10 if pkmn.pbHasMoveFunction?("0C4") # Solarbeam
				end
				if pokmon.ability==:DRIZZLE
					sum+=20 if pkmn.ability == :SWIFTSWIM
					sum+=5 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :WATER
						sum += 10
					end   
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :FIRE
						sum -= 5
					end   
					sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather  == :Sun # Synthesis, Growth,Solarbeam
					sum+=5 if pkmn.pbHasMoveFunction?("008") # Thunder
				end
				if pokmon.ability==:SANDSTREAM
					sum+=20 if pkmn.ability == :SANDRUSH
					sum+=10 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
					sum+=10 if pkmn.hasType?(:ROCK)
					sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather  == :Sun  # Synthesis, Growth,Solarbeam
					sum+=5 if pkmn.pbHasMoveFunction?("16D") # Shore Up
				end
				if pokmon.ability==:SNOWWARNING
					sum+=20 if pkmn.ability == :SLUSHRUSH
					sum+=10 if pkmn.ability == :SNOWCLOAK || pkmn.ability == :ICEBODY
					sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather  == :Sun  # Synthesis, Growth,Solarbeam
					sum+=5 if pkmn.pbHasMoveFunction?("00D") # Blizzard
					sum+=5 if pkmn.pbHasMoveFunction?("167") # Aurora Veil
				end
				if pokmon.ability==:ELECTRICSURGE
					sum+=5 if pkmn.item == :ELECTRICSEED
					sum+=10 if pkmn.ability == :SURGESURFER
					sum+=10 if pkmn.ability == :QUARKDRIVE
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :ELECTRIC
						sum += 5
					end   
					# sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
					# sum+=5 if pkmn.pbHasMoveFunction?("DoublePowerInElectricTerrain") 
				end
				if pokmon.ability==:GRASSYSURGE
					sum+=5 if pkmn.item == :GRASSYSEED
					sum+=5 if pkmn.ability == :GRASSPELT
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :GRASS
						sum += 5
					end   
					score-=5 if pkmn.pbHasMoveFunction?("076","095","044") # Earthquake, Magnitude, Bulldoze
					sum+=5 if pkmn.pbHasMoveFunction?("16E")#,"TypeAndPowerDependOnTerrain") # Floral Healing
					#sum+=5 if pkmn.pbHasMoveFunction?("HigherPriorityInGrassyTerrain") 
				end
				if pokmon.ability==:MISTYSURGE
					sum+=5 if pkmn.item == :MISTYSEED
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :DRAGON
						sum -= 5
					end   
					score-=5 if pkmn.pbHasMoveFunction?("003", "006") # Sleep, Toxic
					#sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "UserFaintsPowersUpInMistyTerrainExplosive")
				end
				if pokmon.ability==:PSYCHICSURGE
					sum+=5 if pkmn.item == :PSYCHICSEED
					sum-=5 if pkmn.ability == :PRANKSTER
					pkmn.eachMove do |m|
						next if m.base_damage==0 || m.type != :PSYCHIC
						sum += 5
					end  
					pkmn.eachMove do |m|
						sum -= 1 if m.priority>0
					end   
					#sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HitsAllFoesAndPowersUpInPsychicTerrain")
				end
			end 
			if batonpasscheck
				sum-=30 if pokmon.hasActiveAbility?(:WONDERGUARD)
			end	
			if i==party.length-1
				if sum>0
					sum-=30
					sum=1 if sum<1
				else
					sum=-1
				end	
			end	
			hazarddamage=0
			if pokmon.takesIndirectDamage?
				if !pokmon.airborne?
					spikesDiv = [8, 6, 4][pokmon.pbOwnSide.effects[PBEffects::Spikes] - 1]
					hazarddamage += pokmon.totalhp/spikesDiv
				end
				if GameData::Type.exists?(:ROCK)
					bTypes = pokmon.pbTypes(true)
					eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
					if !Effectiveness.ineffective?(eff)
						eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
						hazarddamage += pokmon.totalhp * eff / 8
					end  
				end	
			end	
			sum=0 if damagetakenPercent>33 && sack && i!=activemon
			if hazarddamage > pokmon.hp
				sum=0
				sum=2000 if sack && i!=activemon
			end	
			#if $consoleenabled
				echo("\nScore after various other factors: "+sum.to_s+"\n")
			#end	
			if best == -1 || sum > bestSum
				best = i
				bestSum = sum
			end
		end
		echo("\nBest score goes to : "+best.to_s+" with "+bestSum.to_s+"\n")
		return [best,bestSum] if batonpasscheck
		return best
	end
	
end