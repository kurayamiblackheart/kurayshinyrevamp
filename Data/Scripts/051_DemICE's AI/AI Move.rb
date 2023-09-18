$aiberrycheck=false
class PokeBattle_AI

	#=============================================================================
	# Choose an action
	#=============================================================================
	def pbDefaultChooseEnemyCommand(idxBattler)
		#return if pbEnemyShouldUseItem?(idxBattler)
		return if pbEnemyShouldWithdraw?(idxBattler)
		return if @battle.pbAutoFightMenu(idxBattler)
		@battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
		pbChooseMoves(idxBattler)
	end

	#=============================================================================
	# Main move-choosing method (moves with higher scores are more likely to be
	# chosen)
	#=============================================================================
	def pbChooseMoves(idxBattler)
		user        = @battle.battlers[idxBattler]
		wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
		skill       = 0
		if !wildBattler
			skill     = 100#@battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
		end
		# Get scores and targets for each move
		# NOTE: A move is only added to the choices array if it has a non-zero
		#       score.
		choices     = []
		user.eachMoveWithIndex do |_m, i|
			next if !@battle.pbCanChooseMove?(idxBattler, i, false)
			if wildBattler
				pbRegisterMoveWild(user, i, choices)
			else
				pbRegisterMoveTrainer(user, i, choices, skill)
			end
		end

		if !@battle.wildBattle?
			echo("\n\n\nChoices and scores for: "+user.name+"\n")
			echo("----------------------------------------\n")
		end
		# Figure out useful information about the choices
		totalScore = 0
		maxScore   = 0
		choices.each do |c|
			totalScore += c[1]
			if !@battle.wildBattle?
				echo(c[3]+": "+c[1].to_s+"\n")
			end
			maxScore = c[1] if maxScore < c[1]
		end
		echo("\n")
		
		item, idxTarget = pbEnemyItemToUse(idxBattler)
		if item
			if item[0]
				# Determine target of item (always the Pokémon choosing the action)
				useType = GameData::Item.get(item[0]).battle_use
				if [1, 2, 3, 6, 7, 8].include?(useType)   # Use on Pokémon
					idxTarget = @battle.battlers[idxTarget].pokemonIndex   # Party Pokémon
				end
				echo(item[0].name+": "+item[1].to_s)
				# if $consoleenabled
				# 	echo(choices+[item[0],item[1]])
				# end	
				if item[1]>maxScore
					# Register use of item
					@battle.pbRegisterItem(idxBattler,item[0],idxTarget)
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use item #{GameData::Item.get(item[0]).name}")
					return
				end
			end	
		end

		echo("\n\n")

		# if $consoleenabled
		# 	echo(choices)
		# end	

		# Log the available choices
		if $INTERNAL
			logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
			choices.each_with_index do |c, i|
				logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
				logMsg += " (target #{c[2]})" if c[2] >= 0
				logMsg += ", " if i < choices.length - 1
			end
			PBDebug.log(logMsg)
		end
		# Find any preferred moves and just choose from them
		if !wildBattler && skill >= PBTrainerAI.highSkill && maxScore > 100
			#stDev = pbStdDev(choices)
			#if stDev >= 40 && pbAIRandom(100) < 90
			# DemICE removing randomness of AI
			preferredMoves = []
			choices.each do |c|
				next if c[1] < 200 && c[1] < maxScore * 0.8
				#preferredMoves.push(c)
				# DemICE prefer ONLY the best move
				preferredMoves.push(c) if c[1] == maxScore   # Doubly prefer the best move
			end
			if preferredMoves.length > 0
				m = preferredMoves[pbAIRandom(preferredMoves.length)]
				PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
				@battle.pbRegisterMove(idxBattler, m[0], false)
				@battle.pbRegisterTarget(idxBattler, m[2]) if m[2] >= 0
				return
			end
			#end
		end
		# Decide whether all choices are bad, and if so, try switching instead
		if !wildBattler && skill >= PBTrainerAI.highSkill
			badMoves = false
			if ((maxScore <= 20 && user.turnCount > 2) ||
					(maxScore <= 40 && user.turnCount > 5)) #&& pbAIRandom(100) < 80  # DemICE removing randomness
				badMoves = true
			end
			if !badMoves && totalScore < 100 && user.turnCount >= 1
				badMoves = true
				choices.each do |c|
					next if !user.moves[c[0]].damagingMove?
					badMoves = false
					break
				end
				#badMoves = false if badMoves && pbAIRandom(100) < 10 # DemICE removing randomness
			end
			if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
				if $INTERNAL
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
				end
				return
			end
		end
		# If there are no calculated choices, pick one at random
		if choices.length == 0
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
			user.eachMoveWithIndex do |_m, i|
				next if !@battle.pbCanChooseMove?(idxBattler, i, false)
				choices.push([i, 100, -1])   # Move index, score, target
			end
			if choices.length == 0   # No moves are physically possible to use; use Struggle
				@battle.pbAutoChooseMove(user.index)
			end
		end
		# Randomly choose a move from the choices and register it
		randNum = pbAIRandom(totalScore)
		choices.each do |c|
			randNum -= c[1]
			next if randNum >= 0
			@battle.pbRegisterMove(idxBattler, c[0], false)
			@battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
			break
		end
		# Log the result
		if @battle.choices[idxBattler][2]
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
		end
	end
	
	# Trainer Pokémon calculate how much they want to use each of their moves.
	def pbRegisterMoveTrainer(user,idxMove,choices,skill)
		move = user.moves[idxMove]
		target_data = move.pbTarget(user)
		if target_data.num_targets > 1
		# If move affects multiple battlers and you don't choose a particular one
		totalScore = 0
		@battle.eachBattler do |b|
			next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
			score = pbGetMoveScore(move,user,b,skill)
			totalScore += ((user.opposes?(b)) ? score : -score)
		end
		choices.push([idxMove,totalScore,-1,move.name]) if totalScore>0
		elsif target_data.num_targets == 0
		# If move has no targets, affects the user, a side or the whole field
		score = pbGetMoveScore(move,user,user,skill)
		choices.push([idxMove,score,-1,move.name]) if score>0
		else
		# If move affects one battler and you have to choose which one
		scoresAndTargets = []
		@battle.eachBattler do |b|
			next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
			next if target_data.targets_foe && !user.opposes?(b)
			score = pbGetMoveScore(move,user,b,skill)
			scoresAndTargets.push([score,b.index]) if score>0
		end
		if scoresAndTargets.length>0
			# Get the one best target for the move
			scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
			choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1],move.name])
		end
		end
	end

	#=============================================================================
	# Get a score for the given move being used against the given target
	#=============================================================================
	def pbGetMoveScore(move, user, target, skill = 100)
		skill = 100#PBTrainerAI.minimumSkill if skill < PBTrainerAI.minimumSkill
		score = 100
		functionscore = pbGetMoveScoreFunctionCode(score, move, user, target, skill)
		bsdam=move.baseDamage
		bsdiv=15.0/bsdam
		functionscore*= bsdiv if move.baseDamage>50
		#print functionscore
		score+=functionscore
		# A score of 0 here means it absolutely should not be used
		return 0 if score <= 0
		# Adjust score based on how much damage it can deal
		# DemICE moved damage calculation to the beginning
		if move.damagingMove?
			score = pbGetMoveScoreDamage(score, move, user, target, skill)
		else   # Status moves
			# Don't prefer attacks which don't deal damage
			score -= 10
			# Account for accuracy of move
			accuracy = pbRoughAccuracy(move, user, target, skill)
			accuracy*= 1.3 if $game_switches[850] # Endgame Challenge enabled
			accuracy=100 if accuracy>100
			score *= accuracy / 100.0
			score = 0 if score <= 10 && skill >= PBTrainerAI.highSkill
		end
		aspeed = pbRoughStat(user,:SPEED,100)
		ospeed = pbRoughStat(target,:SPEED,100)
		if skill >= PBTrainerAI.mediumSkill
			# Prefer damaging moves if AI has no more Pokémon or AI is less clever  # DemICE this shit does more bad than good.
			# if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 &&
			# !(skill >= PBTrainerAI.highSkill && @battle.pbAbleNonActiveCount(target.idxOwnSide) > 0)
			# if move.statusMove?
			# score /= 1.5
			# elsif target.hp <= target.totalhp / 2
			# score *= 1.5
			# end
			# end
			# Converted all score alterations to multiplicative
			# Don't prefer attacking the target if they'd be semi-invulnerable
			if skill>=PBTrainerAI.highSkill && move.accuracy>0 &&
				(target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
				miss = true
				miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				miss = false if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && move.priority<1
				if miss
					# Knows what can get past semi-invulnerability
					if target.effects[PBEffects::SkyDrop]>=0
						miss = false if move.hitsFlyingTargets?
					else
						if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
							miss = false if move.hitsFlyingTargets?
						elsif target.inTwoTurnAttack?("0CA")          # Dig
							miss = false if move.hitsDiggingTargets?
						elsif target.inTwoTurnAttack?("0CB")          # Dive
							miss = false if move.hitsDivingTargets?
						end
					end
				end
				score *= 0.2 if miss
			end
			# Pick a good move for the Choice items
			if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
				user.hasActiveAbility?(:GORILLATACTICS)
				if move.baseDamage >= 60
					score *= 1.2
				elsif move.damagingMove?
					score *= 1.2
				elsif move.function == "0F2"
					score *= 1.2  # Trick
				else
					score *= 0.8
				end
			end
			# If user is asleep, prefer moves that are usable while asleep
			if user.status == :SLEEP && !move.usableWhenAsleep? && user.statusCount==1 # DemICE check if it'll wake up this turn
				user.eachMove do |m|
					next unless m.usableWhenAsleep?
					score *= 2
					break
				end
			end
			# If user is frozen, prefer a move that can thaw the user
			if user.status == :FROZEN
				if move.thawsUser?
					score *= 2
				else
					user.eachMove do |m|
						next unless m.thawsUser?
						score *= 0.8
						break
					end
				end
			end
			# If target is frozen, don't prefer moves that could thaw them
			if target.status == :FROZEN
				user.eachMove do |m|
					next if m.thawsUser?
					score *= 0.3 if score<120
					break
				end
			end
		end
		# Don't prefer moves that are ineffective because of abilities or effects
		return 0 if pbCheckMoveImmunity(score, move, user, target, skill)
		score = score.to_i
		score = 0 if score < 0
		return score
	end
	
	#=============================================================================
	# Add to a move's score based on how much damage it will deal (as a percentage
	# of the target's current HP)
	#=============================================================================
	def pbGetMoveScoreDamage(score, move, user, target, skill)
		skill=100
		return 0 if score <= 0 || pbCheckMoveImmunity(score,move,user,target,skill)
		# Calculate how much damage the move will do (roughly)
		#baseDmg = pbMoveBaseDamage(move, user, target, skill)
		realDamage = pbRoughDamage(move, user, target, skill)#, baseDmg)  # DemICE Moved the baseDmg calculation inside pbRoughDamage
		#realDamage*=0.9 #DemICE encourage AI to use stronger moves to avoid opponent surviving from low damage roll.
		echo("\n"+move.name+" damage: "+realDamage.to_s+"\n")
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move, user, target, skill)
		accuracy*= 1.3 if $game_switches[850] # Endgame Challenge enabled
		accuracy=100 if accuracy>100
		#realDamage *= accuracy / 100.0 # DemICE
		# Two-turn attacks waste 2 turns to deal one lot of damage
		# if move.chargingTurnMove? || move.function == "0C2"   # Hyper Beam # DemICE this shit does more bad than good.
		# realDamage *= 2 / 3   # Not halved because semi-invulnerable during use or hits first turn
		# end
		# Prefer flinching external effects (note that move effects which cause
		# flinching are dealt with in the function code part of score calculation)
		mold_broken=moldbroken(user,target,move.function)
		if skill>=PBTrainerAI.mediumSkill
			if move.function == "116" # Sucker Punch
				if @battle.choices[0][0]!=:UseMove
				   if pbAIRandom(100) < 50	# Try play "mind games" instead of just getting baited every time.
						echo("\n'Predicting' that opponent will not attack and sucker will fail")
						score=1
						realDamage=0 
				   end
				else
					if @battle.choices[0][1]
						if !@battle.choices[0][2].damagingMove? && pbAIRandom(100) < 50	# Try play "mind games" instead of just getting baited every time.
							 echo("\n'Predicting' that opponent will not attack and sucker will fail")
							 score=1
							 realDamage=0 
						end
					end
				end
			end
			if ((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
				target.effects[PBEffects::Substitute]==0
				canFlinch = false
				if move.canKingsRock? && user.hasActiveItem?([:KINGSROCK,:RAZORFANG])
					canFlinch = true
				end
				if user.hasActiveAbility?(:STENCH) && !move.flinchingMove?
					canFlinch = true
				end
				bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] #* 0.9
				maxmove=bestmove[1]
				if targetSurvivesMove(maxmove,user,target) && canFlinch
					realDamage *= 1.2 if (realDamage *100.0 / maxdam) > 75
					realDamage *= 1.2 if move.function=="175"
					realDamage*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
			end
			# Try make AI not trolled by disguise
			if !mold_broken && target.hasActiveAbility?(:DISGUISE) && target.turnCount==0	
				if ["0C0", "0BD", "175", "0BF"].include?(move.function)
					realDamage*=2.2
				end
			end		
			# Convert damage to percentage of target's remaining HP
			damagePercentage = realDamage * 100.0 / target.hp
			# Don't prefer weak attacks
			#    damagePercentage /= 2 if damagePercentage<20
			# Prefer damaging attack if level difference is significantly high
			#damagePercentage *= 1.2 if user.level - 10 > target.level
			# Adjust score
			if damagePercentage > 100   # Treat all lethal moves the same   # DemICE
				damagePercentage = 110 
				damagePercentage+=50 if move.function == "150"  # DemICE: Fell Stinger should be preferred among other moves that KO
				if ["0DD","14F"].include?(move.function)
					missinghp = (user.totalhp-user.hp) *100.0 / user.totalhp
					damagePercentage += missinghp*0.5
				end  
			end
		end  
		damagePercentage -= 1 if accuracy < 100  # DemICE
		#damagePercentage += 40 if damagePercentage > 100   # Prefer moves likely to be lethal  # DemICE
		score += damagePercentage.to_i
		return score
	end
	
	#=============================================================================
	# Damage calculation
	#=============================================================================
	def pbRoughDamage(move,user,target,skill,baseDmg=0)
		baseDmg = pbMoveBaseDamage(move, user, target, skill)
		# Fixed damage moves
		return baseDmg if move.is_a?(PokeBattle_FixedDamageMove)
		return 0 if baseDmg==0
		# Get the move's type
		type = pbRoughType(move,user,skill)
		typeMod = pbCalcTypeMod(type,user,target)
		##### Calculate user's attack stat #####
		atk = pbRoughStat(user,:ATTACK,skill)
		if move.function=="121"   # Foul Play
			atk = pbRoughStat(target,:ATTACK,skill)
		elsif move.specialMove?(type)
			if move.function=="121"   # Foul Play
				atk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
			else
				atk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
			end
		end
		mold_broken=moldbroken(user,target,move.function)
		##### Calculate target's defense stat #####
		defense = pbRoughStat(target,:DEFENSE,skill)
		if move.specialMove?(type) && move.function!="122"   # Psyshock
			defense = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
		end
		##### Calculate all multiplier effects #####
		multipliers = {
			:base_damage_multiplier  => 1.0,
			:attack_multiplier       => 1.0,
			:defense_multiplier      => 1.0,
			:final_damage_multiplier => 1.0
		}
		# Ability effects that alter damage
		moldBreaker = false
		if skill>=PBTrainerAI.highSkill && target.hasMoldBreaker?
			moldBreaker = true
		end
		if skill>=PBTrainerAI.mediumSkill && user.abilityActive?
			# NOTE: These abilities aren't suitable for checking at the start of the
			#       round.  # DemICE: Some of them, yes.
			abilityBlacklist = [:ANALYTIC,:SNIPER]#,:TINTEDLENS,:AERILATE,:PIXILATE,:REFRIGERATE]
			canCheck = true
			abilityBlacklist.each do |m|
				next if move.id != m
				canCheck = false
				break
			end
			if canCheck
				BattleHandlers.triggerDamageCalcUserAbility(user.ability,
					user,target,move,multipliers,baseDmg,type)
			end
		end
		if skill>=PBTrainerAI.mediumSkill && !moldBreaker
			user.eachAlly do |b|
				next if !b.abilityActive?
				BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
					user,target,move,multipliers,baseDmg,type)
			end
		end
		if skill>=PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
			# NOTE: These abilities aren't suitable for checking at the start of the
			#       round.    #DemICE:  WHAT THE FUCK DO YOU MEAN THEY AREN'T SUITABLE FFS
			# abilityBlacklist = [:FILTER,:SOLIDROCK]
			# canCheck = true
			# abilityBlacklist.each do |m|
			# next if move.id != m
			# canCheck = false
			# break
			# end
			#if canCheck
			BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
				user,target,move,multipliers,baseDmg,type)
			#end
		end
		if skill>=PBTrainerAI.bestSkill && !moldBreaker
			target.eachAlly do |b|
				next if !b.abilityActive?
				BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
					user,target,move,multipliers,baseDmg,type)
			end
		end
		# Item effects that alter damage
		# NOTE: Type-boosting gems aren't suitable for checking at the start of the
		#       round.
		if skill>=PBTrainerAI.mediumSkill && user.itemActive?
			# NOTE: These items aren't suitable for checking at the start of the
			#       round.     #DemICE:  WHAT THE FUCK DO YOU MEAN THEY AREN'T SUITABLE FFS
			# itemBlacklist = [:EXPERTBELT,:LIFEORB]
			# if !itemBlacklist.include?(user.item_id)
			BattleHandlers.triggerDamageCalcUserItem(user.item,
				user,target,move,multipliers,baseDmg,type)
			# end
		end
		if skill>=PBTrainerAI.bestSkill && target.itemActive?
			# NOTE: Type-weakening berries aren't suitable for checking at the start
			#       of the round.
			if target.item && !(target.item.is_berry? && target.item_id!=:CHILANBERRY)
				$aiberrycheck=true
				BattleHandlers.triggerDamageCalcTargetItem(target.item,
					user,target,move,multipliers,baseDmg,type)
				$aiberrycheck=false
			end
		end
		# Global abilities
		if skill>=PBTrainerAI.mediumSkill
			if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
				(@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
				if @battle.pbCheckGlobalAbility(:AURABREAK)
					multipliers[:base_damage_multiplier] *= 2 / 3.0
				else
					multipliers[:base_damage_multiplier] *= 4 / 3.0
				end
			end
		end
		# Parental Bond
		if skill>=PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
			multipliers[:base_damage_multiplier] *= 1.25
		end
		# Me First
		# TODO
		# Helping Hand - n/a
		# Charge
		if skill>=PBTrainerAI.mediumSkill
			if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
				multipliers[:base_damage_multiplier] *= 2
			end
		end
		# Mud Sport and Water Sport
		if skill>=PBTrainerAI.mediumSkill
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
		end
		# Terrain moves
		if skill>=PBTrainerAI.mediumSkill
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
		end
		# Badge multipliers
		if skill>=PBTrainerAI.highSkill
			if @battle.internalBattle
				# Don't need to check the Atk/Sp Atk-boosting badges because the AI
				# won't control the player's Pokémon.
				if target.pbOwnedByPlayer?
					if move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
						multipliers[:defense_multiplier] *= 1.1
					elsif move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
						multipliers[:defense_multiplier] *= 1.1
					end
				end
			end
		end
		# DemICE adding resist berries
		if target.itemActive? && Effectiveness.super_effective?(typeMod)
			case target.item_id
			when :BABIRIBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:STEEL
			when :SHUCABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:GROUND
			when :CHARTIBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:ROCK
			when :CHOPLEBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:FIGHTING
			when :COBABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:FLYING
			when :COLBURBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:DARK
			when :HABANBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:DRAGON
			when :KASIBBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:GHOST
			when :KEBIABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:POISON
			when :OCCABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:FIRE
			when :PASSHOBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:WATER
			when :PAYAPABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:PSYCHIC
			when :RINDOBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:GRASS
			when :ROSELIBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:FAIRY
			when :TANGABERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:BUG
			when :WACANBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:ELECTRIC
			when :YACHEBERRY
				multipliers[:final_damage_multiplier]*=0.5 if type==:ICE
			end
		end   
		#multipliers[:final_damage_multiplier]*=0.5 if type==:NORMAL && target.itemActive?
		# Multi-targeting attacks
		if skill>=PBTrainerAI.highSkill
			if pbTargetsMultiple?(move,user)
				multipliers[:final_damage_multiplier] *= 0.75
			end
		end
		# Weather
		if skill>=PBTrainerAI.mediumSkill
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
				if target.pbHasType?(:ROCK) && move.specialMove?(type) && move.function != "122"   # Psyshock
					multipliers[:defense_multiplier] *= 1.5
				end
			end
		end
		# Critical hits - n/a
		# Random variance - n/a
		# DemICE encourage AI to use stronger moves to avoid opponent surviving from low damage roll.
		multipliers[:final_damage_multiplier] *=0.9 if ($PokemonSystem.damage_variance==1 || game_switches[850])  # If the damage variance is enabled from kuray options.
		# STAB
		if skill>=PBTrainerAI.mediumSkill
			if type && user.pbHasType?(type)
				if user.hasActiveAbility?(:ADAPTABILITY)
					multipliers[:final_damage_multiplier] *= 2
				else
					multipliers[:final_damage_multiplier] *= 1.5
				end
			end
		end
		# Type effectiveness
		if skill>=PBTrainerAI.mediumSkill
			typemod = pbCalcTypeMod(type,user,target)
			multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
		end
		# Burn
		if skill>=PBTrainerAI.highSkill
			if user.status == :BURN && move.physicalMove?(type) &&
				!user.hasActiveAbility?(:GUTS) &&
				!(Settings::MECHANICS_GENERATION >= 6 && move.function == "07E")   # Facade
				multipliers[:final_damage_multiplier] /= 2
			end
		end
		# Aurora Veil, Reflect, Light Screen
		if skill>=PBTrainerAI.highSkill
			if !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
				if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
					if @battle.pbSideBattlerCount(target) > 1
						multipliers[:final_damage_multiplier] *= 2 / 3.0
					else
						multipliers[:final_damage_multiplier] /= 2
					end
				elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
					if @battle.pbSideBattlerCount(target) > 1
						multipliers[:final_damage_multiplier] *= 2 / 3.0
					else
						multipliers[:final_damage_multiplier] /= 2
					end
				elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
					if @battle.pbSideBattlerCount(target) > 1
						multipliers[:final_damage_multiplier] *= 2 / 3.0
					else
						multipliers[:final_damage_multiplier] /= 2
					end
				end
			end
		end
		# Minimize
		if skill>=PBTrainerAI.highSkill
			if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(2)
				multipliers[:final_damage_multiplier] *= 2
			end
		end
		# Move-specific base damage modifiers
		# TODO
		# Move-specific final damage modifiers
		# TODO
		##### Main damage calculation #####
		baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
		atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
		defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
		damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
		damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
		# "AI-specific calculations below"
		# Increased critical hit rates
		if skill>=PBTrainerAI.mediumSkill
			c = 0
			# Ability effects that alter critical hit rate
			if c>=0 && user.abilityActive?
				c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
			end
			if skill>=PBTrainerAI.bestSkill
				if c>=0 && !moldBreaker && target.abilityActive?
					c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
				end
			end
			# Item effects that alter critical hit rate
			if c>=0 && user.itemActive?
				c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
			end
			if skill>=PBTrainerAI.bestSkill
				if c>=0 && target.itemActive?
					c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
				end
			end
			# Other efffects
			c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
			if c>=0
				c += 1 if move.highCriticalRate?
				c += user.effects[PBEffects::FocusEnergy]
				c += 1 if user.inHyperMode? && move.type == :SHADOW
			end
			stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
			stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
			vatk, atkStage = move.pbGetAttackStats(user,target)
			vdef, defStage = move.pbGetDefenseStats(user,target)
			atkmult = 1.0*stageMul[atkStage]/stageDiv[atkStage]
			defmult = 1.0*stageMul[defStage]/stageDiv[defStage]
			if c==3 && 
				!target.hasActiveAbility?(:SHELLARMOR) && !target.hasActiveAbility?(:BATTLEARMOR) && 
				target.pbOwnSide.effects[PBEffects::LuckyChant]==0
				damage = 0.96*damage/atkmult if atkmult<1
				damage = damage*defmult if defmult>1
			end	
			if c>=0
				c = 4 if c>4
				if c>=3
					damage*=1.5
					damage*=1.5 if user.hasActiveAbility?(:SNIPER)
				else
					damage += damage*0.1*c
				end	
			end
		end
		return damage.floor
	end 
	
	
	def moldbroken(attacker,opponent,function="none")
		if (attacker.hasActiveAbility?(:MOLDBREAKER) || attacker.hasActiveAbility?(:TURBOBLAZE) || attacker.hasActiveAbility?(:TERAVOLT) ||
				function=="163") && !opponent.hasActiveAbility?(:FULLMETALBODY) && !opponent.hasActiveAbility?(:SHADOWSHIELD)
			return true
		end
		return false	
	end
	
	#=============================================================================
	# Get a better move's base damage value
	#=============================================================================
	alias stupidity_pbMoveBaseDamage pbMoveBaseDamage
	def pbMoveBaseDamage(move,user,target,skill)
		baseDmg = move.baseDamage
		case move.function
		when "0C1"   # Beat Up #DemICE beat up was being calculated very wrong.
			beatUpList = []
			@battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
				next if !pkmn.able? || pkmn.status != :NONE
				beatUpList.push(i)
			end
			baseDmg=0
			for i in beatUpList
				atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
				baseDmg+= 5+(atk/10)
			end  
			
		else
			baseDmg = stupidity_pbMoveBaseDamage(move,user,target,skill)
		end
		
		return baseDmg
	end
	
	#=============================================================================
	# Immunity to a move because of the target's ability, item or other effects
	#=============================================================================
	def pbCheckMoveImmunity(score,move,user,target,skill)
		type = pbRoughType(move,user,skill)
		typeMod = pbCalcTypeMod(type,user,target)
		mold_broken=moldbroken(user,target,move.function)
		# Type effectiveness
		if Effectiveness.ineffective?(typeMod) || score<=0
			if move.baseDamage>0 || move.name=="Thunder Wave"
				return true
			end
		end	
		# DemICE: Yes i had to move Last Resort here to make its score return 0 otherwise it just never became 0.
		if move.function == "125" 
			hasThisMove = false
			hasOtherMoves = false
			hasUnusedMoves = false
			user.eachMove do |m|
				hasThisMove    = true if m.id == @id
				hasOtherMoves  = true if m.id != @id
				hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
			end
			if !hasThisMove || !hasOtherMoves || hasUnusedMoves
				return true
			end 
		end  
		# Immunity due to ability/item/other effects
		if skill>=PBTrainerAI.mediumSkill
			case type
			when :GROUND
				return true if target.airborne? && !move.hitsFlyingTargets?
			when :FIRE
				return true if target.hasActiveAbility?(:FLASHFIRE,false,mold_broken)
			when :WATER
				return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB],false,mold_broken)
			when :GRASS
				return true if target.hasActiveAbility?(:SAPSIPPER,false,mold_broken)
			when :ELECTRIC
				return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB],false,mold_broken)
			end
			return true if !Effectiveness.super_effective?(typeMod) && move.baseDamage>0 && 
			target.hasActiveAbility?(:WONDERGUARD,false,mold_broken)
			return true if move.damagingMove? && user.index!=target.index && !target.opposes?(user) &&
			target.hasActiveAbility?(:TELEPATHY)
			return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE,false,mold_broken) &&
			target.opposes?(user)
			return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF,false,mold_broken)
			return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF,false,mold_broken)
			if move.powderMove?
				return true if target.pbHasType?(:GRASS)
				return true if target.hasActiveAbility?(:OVERCOAT,false,mold_broken)
				return true if target.hasActiveItem?(:SAFETYGOGGLES)
			end
			return true if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
			!move.ignoresSubstitute?(user) && user.index!=target.index
			return true if Settings::MECHANICS_GENERATION >= 7 && user.hasActiveAbility?(:PRANKSTER) &&
			target.pbHasType?(:DARK) && target.opposes?(user)
			return true if move.priority>0 && @battle.field.terrain == :Psychic &&
			target.affectedByTerrain? && target.opposes?(user)
		end
		return false
	end
	
	
	# NOTE: The AI will only consider using an item on the Pokémon it's currently
	#       choosing an action for.
	def pbEnemyItemToUse(idxBattler)
		return nil if !@battle.internalBattle
		items = @battle.pbGetOwnerItems(idxBattler)
		return nil if !items || items.length==0
		# Determine target of item (always the Pokémon choosing the action)
		idxTarget = idxBattler   # Battler using the item
		battler = @battle.battlers[idxTarget]
		pkmn = battler.pokemon
		# Item categories
		hpItems = {
			:POTION       => 20,
			:SUPERPOTION  => 50,
			:HYPERPOTION  => 200,
			:MAXPOTION    => 999,
			:BERRYJUICE   => 20,
			:SWEETHEART   => 20,
			:FRESHWATER   => 50,
			:SODAPOP      => 60,
			:LEMONADE     => 80,
			:MOOMOOMILK   => 100,
			:ORANBERRY    => 10,
			:SITRUSBERRY  => battler.totalhp/4,
			:ENERGYPOWDER => 50,
			:ENERGYROOT   => 200
		}
		hpItems[:RAGECANDYBAR] = 20 if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
		fullRestoreItems = [
			:FULLRESTORE
		]
		# oneStatusItems = {
		#    :AWAKENING    => :SLEEP,
		#    :CHESTOBERRY  => :SLEEP,
		#    :BLUEFLUTE 	 => :SLEEP,
		#    :ANTIDOTE     => :POISON,
		#    :PECHABERRY   => :POISON,
		#    :BURNHEAL   	 => :BURN,
		#    :RAWSTBERRY   => :BURN,
		#    :PARALYZEHEAL => :PARALYSIS,
		#    :PARLYZHEAL   => :PARALYSIS,
		#    :CHERIBERRY   => :PARALYSIS,
		#    :ICEHEAL      => :FROZEN,
		#    :ASPEARBERRY  => :FROZEN
		# }
		oneStatusItems = [   # Preferred over items that heal all status problems
			:AWAKENING, :CHESTOBERRY, :BLUEFLUTE,
			:ANTIDOTE, :PECHABERRY,
			:BURNHEAL, :RAWSTBERRY,
			:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY,
			:ICEHEAL, :ASPEARBERRY
		]
		allStatusItems = [
			:FULLHEAL, :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE,
			:SHALOURSABLE, :BIGMALASADA, :LUMBERRY, :HEALPOWDER
		]
		allStatusItems.push(:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
		xItems = {
			:XATTACK    => [:ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XATTACK2   => [:ATTACK, 2],
			:XATTACK3   => [:ATTACK, 3],
			:XATTACK6   => [:ATTACK, 6],
			:XDEFENSE   => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XDEFENSE2  => [:DEFENSE, 2],
			:XDEFENSE3  => [:DEFENSE, 3],
			:XDEFENSE6  => [:DEFENSE, 6],
			:XDEFEND    => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XDEFEND2   => [:DEFENSE, 2],
			:XDEFEND3   => [:DEFENSE, 3],
			:XDEFEND6   => [:DEFENSE, 6],
			:XSPATK     => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XSPATK2    => [:SPECIAL_ATTACK, 2],
			:XSPATK3    => [:SPECIAL_ATTACK, 3],
			:XSPATK6    => [:SPECIAL_ATTACK, 6],
			:XSPECIAL   => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XSPECIAL2  => [:SPECIAL_ATTACK, 2],
			:XSPECIAL3  => [:SPECIAL_ATTACK, 3],
			:XSPECIAL6  => [:SPECIAL_ATTACK, 6],
			:XSPDEF     => [:SPECIAL_DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XSPDEF2    => [:SPECIAL_DEFENSE, 2],
			:XSPDEF3    => [:SPECIAL_DEFENSE, 3],
			:XSPDEF6    => [:SPECIAL_DEFENSE, 6],
			:XSPEED     => [:SPEED, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XSPEED2    => [:SPEED, 2],
			:XSPEED3    => [:SPEED, 3],
			:XSPEED6    => [:SPEED, 6],
			:XACCURACY  => [:ACCURACY, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
			:XACCURACY2 => [:ACCURACY, 2],
			:XACCURACY3 => [:ACCURACY, 3],
			:XACCURACY6 => [:ACCURACY, 6],
			:DIREHIT    => [PBEffects::FocusEnergy, 2]
		}
		losthp = battler.totalhp - battler.hp
		preferFullRestore = (battler.hp <= battler.totalhp * 2 / 3 &&
			(battler.status != :NONE || battler.effects[PBEffects::Confusion] > 0))
					
		user=battler
		attacker=battler
		target=battler.pbDirectOpposing(true)
		skill = 100

		hasPhysicalAttack = false
		hasSpecialAttack = false
		canthaw = false
		user.eachMove do |m|
			next if !m.physicalMove?(m.type)
			hasPhysicalAttack = true if m.physicalMove?(m.type)
			hasSpecialAttack = true if m.specialMove?(m.type)
			canthaw = true if m.thawsUser?
			break
		end
		aspeed = pbRoughStat(user,:SPEED,skill)
		ospeed = pbRoughStat(target,:SPEED,skill)
		# Find all usable items
		usableHPItems     = []
		usableStatusItems = []
		usableXItems      = []
		items.each do |i|
			next if !i
			next if !@battle.pbCanUseItemOnPokemon?(i,pkmn,battler,@battle.scene,false)
			next if !ItemHandlers.triggerCanUseInBattle(i,pkmn,battler,nil,
				false,self,@battle.scene,false)
			# Log HP healing items
			if losthp > 0
				power = hpItems[i]
				if power
					usableHPItems.push([i, 5, power])
					next
				end
			end
			# Log Full Restores (HP healer and status curer)
			if losthp > 0 || battler.status != :NONE
				if fullRestoreItems.include?(i)
					usableHPItems.push([i, (preferFullRestore) ? 3 : 7, 999])
					usableStatusItems.push([i, (preferFullRestore) ? 3 : 9])
					next
				end
			end
			# Log single status-curing items
			if oneStatusItems.include?(i)
				usableStatusItems.push([i, 5])
				next
			end
			# Log Full Heal-type items
			if allStatusItems.include?(i)
				usableStatusItems.push([i, 7])
				next
			end
			# Log stat-raising items
			if xItems[i]
				data = xItems[i]
				usableXItems.push([i, battler.stages[data[0]], data[1]])
				next
			end
		end
		# Prioritise using a HP restoration item
		hpitemscore = 0
		if usableHPItems.length>0 #&& (battler.hp<=battler.totalhp/4 ||
			hpitemscore = 100
			#(battler.hp<=battler.totalhp/2 && pbAIRandom(100)<30))
			fastermon=((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			fasterhealing=true
			usableHPItems.sort! { |a,b| (a[1]==b[1]) ? a[2]<=>b[2] : a[1]<=>b[1] }
			prevhpitem = nil
			chosenhpitem=nil
			usableHPItems.each do |i|
				if i[2]>=losthp
					if i[0]==:FULLRESTORE &&
							(
							battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack && 
								(
								(battler.status==:BURN && !battler.hasActiveItem?(:FLAMEORB)) || 
								(battler.status==:POISON && !battler.hasActiveItem?(:TOXICORB))
								)
							) ||  
							(
							battler.hasActiveAbility?(:TOXICBOOST) && hasPhysicalAttack && 
							(battler.status==:POISON && !battler.hasActiveItem?(:TOXICORB))
							) ||  
							(
							battler.hasActiveAbility?(:FLAREBOOST) && hasSpecialAttack && 
							(battler.status==:BURN && !battler.hasActiveItem?(:FLAMEORB))
							) ||  
							(
							battler.hasActiveAbility?(:QUICKFEET)&& 
								(
									(battler.status==:BURN && hasSpecialAttack && !battler.hasActiveItem?(:FLAMEORB)) ||
									(battler.status==:POISON && !battler.hasActiveItem?(:TOXICORB)) ||
									battler.status==:PARALYSIS
								)
							) ||  
							(
							battler.hasActiveAbility?(:MARVELSCALE) && hasSpecialAttack && 
							(battler.status==:BURN && !battler.hasActiveItem?(:FLAMEORB))
							) ||  
							(
							battler.hasActiveAbility?(:POISONHEAL) && 
							(battler.status==:POISON && !battler.hasActiveItem?(:TOXICORB))
							) 

							echo("Will not use Full Restore because the status is beneficial.\n")
							break
		
					end	
					chosenhpitem = i
					break
				end
				chosenhpitem = i
			end
			
				if chosenhpitem
					heal = chosenhpitem[2]
					heal=losthp if heal>losthp
					heal-=battler.totalhp*0.1 if battler.hasActiveItem?(:LIFEORB)
					halfhealth=(user.hp+heal)/2
				echo("healing "+halfhealth.to_s+" of "+battler.totalhp.to_s+"\n")
				bestmove=bestMoveVsTarget(target,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
				#if maxdam>battler.hp
				echo(maxdam.to_s+" expected dmg vs "+heal.to_s+" healing\n")
				if !targetSurvivesMove(maxmove,target,battler)
					echo("user does not survive player's strongest move at current hp")
					echo("\n")
					if maxdam>(battler.hp+heal)
						echo("expected damage is higher than hp after heal")
						echo("\n")
						hpitemscore=0
					else
						echo("expected damage is lower or equal than hp after heal")
						echo("\n")
						if maxdam>=halfhealth
							echo("expected damage is higher than half of hp after heal")
							echo("\n")
							if fasterhealing
								echo("healing will be executed before the player")
								echo("\n")
								hpitemscore*=0.5
							else
								echo("healing will be executed after the player")
								echo("\n")
								hpitemscore*=0.1
							end
						else
							echo("expected damage is lower than half of hp after heal. score doubles")
							echo("\n")
							hpitemscore*=2
						end
					end
				else
					echo("user survives player's strongest move at current hp")
					echo("\n")
					if maxdam*1.5>battler.hp
						echo("expected damage*1.5 is higher than user's current hp. score doubles")
						echo("\n")
						hpitemscore*=2
					end
					if !fastermon
						echo("user is slower than player's mon")
						echo("\n")
						if maxdam*2>battler.hp
							echo("expected damage*2 is higher than user's current hp. score doubles")
							echo("\n")
							hpitemscore*=2
						end
					end
				end
				hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
				opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
				if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
					oppchipdamage=((target.totalhp*(1-hpchange)))
				end
				thisdam=maxdam#*1.1
				hplost=(battler.totalhp-battler.hp)
				hplost+=maxdam if !fasterhealing
				if battler.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,battler)
					echo("user is slower and seeded. score x0.3")
					echo("\n")
					hpitemscore *= 0.3 
				end	
				if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
					echo("we are going to be taking more chip damage than we are going to heal")
					echo("\n")
					chipdamage=((battler.totalhp*(1-hpchange)))
					thisdam+=chipdamage
				elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
					echo("we are going to be healing more hp than we take chip damage for  ")
					echo("\n")
					healing=((battler.totalhp*(hpchange-1)))
					thisdam-=healing if !(thisdam>battler.hp)
				elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
					echo("we are going to a huge overstack of end of turn effects. hence we should just not heal. ")
					echo("\n")
					hpitemscore*=0
				end
				if thisdam>hplost
					echo("expected damage is bigger than missing hp. score x0.1 ")
					echo("\n")
					hpitemscore*=0.1
				else
					echo("expected damage is less than missing hp ")
					echo("\n")
					if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
						echo("this is the last pokemon and the missing hp is less than the future hp after healing. score x0.01 ")
						echo("\n")
						hpitemscore*=0.01
					end
					if thisdam<=(heal)
						echo("expected damage is smaller than the healing score doubles.")
						echo("\n")
						hpitemscore*=2
					else
						if fastermon
							echo("user is faster than the player's mon")
							echo("\n")
							if hpchange<1 && thisdam>=heal && !(opphpchange<1)
								echo("we are taking chip damage, expected damage is bigger than the healing, opponent does not take chip damage. score x0.3")
								echo("\n")
								hpitemscore*=0.3
							end
						end
					end
				end 
				if target.pbHasMoveFunction?("024","025","026","036",
					"02B","02C","027", "028","01C",
					"02E","029","032","039","035") # Setup
					hpitemscore*=0.7
					echo("player has setup, score x0.7")
					echo("\n")
				end
				if ((battler.hp.to_f)<=halfhealth)
					echo("user's hp ("+battler.hp.to_s+") is less than half of hp after healing ("+halfhealth.to_s+"). score x1.5")
					echo("\n")
					hpitemscore*=1.5
				else
					echo("user's hp ("+battler.hp.to_s+") is more than half of hp after healing ("+halfhealth.to_s+"). score x0.3")
					echo("\n")
					hpitemscore*=0.2
				end
				hpitemscore/=(battler.effects[PBEffects::Toxic]) if battler.effects[PBEffects::Toxic]>0
				if maxdam>halfhealth
					echo("expected damage is higher than half of hp after healing")
					echo("\n")
					hpitemscore*=0.8 
				end
				if target.hasActiveItem?(:METRONOME)
					echo("player has metronome.. score decreases accordingly")
					echo("\n")
					met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
					hpitemscore/=met
				end 
				if battler.status==:PARALYSIS || battler.effects[PBEffects::Confusion]>0
					echo("paralysis/confusion. score increases slightly")
					echo("\n")
					hpitemscore*=1.1 
				end
				if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
					echo("player mon suffers from damage over time. score x1.3")
					echo("\n")
					hpitemscore*=1.3
					hpitemscore*=1.3 if target.effects[PBEffects::Toxic]>0
					hpitemscore*=1.3 if battler.item == :BINDINGBAND
				end
				if ((battler.hp.to_f)/battler.totalhp)>0.8
					echo("user's hp is higher than  80perc. score x0.1")
					echo("\n")
					hpitemscore*=0.1 
				end
				if ((battler.hp.to_f)/battler.totalhp)>0.6
					echo("user's hp is higher than  60perc. score x0.6")
					echo("\n")
					hpitemscore*=0.6 
				end
				if ((battler.hp.to_f)/battler.totalhp)<0.25
					echo("user's hp is lower than  25perc. score doubles")
					echo("\n")
					hpitemscore*=2 
				end
			end


			#   usableHPItems.sort! { |a,b| (a[1]==b[1]) ? a[2]<=>b[2] : a[1]<=>b[1] }
			#   prevhpitem = nil
			#   usableHPItems.each do |i|
			#     return i[0], idxTarget if i[2]>=losthp
			#     prevhpitem = i
			#   end
			#   return prevhpitem[0], idxTarget 
		end
		
		statusitemscore=0
		maxscore=0
		chosenstatusitem = nil
		# Next prioritise using a status-curing item
		if usableStatusItems.length>0 #&& pbAIRandom(100)<40
			usableStatusItems.sort! { |a,b| a[1]<=>b[1] }
			usableStatusItems.each do |i|
				if i[1]==7
					if	(
						battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack && 
							(
							battler.status==:BURN || battler.status==:POISON || 
							(battler.status==:SLEEP && battler.pbHasMoveFunction?("0B4")) # Sleep Talk
							)
						) ||  
						(
						battler.hasActiveAbility?(:TOXICBOOST) && hasPhysicalAttack && battler.status==:POISON
						) ||  
						(
						battler.hasActiveAbility?(:FLAREBOOST) && hasSpecialAttack && battler.status==:BURN
						) ||  
						(
						battler.hasActiveAbility?(:QUICKFEET)&& 
							(
								(battler.status==:BURN && hasSpecialAttack) ||
								battler.status==:POISON ||
								battler.status==:PARALYSIS
							)
						) ||  
						(
						battler.hasActiveAbility?(:MARVELSCALE) && hasSpecialAttack && battler.status==:BURN
						) ||  
						(
						battler.hasActiveAbility?(:POISONHEAL) && battler.status==:POISON
						) ||
						(
						battler.status==:SLEEP && (battler.statusCount==1 || target.pbHasMoveFunction?("003"))
						) ||
						(
						battler.status==:FROZEN && canthaw
						) ||
						(
						battler.status==:PARALYSIS && 
							(
								((aspeed*4 < ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) ||
								target.pbHasMove?(:THUNDERWAVE) || target.pbHasMove?(:GLARE) || target.pbHasMove?(:STUNSPORE)
							)
						) ||
						(
						battler.status==:BURN && target.pbHasMove?(:WILLOWISP) || target.pbHasMove?(:SACREDFIRE) || target.pbHasMove?(:INFERNO) || !hasPhysicalAttack
						) ||
						(
						battler.status==:POISON && battler.effects[PBEffects::Toxic]<4
						)

						echo("Will not use Full Heal because it's either pointless or beneficial in this scenario.\n")

					else

						if battler.statusCount>2 && battler.status==:SLEEP && !target.pbHasMoveFunction?("003")
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						elsif battler.status==:FROZEN
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						elsif battler.status==:BURN && !target.pbHasMove?(:WILLOWISP)
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						elsif battler.status==:PARALYSIS && !target.pbHasMove?(:THUNDERWAVE) && !target.pbHasMove?(:GLARE) && !target.pbHasMove?(:STUNSPORE)
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								#statusitemscore += 40
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*4>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
										statusitemscore += 100 
										if attacker.pbHasMoveFunction?("175") && attacker.hasActiveAbility?(:SERENEGRACE) && 
											((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
											target.effects[PBEffects::Substitute]==0
											statusitemscore +=140 
										end
									end
								end
								statusitemscore += 40 if thirdhealth>maxdam
							end
						elsif battler.status==:POISON && user.effects[PBEffects::Toxic]>3
							statusitemscore = 100
							aspeed = pbRoughStat(battler,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							fastermon=true 
							halfhealth=0
							bestmove=bestMoveVsTarget(target,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
							if !targetSurvivesMove(maxmove,target,battler)
								if maxdam>(battler.hp+halfhealth)
									statusitemscore=0
								else
									if maxdam>=halfhealth
										if fastermon
											statusitemscore*=0.5
										else
											statusitemscore*=0.1
										end
									else
										statusitemscore*=2
									end
								end
							else
								if maxdam*1.5>battler.hp
									statusitemscore*=2
								end
								if !fastermon
									if maxdam*2>battler.hp
										statusitemscore*=2
									end
								end
							end
							hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
							opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
							if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
								oppchipdamage=((target.totalhp*(1-hpchange)))
							end
							thisdam=maxdam#*1.1
							hplost=(battler.totalhp-battler.hp)
							hplost+=maxdam if !fastermon
							if battler.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,battler)
								statusitemscore *= 0.3 
							end	
							if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
								chipdamage=((battler.totalhp*(1-hpchange)))
								thisdam+=chipdamage
							elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
								healing=((battler.totalhp*(hpchange-1)))
								thisdam-=healing if !(thisdam>battler.hp)
							elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
								statusitemscore*=0
							end
							if thisdam>hplost
								statusitemscore*=0.1
							else
								if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
									statusitemscore*=0.01
								end
								if thisdam<=(halfhealth)
									statusitemscore*=2
								else
									if fastermon
										if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
											statusitemscore*=0.3
										end
									end
								end
							end
							statusitemscore*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
								"02B","02C","027", "028","01C",
								"02E","029","032","039","035") # Setup
							if ((battler.hp.to_f)<=halfhealth)
								statusitemscore*=1.5
							else
								statusitemscore*=0.8
							end
							statusitemscore/=(battler.effects[PBEffects::Toxic]) if battler.effects[PBEffects::Toxic]>0
							statusitemscore*=0.8 if maxdam>halfhealth
							if target.hasActiveItem?(:METRONOME)
								met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
								statusitemscore/=met
							end 
							statusitemscore*=1.1 if battler.status==:PARALYSIS || battler.effects[PBEffects::Confusion]>0
							if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
								statusitemscore*=1.3
								statusitemscore*=1.3 if target.effects[PBEffects::Toxic]>0
								statusitemscore*=1.3 if battler.item == :BINDINGBAND
							end
							statusitemscore*=0.1 if ((battler.hp.to_f)/battler.totalhp)>0.8
							statusitemscore*=0.6 if ((battler.hp.to_f)/battler.totalhp)>0.6
							statusitemscore*=2 if ((battler.hp.to_f)/battler.totalhp)<0.25
						else
							statusitemscore=0
						end
					end	
				else
					case i[0]
					when :AWAKENING, :CHESTOBERRY, :BLUEFLUTE
						if battler.statusCount>2 && battler.status==:SLEEP && !target.pbHasMoveFunction?("003") &&
							!battler.pbHasMoveFunction?("0B4") # Sleep Talk
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						else
							statusitemscore=0
						end
					when :ICEHEAL, :ASPEARBERRY
						if battler.status==:FROZEN && canthaw
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						else
							statusitemscore=0
						end
					when :BURNHEAL, :RAWSTBERRY
						if battler.status==:BURN && !target.pbHasMove?(:WILLOWISP) &&
							(!battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack) && !battler.hasActiveAbility?(:QUICKFEET) 
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							priodam=0
							priomove=nil
							for j in user.moves
								next if j.priority<1
								if user.effects[PBEffects::ChoiceBand] &&
									user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
									if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
										next if j.id!=user.lastMoveUsed
									end
								end		
								tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
								tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
								if tempdam>priodam
									priodam=tempdam 
									priomove=j
								end	
							end 
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 50
								statusitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
								statusitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
										if priomove
											if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
												statusitemscore+=90
											else	
												statusitemscore -= 90 
											end
										else
											statusitemscore -= 90 
										end
									else
										statusitemscore+=80
									end
								end
								statusitemscore += 20 if halfhealth>maxdam
								statusitemscore += 40 if thirdhealth>maxdam
							end 
						else
							statusitemscore=0
						end
					when :PARALYZEHEAL,:PARLYZHEAL, :CHERIBERRY
						if battler.status==:PARALYSIS && !target.pbHasMove?(:THUNDERWAVE) && !target.pbHasMove?(:GLARE) && !target.pbHasMove?(:STUNSPORE) &&
							!battler.hasActiveAbility?(:QUICKFEET) && ((aspeed*4 > ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
							statusitemscore=100
							bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxprio=bestmove[2]
							halfhealth=(user.totalhp/2)
							thirdhealth=(user.totalhp/3)
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
								#statusitemscore += 40
								if skill>=PBTrainerAI.highSkill
									aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
									ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
									if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*4>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
										statusitemscore += 100 
										if attacker.pbHasMoveFunction?("175") && attacker.hasActiveAbility?(:SERENEGRACE) && 
											((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
											target.effects[PBEffects::Substitute]==0
											statusitemscore +=140 
										end
									end
								end
								statusitemscore += 40 if thirdhealth>maxdam
							end
						else
							statusitemscore=0
						end
					when :ANTIDOTE, :PECHABERRY
						if battler.status==:POISON && user.effects[PBEffects::Toxic]>3 && 
							!((battler.hasActiveAbility?(:GUTS) || battler.hasActiveAbility?(:TOXICBOOST)) && hasPhysicalAttack) &&
							!battler.hasActiveAbility?(:QUICKFEET) && !battler.hasActiveAbility?(:POISONHEAL) && !battler.hasActiveItem?(:LIFEORB)
							statusitemscore = 100
							aspeed = pbRoughStat(battler,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							fastermon=true 
							halfhealth=0
							bestmove=bestMoveVsTarget(target,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
							maxdam=bestmove[0] 
							maxmove=bestmove[1]
							maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
							if !targetSurvivesMove(maxmove,target,battler)
								if maxdam>(battler.hp+halfhealth)
									statusitemscore=0
								else
									if maxdam>=halfhealth
										if fastermon
											statusitemscore*=0.5
										else
											statusitemscore*=0.1
										end
									else
										statusitemscore*=2
									end
								end
							else
								if maxdam*1.5>battler.hp
									statusitemscore*=2
								end
								if !fastermon
									if maxdam*2>battler.hp
										statusitemscore*=2
									end
								end
							end
							hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
							opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
							if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
								oppchipdamage=((target.totalhp*(1-hpchange)))
							end
							thisdam=maxdam#*1.1
							hplost=(battler.totalhp-battler.hp)
							hplost+=maxdam if !fastermon
							if battler.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,battler)
								statusitemscore *= 0.3 
							end	
							if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
								chipdamage=((battler.totalhp*(1-hpchange)))
								thisdam+=chipdamage
							elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
								healing=((battler.totalhp*(hpchange-1)))
								thisdam-=healing if !(thisdam>battler.hp)
							elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
								statusitemscore*=0
							end
							if thisdam>hplost
								statusitemscore*=0.1
							else
								if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
									statusitemscore*=0.01
								end
								if thisdam<=(halfhealth)
									statusitemscore*=2
								else
									if fastermon
										if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
											statusitemscore*=0.3
										end
									end
								end
							end
							statusitemscore*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
								"02B","02C","027", "028","01C",
								"02E","029","032","039","035") # Setup
							if ((battler.hp.to_f)<=halfhealth)
								statusitemscore*=1.5
							else
								statusitemscore*=0.8
							end
							statusitemscore/=(battler.effects[PBEffects::Toxic]) if battler.effects[PBEffects::Toxic]>0
							statusitemscore*=0.8 if maxdam>halfhealth
							if target.hasActiveItem?(:METRONOME)
								met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
								statusitemscore/=met
							end 
							statusitemscore*=1.1 if battler.status==:PARALYSIS || battler.effects[PBEffects::Confusion]>0
							if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
								statusitemscore*=1.3
								statusitemscore*=1.3 if target.effects[PBEffects::Toxic]>0
								statusitemscore*=1.3 if battler.item == :BINDINGBAND
							end
							statusitemscore*=0.1 if ((battler.hp.to_f)/battler.totalhp)>0.8
							statusitemscore*=0.6 if ((battler.hp.to_f)/battler.totalhp)>0.6
							statusitemscore*=2 if ((battler.hp.to_f)/battler.totalhp)<0.25
						else
							statusitemscore=0
						end   
					end
				end
				if statusitemscore>maxscore
					chosenstatusitem=i
					maxscore=statusitemscore
				end
				
				#return usableStatusItems[0][0], idxTarget
			end
			
		end	
		xitemscore=0
		maxscore=0
		chosenxitem = nil
		# Next try using an X item
		if usableXItems.length>0
			usableXItems.sort! { |a,b| (a[1]==b[1]) ? a[2]<=>b[2] : a[1]<=>b[1] }
			usableXItems.each do |i|
				xitemscore=100
				case i[0]
				when :XATTACK, :XATTACK2, :XATTACK3, :XATTACK6
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					priodam=0
					priomove=nil
					for j in user.moves
						next if j.priority<1
						if user.effects[PBEffects::ChoiceBand] &&
							user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
							if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
								next if j.id!=user.lastMoveUsed
							end
						end		
						tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						if tempdam>priodam
							priodam=tempdam 
							priomove=j
						end	
					end 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						xitemscore += 40
						xitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
						xitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if canSleepTarget(user,target,true) && 
								((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
								xitemscore-=90
							end	
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
								if priomove
									if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
										xitemscore+=80
									else	
										xitemscore -= 90 
									end
								else
									xitemscore -= 90 
								end
							else
								xitemscore+=80
							end
						end
						xitemscore += 20 if halfhealth>maxdam
						xitemscore += 40 if thirdhealth>maxdam
					end 
					xitemscore -= user.stages[:ATTACK]*20
					if skill>=PBTrainerAI.mediumSkill
						hasPhysicalAttack = false
						user.eachMove do |m|
							next if !m.physicalMove?(m.type)
							hasPhysicalAttack = true
							break
						end
						if hasPhysicalAttack
							xitemscore += 20
						else
							xitemscore -= 200
						end
					end
				when :XDEFENSE, :XDEFENSE2, :XDEFENSE3, :XDEFENSE6, :XDEFEND2, :XDEFEND3, :XDEFEND6
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					maxphys=(bestmove[3]=="physical") 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						xitemscore-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						if maxphys
							xitemscore += 30
							xitemscore += 20 if halfhealth>maxdam
						end
						xitemscore += 40 if thirdhealth>maxdam
						if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							xitemscore += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						end
					end 
					if user.statStageAtMax?(:DEFENSE)
						xitemscore -= 90
					else
						xitemscore -= user.stages[:DEFENSE] * 20
					end
				when :XSPATK, :XSPATK2, :XSPATK3, :XSPATK6, :XSPECIAL, :XSPECIAL2, :XSPECIAL3, :XSPECIAL6
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						xitemscore-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						xitemscore += 40
						xitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
						xitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							xitemscore -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
						end
						xitemscore += 20 if halfhealth>maxdam
						xitemscore += 40 if thirdhealth>maxdam
					end 
					xitemscore -= user.stages[:SPECIAL_ATTACK]*20
					if skill>=PBTrainerAI.mediumSkill
						hasSpecialAttack = false
						user.eachMove do |m|
							next if !m.specialMove?(m.type)
							hasSpecialAttack = true
							break
						end
						if hasSpecialAttack
							xitemscore += 20
						else
							xitemscore -= 200
						end
					end
				when :XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					maxspec=(bestmove[3]=="special") 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						xitemscore-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						if maxspec
							xitemscore += 30
							xitemscore += 20 if halfhealth>maxdam
						end
						xitemscore += 60 if thirdhealth>maxdam
						if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							xitemscore += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						end
					end 
					if user.statStageAtMax?(:SPECIAL_DEFENSE)
						xitemscore -= 90
					else
						xitemscore -= user.stages[:SPECIAL_DEFENSE] * 20
					end
				when :XSPEED, :XSPEED2, :XSPEED3, :XSPEED6
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						xitemscore-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						#xitemscore += 40
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
								xitemscore += 100 
								if attacker.pbHasMoveFunction?("175") && attacker.hasActiveAbility?(:SERENEGRACE) && 
									((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
									target.effects[PBEffects::Substitute]==0
									xitemscore +=140 
								end
							end
						end
						xitemscore += 40 if thirdhealth>maxdam
					end
					if user.statStageAtMax?(:SPEED)
						xitemscore -= 90
					else
						xitemscore -= user.stages[:SPEED] * 10
					end
				when :DIREHIT
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					priodam=0
					priomove=nil
					for j in user.moves
						next if j.priority<1
						if user.effects[PBEffects::ChoiceBand] &&
							user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
							if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
								next if j.id!=user.lastMoveUsed
							end
						end		
						tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						if tempdam>priodam
							priodam=tempdam 
							priomove=j
						end	
					end 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					hascrit = 0
					if user.hasActiveAbility?(:SUPERLUCK) || user.hasActiveAbility?(:SNIPER) || user.hasActiveItem?(:SCOPELENS)
						hascrit=2
					end
					user.eachMove do |m|
						next if !m.highCriticalRate?
						hascrit +=1
						break if hascrit>=2
					end
					if hascrit==2
						xitemscore += 20
					else
						xitemscore -= 200
					end
					if (targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)) && hascrit==2
						xitemscore += 40
						xitemscore+= 60 if (target.status == :SLEEP && target.statusCount>1)
						xitemscore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if canSleepTarget(user,target,true) && 
								((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
								xitemscore-=90
							end	
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
								if priomove
									if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
										xitemscore+=80
									else	
										xitemscore -= 90 
									end
								else
									xitemscore -= 90 
								end
							else
								xitemscore+=80
							end
						end
						xitemscore += 20 if halfhealth>maxdam
						xitemscore += 40 if thirdhealth>maxdam
					end 
					
				end
				
				if xitemscore>maxscore
					chosenxitem=i
					maxscore=xitemscore
				end
				
				# break if prevItem && i[1]>prevItem[1]
				# return i[0], idxTarget if i[1]+i[2]>=6
				# prevItem = i
			end
			#return prevItem[0], idxTarget
		end
		echo("\nItem scores:\n")
		if chosenhpitem
			echo(chosenhpitem[0].name+": "+hpitemscore.to_s+"\n")
		end	
		if chosenstatusitem
			echo(chosenstatusitem[0].name+": "+statusitemscore.to_s+"\n")
		end
		if chosenxitem
			echo(chosenxitem[0].name+": "+xitemscore.to_s+"\n")
		end
		echo("\n")
		bestitem= [hpitemscore, statusitemscore, xitemscore].max #nil
		case bestitem
		when hpitemscore
			if chosenhpitem
				return [chosenhpitem[0], hpitemscore], idxTarget
			else
				return [nil, hpitemscore], idxTarget
			end
		when statusitemscore
			if chosenstatusitem
				return [chosenstatusitem[0], statusitemscore], idxTarget
			else
				return [nil, statusitemscore], idxTarget
			end
		when xitemscore
			if chosenxitem
				return [chosenxitem[0], xitemscore], idxTarget
			else
				return [nil, xitemscore], idxTarget
			end
		end
		
	end
	
end

def pbBattleTypeWeakingBerry(type,moveType,target,mults)
	return if moveType != type
	return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
	mults[:final_damage_multiplier] /= 2
	target.damageState.berryWeakened = true
	target.battle.pbCommonAnimation("EatBerry",target) if !$aiberrycheck
end  



class PokeBattle_Battle

  def pbCommandPhaseLoop(isPlayer)
    # NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
    #       your actions in a round.
    actioned = []
    idxBattler = -1
    loop do
      break if @decision!=0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler>=@battlers.length
      next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler)!=isPlayer
      next if @choices[idxBattler][0]!=:None    # Action is forced, can't choose one
      next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
      if !@controlPlayer && pbOwnedByPlayer?(idxBattler)
        # Player chooses an action
        actioned.push(idxBattler)
        commandsEnd = false   # Whether to cancel choosing all other actions this round
        loop do
          cmd = pbCommandMenu(idxBattler,actioned.length==1)
          # If being Sky Dropped, can't do anything except use a move
          if cmd>0 && @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
            pbDisplay(_INTL("Sky Drop won't let {1} go!",@battlers[idxBattler].pbThis(true)))
            next
          end
          case cmd
          when 0    # Fight
            break if pbFightMenu(idxBattler)
          when 1    # Bag
            if pbItemMenu(idxBattler,actioned.length==1)
              commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
              break
            end
          when 2    # Pokémon
            break if pbPartyMenu(idxBattler)
          when 3    # Run
            # NOTE: "Run" is only an available option for the first battler the
            #       player chooses an action for in a round. Attempting to run
            #       from battle prevents you from choosing any other actions in
            #       that round.
            if pbRunMenu(idxBattler)
              commandsEnd = true
              break
            end
          when 4    # Call
            break if pbCallMenu(idxBattler)
          when -2   # Debug
            pbDebugMenu
            next
          when -1   # Go back to previous battler's action choice
            next if actioned.length<=1
            actioned.pop   # Forget this battler was done
            idxBattler = actioned.last-1
            pbCancelChoice(idxBattler+1)   # Clear the previous battler's choice
            actioned.pop   # Forget the previous battler was done
            break
          end
          pbCancelChoice(idxBattler)
        end
      else 
		# DemICE moved the AI decision after player decision.
        # AI controls this battler
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
      end  
      break if commandsEnd
    end
  end
end
