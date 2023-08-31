class PokeBattle_AI
	
		def pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
			return false if @battle.pbParty(idxBattler).length==1
			return false if @battle.wildBattle?
			return false if @battle.pbCanSwitch?(idxBattler)
			shouldSwitch = forceSwitch
			batonPass = -1
			moveType = nil
			skill = 100#@battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
			battler = @battle.battlers[idxBattler]
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
						shouldSwitch = true if switchChance>80 #(pbAIRandom(100) < switchChance) # DemICE removing randomness
					end
				end
			end
			# Pokémon can't do anything (must have been in battle for at least 5 rounds)
			if !@battle.pbCanChooseAnyMove?(idxBattler) &&
				battler.turnCount && battler.turnCount >= 5
				shouldSwitch = true
			end
			# Pokémon is Perish Songed and has Baton Pass
			if skill >= PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong] == 1
				battler.eachMoveWithIndex do |m, i|
					next if m.function != "0ED"   # Baton Pass
					next if !@battle.pbCanChooseMove?(idxBattler, i, false)
					batonPass = i
					shouldSwitch = true
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
					if scoreCount > 0 && scoreSum / scoreCount <= 20 #&& pbAIRandom(100) < 80 # DemICE removing randomness
						shouldSwitch = true
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
				elsif battler.hp <= battler.totalhp / 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
					shouldSwitch = true
				end
			end
			# Pokémon is about to faint because of Perish Song
			if battler.effects[PBEffects::PerishSong] == 1
				shouldSwitch = true
			end
			incoming = [nil,0]
			weight = 1
			if shouldSwitch
				idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
				@battle.pbParty(idxBattler).each_with_index do |pkmn, i|
					next if i == idxPartyEnd - 1   # Don't choose to switch in ace
					next if !@battle.pbCanSwitch?(idxBattler, i)
					# If perish count is 1, it may be worth it to switch
					# even with Spikes, since Perish Song's effect will end
					if battler.effects[PBEffects::PerishSong] != 1
						# Will contain effects that recommend against switching
						spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
						# Don't switch to this if too little HP
						if spikes > 0
							spikesDmg = [8, 6, 4][spikes - 1]
							next if pkmn.hp <= pkmn.totalhp / spikesDmg &&
							!pkmn.hasType?(:FLYING) && !pkmn.hasActiveAbility?(:LEVITATE)
						end
					end
					# moveType is the type of the target's last used move
					if moveType && Effectiveness.ineffective?(pbCalcTypeMod(moveType, battler, battler))
						weight = 65
						typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
						if Effectiveness.super_effective?(typeMod)
							# Greater weight if new Pokemon's type is effective against target
							weight = 85
						end
						#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
					elsif moveType && Effectiveness.resistant?(pbCalcTypeMod(moveType, battler, battler))
						weight = 40
						typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
						if Effectiveness.super_effective?(typeMod)
							# Greater weight if new Pokemon's type is effective against target # DemICE removing randomness
							weight = 60
						end
						#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
					else
						#list.push(i)   # put this Pokemon last # DemICE removing randomness
					end
					incoming=[i,weight] if weight > incoming[1] # DemICE new way of determining what pokemon to switch in
				end
				#if list.length > 0 # DemICE removing randomness
				if batonPass >= 0 && @battle.pbRegisterMove(idxBattler, batonPass, false)
					PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
					return true
				end
				if @battle.pbRegisterSwitch(idxBattler, incoming[0]) # DemICE Applying the new way to determine the next switch-in
					PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
						@battle.pbParty(idxBattler)[incoming[0]].name)
					return true
				end
				#end
			end
			return false
		end


  #=============================================================================
  # Choose a replacement Pokémon
  #=============================================================================
  def pbChooseBestNewEnemy(idxBattler, party, enemies)
    return -1 if !enemies || enemies.length == 0
    best    = -1
    bestSum = 0
    enemies.each do |i|
      pokmon = party[i]
      sum  = 0
	  if PluginManager.installed?("Mid Battle Dialogue")
		if BattleScripting.hasAceData?
			aceId = BattleScripting.getAceOf(idxBattler)
			next if aceId > -1 && i == aceId && @battle.pbAbleCount(idxBattler) != 1
		end
	  end
	  ownparty = @battle.pbParty(1)
	  ownparty.each_with_index do |pkmn, idxParty|
		  next if !pkmn || !pkmn.able?
		  next if pkmn==pokmon
		  if pokmon.ability==:DROUGHT
			  sum+=10 if pkmn.ability == :CHLOROPHYLL
			  sum+=5 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER || pkmn.ability == :PROTOSYNTHESIS
			  pkmn.eachMove do |m|
				  next if m.base_damage==0 || m.type != :FIRE
				  sum += 5
			  end   
			  pkmn.eachMove do |m|
				  next if m.base_damage==0 || m.type != :WATER
				  sum -= 5
			  end   
			  sum+=5 if pkmn.pbHasMoveFunction?("0D8", "028") # Synthesis, Growth
			  sum+=5 if pkmn.pbHasMoveFunction?("0C4") # Solarbeam
		  end
		  if pokmon.ability==:DRIZZLE
			  sum+=10 if pkmn.ability == :SWIFTSWIM
			  sum+=5 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
			  pkmn.eachMove do |m|
				  next if m.base_damage==0 || m.type != :WATER
				  sum += 5
			  end   
			  pkmn.eachMove do |m|
				  next if m.base_damage==0 || m.type != :FIRE
				  sum -= 5
			  end   
			  sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.field.weather == :Sun # Synthesis, Growth,Solarbeam
			  sum+=5 if pkmn.pbHasMoveFunction?("008") # Thunder
		  end
		  if pokmon.ability==:SANDSTREAM
			  sum+=10 if pkmn.ability == :SANDRUSH
			  sum+=5 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
			  sum+=5 if pkmn.hasType?(:ROCK)
			  sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.field.weather == :Sun  # Synthesis, Growth,Solarbeam
			  sum+=5 if pkmn.pbHasMoveFunction?("16D") # Shore Up
		  end
		  if pokmon.ability==:SNOWWARNING
			  sum+=10 if pkmn.ability == :SLUSHRUSH
			  sum+=10 if pkmn.ability == :SNOWCLOAK || pkmn.ability == :ICEBODY
			  sum-=5 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.field.weather == :Sun  # Synthesis, Growth,Solarbeam
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
			  sum+=5 if pkmn.item == :PSSYCHICSEED
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
      pokmon.moves.each do |m|
        next if m.base_damage == 0
        @battle.battlers[idxBattler].eachOpposing do |b|
			#newenemy = pbMakeFakeBattler(pokmon,false,b)  scrapped for now because too much effort
          bTypes = b.pbTypes(true)
          sum += Effectiveness.calculate(m.type, bTypes[0], bTypes[1], bTypes[2])
        end
      end
      if best == -1 || sum > bestSum
        best = i
        bestSum = sum
      end
    end
    return best
  end
  
end