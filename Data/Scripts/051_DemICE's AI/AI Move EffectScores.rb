class PokeBattle_AI
	
	alias stupidity_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
	
	def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
		initialscore=score
		attacker=user
		opponent=user.pbDirectOpposing(true)
		# prankpri = false
		# if move.baseDamage==0 && attacker.hasActiveAbility?(:PRANKSTER)
		# 	prankpri = true
		# end	
		# if move.priority>0 || prankpri || (attacker.hasActiveAbility?(:GALEWINGS) && attacker.hp==attacker.totalhp && move.type==:FLYING)
		thisprio = priorityAI(user,move)
		if thisprio > 0
			aspeed = pbRoughStat(attacker,:SPEED,skill)
			ospeed = pbRoughStat(opponent,:SPEED,skill)
			if move.baseDamage>0  
				fastermon = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				if fastermon
					PBDebug.log(sprintf("AI Pokemon is faster.")) if $INTERNAL
				else
					PBDebug.log(sprintf("Player Pokemon is faster.")) if $INTERNAL
				end   
				# pridamage=pbRoughDamage(move,attacker,opponent,skill,move.baseDamage)   
				# if pridamage>=opponent.totalhp  
				if !targetSurvivesMove(move,attacker,opponent)
					if fastermon
						score*=1.3
					else
						score*=2
					end
				end      
				movedamage = -1
				maxpriomove=nil
				maxmove=nil
				opppri = false     
				pridam = -1
				#if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				for j in opponent.moves
					tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
					if priorityAI(opponent,j)>0
						opppri=true
						if tempdam>pridam
							pridam = tempdam
							maxpriomove=j
						end              
					end    
					if tempdam>movedamage
						movedamage = tempdam
						maxmove=j
					end 
				end 
				#end
				PBDebug.log(sprintf("Expected damage taken: %d",movedamage)) if $INTERNAL
				if !fastermon
					maxdam=0
					maxmove2=nil
					#if movedamage>attacker.hp
					if !targetSurvivesMove(maxmove,opponent,attacker)
						score+=150
						for j in opponent.moves
							if moveLocked(opponent)
								if opponent.lastMoveUsed && opponent.pbHasMove?(opponent.lastMoveUsed)
									next if j.id!=opponent.lastMoveUsed
								end
							end		
							tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
							maxdam=tempdam if tempdam>maxdam
							maxmove2=j
						end  
						#if maxdam>=attacker.hp
						if !targetSurvivesMove(maxmove2,opponent,attacker)
							score+=30
						end
					end
				end      
				if opppri
					score*=1.1
					#if pridam>attacker.hp
					if !targetSurvivesMove(maxpriomove,opponent,attacker)
						if fastermon
							score*=3
						else
							score*=0.5
						end
					end
				end
				if !fastermon && opponent.inTwoTurnAttack?("0C9","0CC","0CE","0CA","0CB")  # Invul moves
					score*=0
				end
				if @battle.field.terrain == :Psychic && opponent.affectedByTerrain?
					score*=0
				end
				if opponent.hasActiveAbility?(:DAZZLING) || opponent.hasActiveAbility?(:QUEENLYMAJESTY)
					score*=0
				end    
				if pbTargetsMultiple?(move,user)
					quickcheck = false 
					for j in opponent.moves
						quickcheck = true if j.function=="0AB"
					end          
					if quickcheck
						score*=0.2
					end 
				end	
			end      
		elsif move.priority<0
			if fastermon
				score*=0.9
				if move.baseDamage>0
					if opponent.inTwoTurnAttack?("0C9","0CC","0CE","0CA","0CB")  # Invul moves
						score*=2
					end
				end
			end      
		end  
		case move.function
			
			#---------------------------------------------------------------------------
		when "003", "004"
			aspeed = pbRoughStat(user, :SPEED, skill)
			ospeed = pbRoughStat(target, :SPEED, skill)
			if target.pbCanSleep?(user,false,move)
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				halfhealth=(user.totalhp/2)
				thirdhealth=(user.totalhp/3)
				score += 90
				if ((aspeed > ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) &&
					!targetSurvivesMove(maxmove,target,attacker)
					score+=30
				end
				bestownmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxowndmg=bestownmove[0]
				maxownmove=bestownmove[1]
				if targetSurvivesMove(maxownmove,attacker,target)
					score+=30
					score+=20 if user.hasActiveAbility?(:BADDREAMS)
				end
				if user.pbHasMoveFunction?("02B", "026", # Quiver Dance, Dragon Dance
						"036", "035",  # Shift Gear, Shell Smash
						"022", "034",   # Evasion Moves
						"103", "104", "105", "153", # Hazards
						"0D5", "0D6",  #  Recovery
						"0D8", "16D", "0D9")  # Synthesis, Shore up , Rest
					score += 60	
					# GameData::Stat.each_battle do |stat|
					# 	score -= 10*user.stages[stat.id]
					# end	
				end
				if user.pbHasMoveFunction?("024", "025", "02C", # Bulk Up, Coil, Calm Mind
						"027", "028","02A", # Growth, Cosmoic Power
						"01C", "02E", "029", # Howl, Swords Dance, Hone Claws
						"032", "039") && # Nasty Plot, Tail Glow
					((aspeed > ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
					score += 60
				end
				if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:CHESTOBERRY)
					score-=30 
					score-=150 if maxdam>halfhealth
				end	
				if skill >= PBTrainerAI.mediumSkill
					score -=300 if target.effects[PBEffects::Yawn] > 0 && move.function == "004"
				end
				if skill >= PBTrainerAI.highSkill
					score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
				end
				if skill >= PBTrainerAI.bestSkill
					if target.pbHasMoveFunction?("011","0B4")   # Snore, Sleep Talk
						score -= 50
					end
					score -= 150 if target.hasActiveAbility?(:EARLYBIRD)
				end
			elsif skill >= PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
				score -=300 if target.effects[PBEffects::Yawn] > 0 && move.function == "004"
			end
			
			#---------------------------------------------------------------------------
		when "007", "008", "009"
			if target.pbCanParalyze?(user, false,move) &&
				!(skill >= PBTrainerAI.mediumSkill &&
					move.id == :THUNDERWAVE &&
					Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxprio=bestmove[2]
				halfhealth=(user.totalhp/2)
				thirdhealth=(user.totalhp/3)
				score += 30
				score-=50 if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:CHERIBERRY)
				score-=50 if maxprio>thirdhealth
				if skill >= PBTrainerAI.mediumSkill
					aspeed = pbRoughStat(user, :SPEED, skill)
					ospeed = pbRoughStat(target, :SPEED, skill)
					if ((aspeed < ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
						score += 40
						score += 60 if move.statusMove?
					elsif ((aspeed > ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
						score -= 40
					end
				end
				if skill >= PBTrainerAI.highSkill
					score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
				end
			elsif skill >= PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
			end
			
			#---------------------------------------------------------------------------
		when "00A" # Burn
			if target.pbCanBurn?(user, false,move)
				score += 30    
				score += 80 if target.hasActiveAbility?(:WONDERGUARD)
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxphys=(bestmove[3]=="physical") 
				halfhealth=(user.totalhp/2)     
				halfdam= maxdam*0.5
				if move.statusMove? && maxphys
					score += 30 
					score += 80 if halfdam < halfhealth
				end   
				if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:RAWSTBERRY)
					score-=50 
					score-=150 if maxdam>halfhealth
				end	
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					score -= 40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>halfhealth
				end
				if skill >= PBTrainerAI.highSkill
					score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
				end
			elsif skill >= PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
			end    
		#---------------------------------------------------------------------------
		when "005", "006", "0BE"
			if target.pbCanPoison?(user,false,move)
				score += 30
				score += 80 if target.hasActiveAbility?(:WONDERGUARD)
			if skill>=PBTrainerAI.mediumSkill
				score += 30 if target.hp<=target.totalhp/4
				score += 50 if target.hp<=target.totalhp/8
				score -= 40 if target.effects[PBEffects::Yawn]>0
			end
			if skill>=PBTrainerAI.highSkill
				score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
				score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
				score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
			end
			else
			if skill>=PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
			end
			end        
			#---------------------------------------------------------------------------
		when "012"   # Fake Out
			if user.turnCount == 0
				#if skill >= PBTrainerAI.highSkill
				score +=120 if !target.hasActiveAbility?(:INNERFOCUS) &&
				target.effects[PBEffects::Substitute] == 0
				# end
			else
				score -= 90   # Because it will fail here
				score = 0 #if skill >= PBTrainerAI.bestSkill
			end
			
			#---------------------------------------------------------------------------
		when "034"  # Minimize
			if move.statusMove?
				if user.statStageAtMax?(:EVASION) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target==user.pbDirectOpposing(true)
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
						if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>halfhealth
						end
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:EVASION] * 10
				end
			else
				score += 10 if user.turnCount == 0
				score += 20 if user.stages[:EVASION] < 0
			end
			#---------------------------------------------------------------------------
		when "10D"  # Curse
			if user.pbHasType?(:GHOST)
				score-=200 if target.effects[PBEffects::Curse]
				score-=200 if target.hasActiveAbility?(:MAGICGUARD)
			else    
				if (user.statStageAtMax?(:ATTACK) &&
					user.statStageAtMax?(:DEFENSE)) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					maxphys=(bestmove[3]=="physical") 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					if targetSurvivesMove(maxmove,target,attacker,maxprio)|| (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score+=20 if maxphys
						if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 20
						end
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>halfhealth
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:ATTACK]*5
					score -= user.stages[:DEFENSE]*5
					if skill>=PBTrainerAI.mediumSkill
						hasPhysicalAttack = false
						user.eachMove do |m|
							next if !m.physicalMove?(m.type)
							hasPhysicalAttack = true
							break
						end
						if hasPhysicalAttack
							score += 20
						elsif skill>=PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			end    
			#---------------------------------------------------------------------------
		when "024"  # Bulk Up
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:DEFENSE)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio)|| (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score+=20 if maxphys
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 20
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK]*10
				score -= user.stages[:DEFENSE]*10
				if skill>=PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					if hasPhysicalAttack
						score += 20
					elsif skill>=PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			
			#---------------------------------------------------------------------------
		when "025"  # Coil
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:ACCURACY)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score+=20 if maxphys
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 20
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK]*10
				score -= user.stages[:DEFENSE]*10
				score -= user.stages[:ACCURACY]*10
				if skill>=PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					if hasPhysicalAttack
						score += 20
					elsif skill>=PBTrainerAI.highSkill
						score -= 90
					end
				end
			end		  
			
			#---------------------------------------------------------------------------
		when "026"  # Dragon Dance
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPEED)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 20
					score+= 60 if (target.status == :SLEEP && target.statusCount>1)
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score += 80 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*1.5>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK]*10
				score -= user.stages[:SPEED]*10
				if skill>=PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					if hasPhysicalAttack
						score += 20
					elsif skill>=PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			
			#---------------------------------------------------------------------------
		when "036"  # Shift Gear
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPEED)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 20
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score += 40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK] * 10
				score -= user.stages[:SPEED] * 10
				if skill >= PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					if hasPhysicalAttack
						score += 20
					elsif skill >= PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			#---------------------------------------------------------------------------
		when "02B"  # Quiver Dance
			if (user.statStageAtMax?(:SPEED) &&
				user.statStageAtMax?(:SPECIAL_ATTACK) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 20
					score+= 60 if (target.status == :SLEEP && target.statusCount>1)
					score+=20 if maxspec
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					if user.pbHasMoveFunction?("0D5", "0D6")   # Recovey
						score += 20
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score += 40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*1.5>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
					end
				end
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:SPECIAL_ATTACK]*3
				score -= user.stages[:SPECIAL_DEFENSE]*3
				score -= user.stages[:SPEED]*3
				if skill>=PBTrainerAI.mediumSkill
					hasSpecicalAttack = false
					user.eachMove do |m|
						next if !m.specialMove?(m.type)
						hasSpecicalAttack = true
						break
					end
					if hasSpecicalAttack
						score += 20
					elsif skill>=PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			
			#---------------------------------------------------------------------------
		when "02C"  # Calm Mind
			if (user.statStageAtMax?(:SPECIAL_ATTACK) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score+=20 if maxspec
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 20
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:SPECIAL_ATTACK]*10
				score -= user.stages[:SPECIAL_DEFENSE]*10
				if skill>=PBTrainerAI.mediumSkill
					hasSpecicalAttack = false
					user.eachMove do |m|
						next if !m.specialMove?(m.type)
						hasSpecicalAttack = true
						break
					end
					if hasSpecicalAttack
						score += 20
					elsif skill>=PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			
			#---------------------------------------------------------------------------
		when "02A"  # Cosmic Power
			if (user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 30
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 40
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
					end
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:DEFENSE] * 4
				score -= user.stages[:SPECIAL_DEFENSE] * 4
			end		
			#---------------------------------------------------------------------------
		when "112"  # Stockpile
			target=user.pbDirectOpposing(true)
			if (user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)) || user.effects[PBEffects::Stockpile] >= 3 || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 30
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 40
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
					end
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:DEFENSE] * 10
				score -= user.stages[:SPECIAL_DEFENSE] * 10
			end	
			#---------------------------------------------------------------------------
		when "137"  # Magnetic Flux
			geared=false
			@battle.allSameSideBattlers(user.index).each do |b|
				next if !b.hasActiveAbility?(:PLUS) && !b.hasActiveAbility?(:MINUS)
				geared=true
			end
			if (user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)) || !geared || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 30
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 40
					end
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
					end
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:DEFENSE] * 4
				score -= user.stages[:SPECIAL_DEFENSE] * 4
			end
			#---------------------------------------------------------------------------
		when "01D", "02F"  # Iron Defense
			if move.statusMove?
				if user.statStageAtMax?(:DEFENSE) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						if maxphys
							score += 30
							score += 20 if halfhealth>maxdam
						end
						score += 40 if thirdhealth>maxdam
						if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
						end
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:DEFENSE] * 20
				end
			else
				score += 20 if user.stages[:DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "038" # Cotton Guard
			if move.statusMove?
				if user.statStageAtMax?(:DEFENSE) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						if maxphys
							score += 40
							score += 20 if halfhealth>maxdam
						end
						score += 60 if thirdhealth>maxdam
						if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
						end
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:DEFENSE] * 30
				end
			else
				score += 10 if user.turnCount == 0
				score += 30 if user.stages[:DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "033"  # Amnesia
			if move.statusMove?
				if user.statStageAtMax?(:SPECIAL_DEFENSE) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						if maxspec
							score += 30
							score += 20 if halfhealth>maxdam
						end
						score += 60 if thirdhealth>maxdam
						if user.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>thirdhealth
						end
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:SPECIAL_DEFENSE] * 20
				end
			else
				score += 20 if user.stages[:SPECIAL_DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "01F" # Flame Charge
			#if move.statusMove?
				if user.statStageAtMax?(:SPEED) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						#score += 40
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score += 100 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*1.5>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
						end
						score += 40 if thirdhealth>maxdam
					end
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:SPEED] * 10
				end
			# elsif user.stages[:SPEED] < 0
			# 	score += 20
			# end
			#---------------------------------------------------------------------------
		when "030", "031" # Agility, Autotomize
			if move.statusMove?
				if user.statStageAtMax?(:SPEED) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						#score += 40
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
								score += 100 
								if attacker.pbHasMoveFunction?("175") && attacker.hasActiveAbility?(:SERENEGRACE) && 
									((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
									target.effects[PBEffects::Substitute]==0
									score +=140 
								end
							end
						end
						score += 40 if thirdhealth>maxdam
					end
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:SPEED] * 10
				end
			else
				score += 20 if user.stages[:SPEED] < 0
			end
			#---------------------------------------------------------------------------
		when "15C"  # Gear Up
			geared=false
			@battle.allSameSideBattlers(user.index).each do |b|
				next if !b.hasActiveAbility?(:PLUS) && !b.hasActiveAbility?(:MINUS)
				geared=true
			end
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPECIAL_ATTACK)) || !geared || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					prio=false
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK] * 10
				score -= user.stages[:SPECIAL_ATTACK] * 10
				if skill >= PBTrainerAI.mediumSkill
					hasDamagingAttack = false
					user.eachMove do |m|
						next if !m.damagingMove?
						hasDamagingAttack = true
						break
					end
					if hasDamagingAttack
						score += 20
					elsif skill >= PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			#---------------------------------------------------------------------------
		when "027", "028"  # Growth
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPECIAL_ATTACK)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
					prio=false
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK] * 10
				score -= user.stages[:SPECIAL_ATTACK] * 10
				if skill >= PBTrainerAI.mediumSkill
					hasDamagingAttack = false
					user.eachMove do |m|
						next if !m.damagingMove?
						hasDamagingAttack = true
						break
					end
					if hasDamagingAttack
						score += 20
					elsif skill >= PBTrainerAI.highSkill
						score -= 90
					end
				end
				if move.function == "028"   # Growth
					score += 20 if [:Sun, :HarshSun].include?(@battle.pbWeather)
				end
			end
			#---------------------------------------------------------------------------
		when "01C"  # Howl
			if move.statusMove?
				if user.statStageAtMax?(:ATTACK) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:ATTACK] * 20
					if skill >= PBTrainerAI.mediumSkill
						hasPhysicalAttack = false
						user.eachMove do |m|
							next if !m.physicalMove?(m.type)
							hasPhysicalAttack = true
							break
						end
						if hasPhysicalAttack
							score += 20
						elsif skill >= PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			else
				score += 20 if user.stages[:ATTACK] < 0
				if skill >= PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					score += 20 if hasPhysicalAttack
				end
			end            
			#---------------------------------------------------------------------------
		when "02E"  # Swords Dance
			if move.statusMove?
				if user.statStageAtMax?(:ATTACK) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					priodam=0
					priomove=nil
					for j in user.moves
						next if j.priority<1
						if moveLocked(user)
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
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,user,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score+= 60 if (target.status == :SLEEP && target.statusCount>1)
						score += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
								if priomove
									if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,2)
										score+=80
									else	
										score -= 90 
									end
								else
									score -= 90 
								end
							else
								score+=80
							end
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:ATTACK]*20
					if skill>=PBTrainerAI.mediumSkill
						hasPhysicalAttack = false
						user.eachMove do |m|
							next if !m.physicalMove?(m.type)
							hasPhysicalAttack = true
							break
						end
						if hasPhysicalAttack
							score += 20
						elsif skill>=PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			else
				score += 10 if user.hp==user.totalhp
				score += 20 if user.stages[:ATTACK]<0
				if skill>=PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					score += 20 if hasPhysicalAttack
				end
			end
			
			#---------------------------------------------------------------------------
		when "029" # Hone Claws
			if (user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:ACCURACY)) || user.hasActiveAbility?(:CONTRARY)
				score -= 200
			else
				target=user.pbDirectOpposing(true)
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
					score-=90
				end	
				if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
					score += 40
					score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
					if skill>=PBTrainerAI.highSkill
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
					end
					score += 20 if halfhealth>maxdam
					score += 40 if thirdhealth>maxdam
				end 
				score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
				score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				score -= user.stages[:ATTACK] * 10
				score -= user.stages[:ACCURACY] * 10
				if skill >= PBTrainerAI.mediumSkill
					hasPhysicalAttack = false
					user.eachMove do |m|
						next if !m.physicalMove?(m.type)
						hasPhysicalAttack = true
						break
					end
					if hasPhysicalAttack
						score += 20
					elsif skill >= PBTrainerAI.highSkill
						score -= 90
					end
				end
			end
			#---------------------------------------------------------------------------
		when "032"  # Nasty Plot
			if move.statusMove?
				if user.statStageAtMax?(:SPECIAL_ATTACK) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score+= 60 if (target.status == :SLEEP && target.statusCount>1)
						score += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:SPECIAL_ATTACK]*20
					if skill>=PBTrainerAI.mediumSkill
						hasSpecicalAttack = false
						user.eachMove do |m|
							next if !m.specialMove?(m.type)
							hasSpecicalAttack = true
							break
						end
						if hasSpecicalAttack
							score += 20
						elsif skill>=PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			else
				score += 10 if user.turnCount==0
				score += 20 if user.stages[:SPECIAL_ATTACK]<0
				if skill>=PBTrainerAI.mediumSkill
					hasSpecicalAttack = false
					user.eachMove do |m|
						next if !m.specialMove?(m.type)
						hasSpecicalAttack = true
						break
					end
					score += 20 if hasSpecicalAttack
				end
			end
			
			#---------------------------------------------------------------------------
		when "039" # Tail Glow
			if move.statusMove?
				if user.statStageAtMax?(:SPECIAL_ATTACK) || user.hasActiveAbility?(:CONTRARY)
					score -= 200
				else
					target=user.pbDirectOpposing(true)
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
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score += 40 if user.turnCount == 0
					score -= user.stages[:SPECIAL_ATTACK] * 30
					if skill >= PBTrainerAI.mediumSkill
						hasSpecicalAttack = false
						user.eachMove do |m|
							next if !m.specialMove?(m.type)
							hasSpecicalAttack = true
							break
						end
						if hasSpecicalAttack
							score += 20
						elsif skill >= PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			else
				score += 10 if user.turnCount == 0
				score += 30 if user.stages[:SPECIAL_ATTACK] < 0
				if skill >= PBTrainerAI.mediumSkill
					hasSpecicalAttack = false
					user.eachMove do |m|
						next if !m.specialMove?(m.type)
						hasSpecicalAttack = true
						break
					end
					score += 20 if hasSpecicalAttack
				end
			end       
			#---------------------------------------------------------------------------
		when "035" # Shell Smash
			if user.hasActiveAbility?(:CONTRARY)
				score += user.stages[:ATTACK] * 20
				score += user.stages[:SPEED] * 20
				score += user.stages[:SPECIAL_ATTACK] * 20
				score -= user.stages[:DEFENSE] * 10
				score -= user.stages[:SPECIAL_DEFENSE] * 10
			else
				score -= user.stages[:ATTACK] * 20
				score -= user.stages[:SPEED] * 20
				score -= user.stages[:SPECIAL_ATTACK] * 20
				score += user.stages[:DEFENSE] * 10
				score += user.stages[:SPECIAL_DEFENSE] * 10
				if skill>=PBTrainerAI.mediumSkill
					hasDamagingAttack = false
					user.eachMove do |m|
						next if !m.damagingMove?
						hasDamagingAttack = true
						break
					end
					score += 20 if hasDamagingAttack
					target=user.pbDirectOpposing(true)
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					mult=1
					mult=2 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && !user.hasActiveItem?(:WHITEHERB)
					maxdam*=mult
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score-=90
					end	
					if targetSurvivesMove(maxmove,target,attacker,maxprio,mult) || (target.status == :SLEEP && target.statusCount>1)
						score += 100-30*mult
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score += 40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
						end
						score += 20 if halfhealth>(maxdam)
						score += 40 if thirdhealth>(maxdam)
					end
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
				end	
			end    
			#---------------------------------------------------------------------------
			when "03A" # Belly Drum
				if user.statStageAtMax?(:ATTACK) ||
					user.hp <= user.totalhp / 2 || user.hasActiveAbility?(:CONTRARY)
					score -= 300
				else
					target=user.pbDirectOpposing(true)
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam=bestmove[0] 
					maxmove=bestmove[1]
					maxprio=bestmove[2]
					priodam=0
					priomove=nil
					for j in user.moves
						next if j.priority<1
						if moveLocked(user)
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
					if canSleepTarget(user,target,true) && 
						((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score-=90
					end	
					mult=2
					mult=1.5 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.hasActiveItem?(:SITRUSBERRY)
					if targetSurvivesMove(maxmove,target,user,maxprio,mult) || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score+= 60 if (target.status == :SLEEP && target.statusCount>1)
						score += 60 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && maxdam>halfhealth
								if priomove
									if targetSurvivesMove(priomove,user,target) && !targetSurvivesMove(priomove,user,target,0,4)
										score+=80
									else	
										score -= 90 
									end
								else
									score -= 90 
								end
							else
								score+=80
							end
						end
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
					end 
					score-=50 if target.pbHasMoveFunction?("055","054","15D") # Psych Up, Heart Swap, Spectral Thief
					score-=50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
					score -= user.stages[:ATTACK]*20
					if skill>=PBTrainerAI.mediumSkill
						hasPhysicalAttack = false
						user.eachMove do |m|
							next if !m.physicalMove?(m.type)
							hasPhysicalAttack = true
							break
						end
						if hasPhysicalAttack
							score += 20
						elsif skill>=PBTrainerAI.highSkill
							score -= 90
						end
					end
				end
			#---------------------------------------------------------------------------
		when "071"  # Counter
			target=user.pbDirectOpposing(true)
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxphys=(bestmove[3]=="physical") 
				maxowndam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
					maxowndam=tempdam if tempdam>maxowndam
				end 
				maxowndam=target.hp if maxowndam>target.hp
				counterdam=0
				counterdam=maxdam*2 if maxphys
				counterdam=target.hp if counterdam>target.hp
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if maxphys && targetSurvivesMove(maxmove,target,attacker)
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					score += 30 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				end   
				score-=200 if pbAIRandom(100) < 50
			end
			#---------------------------------------------------------------------------
		when "072"  # Mirror Coat
			target=user.pbDirectOpposing(true)
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxspec=(bestmove[3]=="special") 
				maxowndam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
					maxowndam=tempdam if tempdam>maxowndam
				end 
				maxowndam=target.hp if maxowndam>target.hp
				counterdam=0
				counterdam=maxdam*2 if maxspec
				counterdam=target.hp if counterdam>target.hp
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if maxspec && targetSurvivesMove(maxmove,target,attacker)
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					score += 30 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				end   
				score-=200 if pbAIRandom(100) < 50
			end   
			#---------------------------------------------------------------------------
		when "073"  # Metal Burst
			target=user.pbDirectOpposing(true)
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxowndam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
					maxowndam=tempdam if tempdam>maxowndam
				end 
				maxowndam=target.hp if maxowndam>target.hp
				counterdam=0
				counterdam=maxdam*1.5
				counterdam=target.hp if counterdam>target.hp
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if targetSurvivesMove(maxmove,target,attacker)
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score += 30 
					else  
						score-=90
					end        
				end  
				score=5 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score-=200 if pbAIRandom(100) < 50
			end   
			#---------------------------------------------------------------------------
		when "073"  # Bide
			target=user.pbDirectOpposing(true)
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxowndam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
					maxowndam=tempdam if tempdam>maxowndam
				end 
				maxowndam=target.hp if maxowndam>target.hp
				counterdam=0
				counterdam=maxdam*2
				counterdam=target.hp if counterdam>target.hp
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if targetSurvivesMove(maxmove,target,attacker,0,2)
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					score += 30 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				end   
				score-=200 if pbAIRandom(100) < 50
			end     
			#---------------------------------------------------------------------------
		when "0B4"   # Sleep Talk
			if (user.asleep? && user.statusCount>1) || (user.hasActiveAbility?(:COMATOSE) && user.pbHasMoveFunction?("125"))
				score += 150   # Because it can only be used while asleep
			else
				score -= 90
			end 
			#---------------------------------------------------------------------------
		# when "125" # Last Resort # HANDLED IN pbCheckMoveImmunity
		# 	hasThisMove = false
		# 	hasOtherMoves = false
		# 	hasUnusedMoves = false
		# 	user.eachMove do |m|
		# 		hasThisMove    = true if m.id == @id
		# 		hasOtherMoves  = true if m.id != @id
		# 		hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
		# 	end
		# 	if !hasThisMove || !hasOtherMoves || hasUnusedMoves
		# 		score=0
		# 	end
		#---------------------------------------------------------------------------
		when "0EB" # Whirlwind
			if target.effects[PBEffects::Ingrain] ||
				(skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
			score -= 90
			else
			ch = 0
			@battle.pbParty(target.index).each_with_index do |pkmn,i|
				ch += 1 if @battle.pbCanSwitchLax?(target.index,i)
			end
			score -= 90 if ch==0
			end
			if score>20
				score += 50 if target.pbOwnSide.effects[PBEffects::Spikes]>0
				score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
				score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
				@battle.allOtherSideBattlers(user.index).each do |b|
					if b.hasActiveAbility?(:WONDERGUARD) &&
							(user.pbOpposingSide.effects[PBEffects::StealthRock] ||
							user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >0
							user.pbOpposingSide.effects[PBEffects::Spikes] >0)	
						score+=50
					end	
				end	
			end
			#---------------------------------------------------------------------------
			when "061" # Soak
				if target.effects[PBEffects::Substitute]>0 || !target.canChangeType?
					core -= 90
				elsif !target.pbHasOtherType?(:WATER)
					score -= 90
				end
				score+=60 if target.hasActiveAbility?(:WONDERGUARD)
			#---------------------------------------------------------------------------
			when "10F" # Nightmare
				if target.effects[PBEffects::Nightmare] ||
					target.effects[PBEffects::Substitute]>0
					score -= 90
				elsif !target.asleep?
					score -= 90
				else
					score -= 90 if target.statusCount<=1
					score +=50 if target.statusCount>1
				end
			#---------------------------------------------------------------------------
			when "068" # Gastro Acid
				if target.effects[PBEffects::Substitute]>0 ||
					target.effects[PBEffects::GastroAcid]
					score -= 200
				elsif skill>=PBTrainerAI.highSkill
					score+=50 if target.hasActiveAbility?(:WONDERGUARD)
				score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
				end
			#---------------------------------------------------------------------------
		when "103" # Spikes
			target=user.pbDirectOpposing(true)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			denier=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				if b.effects[PBEffects::MagicCoat] || b.hasActiveAbility?(:MAGICBOUNCE) ||
					(b.pbHasMoveFunction?("110") && !user.pbHasType?(:GHOST)) ||
					b.pbHasMoveFunction?("049") 
					denier=true
				end
			end    
			if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3 || denier
				score -= 90
			elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
				score -= 90   # Opponent can't switch in any Pokemon
			else
				party = @battle.pbParty(target.index)
				inBattleIndices = @battle.allSameSideBattlers(target.index).map { |b| b.pokemonIndex }
				count = 0
				party.each_with_index do |pkmn, idxParty|
					next if !pkmn || !pkmn.able?
					next if inBattleIndices.include?(idxParty)
					next if pkmn.ability == :MAGICGUARD || pkmn.isAirborne? || pkmn.item == :HEAVYDUTYBOOTS 
					count += 1
					count += 1 if (pkmn.item == :FOCUSSASH || pkmn.ability == :STURDY || pkmn.ability == :WONDERGUARD) && 
					user.pbOpposingSide.effects[PBEffects::Spikes]==0
				end
				score += [15, 10, 5][user.pbOpposingSide.effects[PBEffects::Spikes]] * count
			end
			#---------------------------------------------------------------------------
		when "104" # Toxic Spikes
			target=user.pbDirectOpposing(true)
			denier=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				if b.effects[PBEffects::MagicCoat] || b.hasActiveAbility?(:MAGICBOUNCE) ||
					(b.pbHasMoveFunction?("110") && !user.pbHasType?(:GHOST)) ||
					b.pbHasMoveFunction?("049") 
					denier=true
				end
			end    
			if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2 || denier
				score -= 90
			elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
				score -= 90  # Opponent can't switch in any Pokemon
			else
				party = @battle.pbParty(target.index)
				inBattleIndices = @battle.allSameSideBattlers(target.index).map { |b| b.pokemonIndex }
				count = 0
				party.each_with_index do |pkmn, idxParty|
					next if !pkmn || !pkmn.able?
					next if inBattleIndices.include?(idxParty)
					next if pkmn.ability == :MAGICGUARD || pkmn.ability == :IMMUNITY || pkmn.isAirborne? || pkmn.item == :HEAVYDUTYBOOTS || 
					pkmn.status != :NONE || pkmn.hasType?(:STEEL)
					if pkmn.hasType?(:POISON) || pkmn.ability == :POISONHEAL || pkmn.ability == :GUTS || pkmn.ability == :TOXICBOOST
						count-=1
					else  
						count += 1
						count += 1 if (pkmn.item == :FOCUSSASH || pkmn.ability == :STURDY || pkmn.ability == :WONDERGUARD) && 
						user.pbOpposingSide.effects[PBEffects::ToxicSpikes]==0
					end 
				end
				count=0 if count<0
				score += [15, 5][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]] * count
			end
			#---------------------------------------------------------------------------
		when "105" # Stealth Rock
			target=user.pbDirectOpposing(true)
			denier=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				if b.effects[PBEffects::MagicCoat] || b.hasActiveAbility?(:MAGICBOUNCE) ||
					(b.pbHasMoveFunction?("110") && !user.pbHasType?(:GHOST)) ||
					b.pbHasMoveFunction?("049") 
					denier=true
				end
			end    
			if user.pbOpposingSide.effects[PBEffects::StealthRock] || denier
				score -= 200
			elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
				score -= 200   # Opponent can't switch in any Pokemon
			else
				party = @battle.pbParty(target.index)
				inBattleIndices = @battle.allSameSideBattlers(target.index).map { |b| b.pokemonIndex }
				count = 0
				party.each_with_index do |pkmn, idxParty|
					next if !pkmn || !pkmn.able?
					next if inBattleIndices.include?(idxParty)
					next if pkmn.ability == :MAGICGUARD || pkmn.item == :HEAVYDUTYBOOTS
					count += 1
					count += 1 if pkmn.item == :FOCUSSASH || pkmn.ability == :STURDY || pkmn.ability == :WONDERGUARD ||
					(pkmn.hasType?(:FIRE) && (pkmn.hasType?(:ICE) || pkmn.hasType?(:BUG) || pkmn.hasType?(:FLYING))) || 
					(pkmn.hasType?(:ICE) &&  (pkmn.hasType?(:BUG) || pkmn.hasType?(:FLYING))) || 
					(pkmn.hasType?(:BUG) && pkmn.hasType?(:FLYING)) 
					count +=3 if pkmn.ability == :WONDERGUARD
				end
				score += 15 * count
				@battle.allOtherSideBattlers(user.index).each do |b|
					score+=80 if b.hasActiveAbility?(:WONDERGUARD)
				end	
			end
			#---------------------------------------------------------------------------
		when "153" # Sticky Web
			target=user.pbDirectOpposing(true)
			denier=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				if b.effects[PBEffects::MagicCoat] || b.hasActiveAbility?(:MAGICBOUNCE) ||
					(b.pbHasMoveFunction?("110") && !user.pbHasType?(:GHOST)) ||
					b.pbHasMoveFunction?("049") 
					denier=true
				end
			end    
			if user.pbOpposingSide.effects[PBEffects::StickyWeb] || denier
				score -= 95
			elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
				score -= 95   # Opponent can't switch in any Pokemon
			else
				maxownspeed=0
				ownparty = @battle.pbParty(user.index)
				ownparty.each_with_index do |pkmn, idxParty|
					maxownspeed = pkmn.speed if pkmn.speed>maxownspeed
				end
				party = @battle.pbParty(target.index)
				inBattleIndices = @battle.allSameSideBattlers(target.index).map { |b| b.pokemonIndex }
				count = 0
				party.each_with_index do |pkmn, idxParty|
					next if !pkmn || !pkmn.able?
					next if inBattleIndices.include?(idxParty)
					next if pkmn.item == :HEAVYDUTYBOOTS || pkmn.ability == :CLEARBODY || pkmn.ability == :FULLMETALBODY
					if pkmn.ability == :CONTRARY || pkmn.ability == :DEFIANT || pkmn.ability == :COMPETITIVE
						count-=1
					else  
						count += 1
						count += 1 if pkmn.speed>=maxownspeed
					end 
				end
				score += 10 * count
			end
			
			#---------------------------------------------------------------------------
		when "0A2" # Reflect
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxphys=(bestmove[3]=="physical") 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxphys
				score+=40 if halfhealth>maxdam
				score+=60
				if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)))
			score = 5 if user.pbOwnSide.effects[PBEffects::Reflect] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			
			#---------------------------------------------------------------------------
		when "0A3" # Light Screen
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxspec=(bestmove[3]=="special") 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxspec
				score+=40 if halfhealth>maxdam
				score+=60
				if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)))
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			#---------------------------------------------------------------------------
		when "167" # Aurora Veil
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			score+=40 if halfhealth>maxdam
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			else
				halfdam=maxdam/2
				score+=80 if halfdam<user.hp
			end    
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)))
			score =5 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || @battle.pbWeather != :Hail || 
			user.pbOwnSide.effects[PBEffects::Reflect] > 1 || user.pbOwnSide.effects[PBEffects::LightScreen] > 1
			#---------------------------------------------------------------------------
		when "0FF" # Sunny Day
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			water=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						water= (j.type==:WATER)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:HEATROCK)
			score+=30 if halfhealth>maxdam || (target.status == :SLEEP && target.statusCount>1)
			score+=40 if water && ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			if @battle.pbWeather != :Sun && @battle.pbWeather != :None
				score+=20
			end
			score+=10 if user.pbHasMoveFunction?("0D8", "028")
			score+=20 if user.pbHasMoveFunction?("0C4")
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :FIRE
				score += 20
			end    
			if user.hasActiveAbility?(:CHLOROPHYLL)
				score+=20
				score+=40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
			end    
			score+=20 if user.hasActiveAbility?(:FLOWERGIFT) || user.hasActiveAbility?(:SOLARPOWER) || user.hasActiveAbility?(:PROTOSYNTHESIS)
			score-=50 if user.hasActiveAbility?(:DRYSKIN)
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :CHLOROPHYLL
				score+=20 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER || pkmn.ability == :PROTOSYNTHESIS
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :FIRE
					score += 20
				end   
				score+=10 if pkmn.pbHasMoveFunction?("0D8", "028")
				score+=20 if pkmn.pbHasMoveFunction?("0C4") 
			end
			party = @battle.pbParty(target.index)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if pkmn.ability == :SWIFTSWIM && @battle.pbWeather == :Rain
					score+=40
				end 
				if (pkmn.ability == :SLUSHRUSH && @battle.pbWeather == :Hail) || (pkmn.ability == :SANDRUSH && @battle.pbWeather == :Sandstorm)
					score+=20
				end 
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :WATER
					score += 20
				end    
			end
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score -=200
			elsif @battle.pbWeather == :Sun
				score -=200
			end
			#---------------------------------------------------------------------------
		when "100"  # Rain Dance
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			fire=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						fire= (j.type==:FIRE)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:DAMPROCK)
			score+=30 if halfhealth>maxdam || (target.status == :SLEEP && target.statusCount>1)
			score+=40 if fire && ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			if @battle.pbWeather != :Rain && @battle.pbWeather != :None
				score+=20
			end
			score-=20 if user.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather == :Sun
			score+=10 if user.pbHasMoveFunction?("008")
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :WATER
				score += 20
			end    
			if user.hasActiveAbility?(:SWIFTSWIM)
				score+=20
				score+=40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
			end    
			score+=20 if user.hasActiveAbility?(:RAINDISH) || user.hasActiveAbility?(:DRYSKIN) || user.hasActiveAbility?(:HYDRATION)
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SWIFTSWIM
				score+=20 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :WATER
					score += 20
				end   
				score-=10 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather == :Sun
				score+=10 if pkmn.pbHasMoveFunction?("008") 
			end
			party = @battle.pbParty(target.index)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if pkmn.ability == :CHLOROPHYLL && @battle.pbWeather == :Sun
					score+=40
				end 
				if (pkmn.ability == :SLUSHRUSH && @battle.pbWeather == :Hail) || (pkmn.ability == :SANDRUSH && @battle.pbWeather == :Sandstorm)
					score+=20
				end 
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :FIRE
					score += 20
				end    
			end
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score -=200
			elsif @battle.pbWeather == :Rain
				score -=200
			end
			#---------------------------------------------------------------------------
		when "101"  # Sandstorm
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxspec=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						maxspec=j.specialMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:SMOOTHROCK)
			score+=30 if halfhealth>maxdam || (target.status == :SLEEP && target.statusCount>1)
			score+=20 if maxspec && ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.pbHasType?(:ROCK)
			score+=20 if user.pbHasType?(:ROCK)
			if !user.hasActiveItem?(:SAFETYGOGGLES) && !user.hasActiveItem?(:UTILITYUMBRELLA) && 
				!user.pbHasType?(:ROCK) && !user.pbHasType?(:STEEL) && !user.pbHasType?(:GROUND) &&
				!user.hasActiveAbility?(:MAGICGUARD) && !user.hasActiveAbility?(:OVERCOAT) && 
				!user.hasActiveAbility?(:SANDVEIL) && !user.hasActiveAbility?(:SANDRUSH) && !user.hasActiveAbility?(:SANDFORCE)
				score-=10
				score-=40 if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
			end    
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			score-=20 if user.pbHasMoveFunction?("0D8", "028", "0C4")
			score+=20 if user.pbHasMoveFunction?("16D")
			if user.hasActiveAbility?(:SANDRUSH)
				score+=20
				score+=40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
			end    
			score+=20 if user.hasActiveAbility?(:SANDVEIL) || user.hasActiveAbility?(:SANDFORCE)
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SANDRUSH
				score+=20 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
				score+=20 if pkmn.hasType?(:ROCK)
				score-=10 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather == :Sun
				score+=20 if pkmn.pbHasMoveFunction?("16D") 
			end
			party = @battle.pbParty(target.index)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if (pkmn.ability == :CHLOROPHYLL && @battle.pbWeather == :Sun) || (pkmn.ability == :SWIFTSWIM && @battle.pbWeather == :Rain)
					score+=40
				end 
				if (pkmn.ability == :SLUSHRUSH && @battle.pbWeather == :Hail)
					score+=20
				end 
			end
			@battle.allOtherSideBattlers(user.index).each do |b|
				score+=80 if b.hasActiveAbility?(:WONDERGUARD) && !b.pbHasType?(:ROCK) && !b.pbHasType?(:GROUND) && !b.pbHasType?(:STEEL)
			end	
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score -=200
			elsif @battle.pbWeather == :Sandstorm
				score -=200
			end
			#------------------------------------------------------------------
		when "102"  # Hail
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxphys=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						maxphys=j.physicalMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:ICYROCK)
			score+=30 if halfhealth>maxdam || (target.status == :SLEEP && target.statusCount>1)
			#score+=20 if maxphys && aspeed>ospeed && user.pbHasType?(:ICE) # DemICE alas, not in this game
			score+=20 if user.pbHasType?(:ICE)
			if !user.hasActiveItem?(:SAFETYGOGGLES) && !user.hasActiveItem?(:UTILITYUMBRELLA) && 
				!user.pbHasType?(:ICE) && !user.pbHasType?(:STEEL) && !user.pbHasType?(:GROUND) &&
				!user.hasActiveAbility?(:MAGICGUARD) && !user.hasActiveAbility?(:OVERCOAT) && 
				!user.hasActiveAbility?(:SANDVEIL) && !user.hasActiveAbility?(:SANDRUSH) && !user.hasActiveAbility?(:SANDFORCE)
				score-=10
				score-=40 if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
			end    
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			score-=20 if user.pbHasMoveFunction?("0D8", "028", "0C4")
			score+=20 if user.pbHasMoveFunction?("00D")
			score+=40 if user.pbHasMoveFunction?("167")
			if user.hasActiveAbility?(:SLUSHRUSH)
				score+=20
				score+=40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
			end    
			score+=20 if user.hasActiveAbility?(:SNOWCLOAK) || user.hasActiveAbility?(:ICEBODY)
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SLUSHRUSH
				score+=20 if pkmn.ability == :SNOWCLOAK || pkmn.ability == :ICEBODY
				#score+=20 if pkmn.hasType?(:ICE)
				score-=10 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather == :Sun
				score+=20 if pkmn.pbHasMoveFunction?("00D") 
				score+=20 if pkmn.pbHasMoveFunction?("167") 
			end
			party = @battle.pbParty(target.index)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if (pkmn.ability == :CHLOROPHYLL && @battle.pbWeather == :Sun) || (pkmn.ability == :SWIFTSWIM && @battle.pbWeather == :Rain)
					score+=40
				end 
				if (pkmn.ability == :SANDRUSH && @battle.pbWeather == :Sandstorm)
					score+=20
				end 
			end
			@battle.allOtherSideBattlers(user.index).each do |b|
				score+=80 if b.hasActiveAbility?(:WONDERGUARD) && !b.pbHasType?(:ICE)
			end	
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score -=200
			elsif @battle.pbWeather == :Hail
				score -=200
			end   
			#---------------------------------------------------------------------------
		when "154"  # Electric Terrain
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxphys=false
			maxspec=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						maxphys=j.physicalMove?(j.type)
						maxspec=j.specialMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.hasActiveItem?(:ELECTRICSEED) & maxphys
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && target.pbHasMoveFunction?("003","004")
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :ELECTRIC
				score += 10
			end  
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
			# score+=30 if user.pbHasMoveFunction?("DoublePowerInElectricTerrain")
			if user.hasActiveAbility?(:SURGESURFER)
				score+=20
				score+=40 if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
			end    
			score+=20 if user.hasActiveAbility?(:QUARKDRIVE)
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SURGESURFER
				score+=20 if pkmn.ability == :QUARKDRIVE
				score+=20 if pkmn.item == :ELECTRICSEED
				# score+=20 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
				# score+=30 if pkmn.pbHasMoveFunction?("DoublePowerInElectricTerrain") 
			end
			if @battle.field.terrain == :Electric
				score -=200
			end   
			#---------------------------------------------------------------------------
		when "155"  # Grassy Terrain
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxmove="none"
			maxphys=false
			maxspec=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						maxmove=j.function
						maxphys=j.physicalMove?(j.type)
						maxspec=j.specialMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.hasActiveItem?(:GRASSYSEED) & maxphys
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && (maxmove == "076" || maxmove == "095" || maxmove == "044") # Earthquake, Magnitude, Bulldoze
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :GRASS
				score += 10
			end  
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			score+=20 if user.pbHasMoveFunction?("16E") # Floral Healing
			#score+=30 if user.pbHasMoveFunction?("HigherPriorityInGrassyTerrain")
			if user.hasActiveAbility?(:GRASSPELT)
				score+=20
				score+=20 if maxphys && ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			end    
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=20 if pkmn.ability == :GRASSPELT
				score+=20 if pkmn.item == :GRASSYSEED
				score-=20 if pkmn.pbHasMoveFunction?("076", "095","044") # Earthquake, Magnitude, Bulldoze
				score+=20 if pkmn.pbHasMoveFunction?("16E")
				#score+=40 if pkmn.pbHasMoveFunction?("HigherPriorityInGrassyTerrain") 
			end
			if @battle.field.terrain == :Grassy
				score -=200
			end   
			#---------------------------------------------------------------------------
		when "156"  # Misty Terrain
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			dragon=false
			maxphys=false
			maxspec=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						dragon= (j.type==:DRAGON)
						maxphys=j.physicalMove?(j.type)
						maxspec=j.specialMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=40 if dragon && ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.hasActiveItem?(:MISTYSEED) & maxspec
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			target.eachMove do |m|
				next if m.baseDamage>20
				score += 20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && (m.function=="007")
				score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && target.pbHasMoveFunction?("003", "004")
			end                                                        
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
			# score+=30 if user.pbHasMoveFunction?("UserFaintsPowersUpInMistyTerrainExplosive")
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=20 if pkmn.item == :MISTYSEED
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :DRAGON
					score -= 20
				end   
				score-=20 if pkmn.pbHasMoveFunction?("003", "004","006")
				# score+=20 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
				# score+=30 if pkmn.pbHasMoveFunction?("UserFaintsPowersUpInMistyTerrainExplosive") 
			end
			if @battle.field.terrain == :Misty
				score -=200
			end   
			#---------------------------------------------------------------------------
		when "173"  # Psychic Terrain
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			prio=false
			maxphys=false
			maxspec=false
			@battle.allOtherSideBattlers(user.index).each do |b|
				for j in b.moves
					if moveLocked(b)
						if b.lastMoveUsed && b.pbHasMove?(b.lastMoveUsed)
							next if j.id!=b.lastMoveUsed
						end
					end	
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						prio= priorityAI(b,j) > 0
						maxphys=j.physicalMove?(j.type)
						maxspec=j.specialMove?(j.type)
					end    
				end 
			end   
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :PSYCHIC
				score += 10
			end  
			score+=40 if prio
			score+=20 if target.hasActiveAbility?(:PRANKSTER)
			score+=20 if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && user.hasActiveItem?(:PSYCHICSEED) & maxspec
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			score+=20 if target.pbHasMoveFunction?("116")                                       
			if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
			# score+=30 if user.pbHasMoveFunction?("HitsAllFoesAndPowersUpInPsychicTerrain")
			ownparty = @battle.pbParty(user.index)
			inBattleIndices = @battle.allSameSideBattlers(user.index).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score-=10 if pkmn.ability == :PRANKSTER
				score+=20 if pkmn.item == :PSYCHICSEED
				pkmn.eachMove do |m|
					score -= 5 if m.priority>0
				end   
				# score+=20 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
				# score+=30 if pkmn.pbHasMoveFunction?("HitsAllFoesAndPowersUpInPsychicTerrain") 
			end
			if @battle.field.terrain == :Psychic
				score -=200
			end 
			#---------------------------------------------------------------------------
		when "0EE"  # U-Turn , Volt Switch , Flip Turn
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			score -= 30 if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
			user.pbOwnSide.effects[PBEffects::Spikes]>0 || user.pbOwnSide.effects[PBEffects::StickyWeb]
			if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && !(target.status == :SLEEP && target.statusCount>1)
				score -= 30 # DemICE: Switching AI is dumb so if you're faster, don't sack a healthy mon. Better use another move.
			else
				score +=30 if user.hasActiveAbility?(:REGENERATOR)
				score +=30 if user.effects[PBEffects::Toxic]>3
				score +=30 if user.effects[PBEffects::Curse]
				score +=30 if user.effects[PBEffects::PerishSong]==1
				score +=30 if user.effects[PBEffects::LeechSeed]>=0
			end    
			#---------------------------------------------------------------------------
			# when "SwitchOutUserStatusMove"  # Teleport
			# target=user.pbDirectOpposing(true)
			# aspeed = pbRoughStat(user,:SPEED,skill)
			# ospeed = pbRoughStat(target,:SPEED,skill)
			# score -= 30 if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
			# user.pbOwnSide.effects[PBEffects::Spikes]>0 || user.pbOwnSide.effects[PBEffects::StickyWeb]
			# score +=30 if user.hasActiveAbility?(:REGENERATOR)
			# score +=30 if user.effects[PBEffects::Toxic]>3
			# score +=30 if user.effects[PBEffects::Curse]
			# score +=30 if user.effects[PBEffects::PerishSong]==1
			# score +=30 if user.effects[PBEffects::LeechSeed]>=0
			# score +=30 if target.status == :SLEEP && target.statusCount>1
		#---------------------------------------------------------------------------
		when "0ED" # Baton PAss
			attacker=user
			opponent=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(opponent,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxoppdam=0
			maxoppmove=nil
			for j in opponent.moves
				if moveLocked(opponent)
					if opponent.lastMoveUsed && opponent.pbHasMove?(opponent.lastMoveUsed)
						next if j.id!=opponent.lastMoveUsed
					end
				end		
				tempdam = pbRoughDamage(j,opponent,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,opponent,user,100)
				if tempdam>maxoppdam
					maxoppdam=tempdam 
					maxoppmove=j
				end	
			end 
			party=@battle.pbParty(attacker.index)
			sack=false
			sack=true if ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			stagemult=1
			swapper=attacker.pokemonIndex
			switchin=pbHardSwitchChooseNewEnemy(attacker.index,party,sack,true)
			if switchin
				if switchin.is_a?(Array)
					swapper=switchin[0]
				else
					swapper=switchin
				end
			end
			if @battle.pbCanChooseNonActive?(attacker.index) && swapper!=attacker.pokemonIndex
				if targetSurvivesMove(maxmove,attacker,opponent)
					stagemult+=1
					if sack
						stagemult+=2
						case attacker.status
						when :BURN
							stagemult+=5 if maxmove.physicalMove? && !attacker.hasActiveAbility?(:GUTS)
						when :POISON
							stagemult+=5 if !attacker.hasActiveAbility?(:POISONHEAL) && !attacker.hasActiveAbility?(:GUTS)
						when :PARALYSIS
							stagemult+=5 if maxdam>=attacker.hp/3
						end
					end	
				end
				if (opponent.status == :SLEEP && opponent.statusCount==2)
						stagemult+=5 if targetSurvivesMove(maxmove,attacker,opponent) 
						stagemult+=5 if !targetSurvivesMove(maxoppmove,opponent,attacker)
				end		
				GameData::Stat.each_battle do |stat|
					next if attacker.pbHasMoveFunction?("10D") && attacker.stages[stat.id]<0 && stat.id==:SPEED
					score += stagemult*attacker.stages[stat.id]
				end	
				if attacker.effects[PBEffects::Substitute]>0
					score+=30
				end
				if attacker.effects[PBEffects::Confusion]>0
					score-=20
				end
				if attacker.effects[PBEffects::LeechSeed]>=0
					score-=40
				end
				if attacker.effects[PBEffects::Curse]
					score-=40
				end
				if attacker.effects[PBEffects::Yawn]>0
					score-=20
				end
				score+=10 if attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing]
				score-=200 if attacker.effects[PBEffects::PerishSong]>0
				if attacker.turnCount<1
					score-=30
				end
				score-=20 if @battle.pbSideSize(attacker.index)>1
			else
				score-=200
			end
			#---------------------------------------------------------------------------
		when "0A6" # Lock-On / Mind Reader
			if user.effects[PBEffects::LockOn]>0 || target.effects[PBEffects::Substitute]>0
				score -=200
			else
				found=false
				for m in user.moves
					found=true if m.function=="070" && !pbCheckMoveImmunity(1,m,user,target,100)
				end
				score +=90 if found
			end
			#---------------------------------------------------------------------------
		when "0DE" # Dream Eater
			if !target.asleep?
				score -= 2000
			elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
				score -= 70
			else
				score += 20 if user.hp<=user.totalhp/2
			end
			#---------------------------------------------------------------------------
			when "0DD" # 50% drain ex. Giga Drain
			  if skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
				score -= 500
			  elsif user.hp <= user.totalhp / 2
				score += 20
			  end
			#---------------------------------------------------------------------------
			when "14F" # 75% drain ex. Draining Kiss, Oblivion Wing
			  if skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
				score -= 750
			  elsif user.hp <= user.totalhp / 2
				score += 40
			  end
			#---------------------------------------------------------------------------
		when "150" # Fell Stinger
			# Yes, this is my change. To override the one in AI_Move_Effectscores_1 that treats the move like fucking Swords Dance >.>
			# This is now handled in pbGetMoveScoreDamage.
			#---------------------------------------------------------------------------
		when "05B" # Tailwind
			target=user.pbDirectOpposing(true)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			if targetSurvivesMove(maxmove,target,attacker) || (target.status == :SLEEP && target.statusCount>1)
				#score += 40
				pspeed=0
				espeed=0
				if skill>=PBTrainerAI.highSkill
					minspeed=0
					@battle.allSameSideBattlers(user.index).each do |b|
						pspeed = pbRoughStat(b,:SPEED,skill)
						pspeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						minspeed=pspeed if pspeed<minspeed
					end
					maxspeed=0
					@battle.allSameSideBattlers(target.index).each do |b|
						espeed = pbRoughStat(b,:SPEED,skill)
						espeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						maxspeed=espeed if espeed>maxspeed
					end
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 100 if (((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))) || 
									(((aspeed<espeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((aspeed*2>espeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))) ||
									(((pspeed<espeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((pspeed*2>espeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))) || 
									(((pspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)) && ((pspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1)))
				end
			end
			score -=200 if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
			#---------------------------------------------------------------------------
		when "11F" # Trick Room
			target=user.pbDirectOpposing(true)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxprio=bestmove[2]
			if targetSurvivesMove(maxmove,target,attacker,maxprio) || maxprio==0 || (target.status == :SLEEP && target.statusCount>1)
				#score += 40
				pspeed=0
				espeed=0
				if skill>=PBTrainerAI.highSkill
					minspeed=0
					@battle.allSameSideBattlers(user.index).each do |b|
						pspeed = pbRoughStat(b,:SPEED,skill)
						pspeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						minspeed=pspeed if pspeed<minspeed
					end
					maxspeed=0
					@battle.allSameSideBattlers(target.index).each do |b|
						espeed = pbRoughStat(b,:SPEED,skill)
						espeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						maxspeed=espeed if espeed>maxspeed
					end
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) ||
						((minspeed<maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
						score += 140 
					else
						score -= 200
					end
				end
			end
			#---------------------------------------------------------------------------
			when "0AA", "14C", "168" , "14B"  # Protect
				target=user.pbDirectOpposing(true)
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxprio=bestmove[2]
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				ownhpchange=(EndofTurnHPChanges(user,target,false,false,true)) # what % of our hp will change after end of turn effects go through
				opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
				score -= 200 if maxdam < (user.hp * 0.1)
				if @battle.positions[user.index].effects[PBEffects::Wish]>0
					score+=140 if (maxdam >= @battle.positions[user.index].effects[PBEffects::WishAmount] || maxdam >= user.hp)
				else
					if ownhpchange > opphpchange
						score += 90 
					end
					if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && maxdam>0
						if user.hasActiveAbility?(:SPEEDBOOST) && !target.hasActiveAbility?(:SPEEDBOOST) 
							if @battle.field.effects[PBEffects::TrickRoom]<2
								score+=60
								score+=80 if (aspeed * 1.5) > ospeed
							else
								score-=90
							end
						end
						if target.pbOwnSide.effects[PBEffects::Tailwind] > user.pbOwnSide.effects[PBEffects::Tailwind]
							if @battle.field.effects[PBEffects::TrickRoom]<2
								score+=60
								score+=80 if (aspeed * 2) > ospeed
							else
								score-=90
							end
						end
					end
					if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
						if (target.pbOwnSide.effects[PBEffects::AuroraVeil] > user.pbOwnSide.effects[PBEffects::AuroraVeil])
							score+=90
						else
							score-=90
						end
					end
					bestownmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxowndam=bestmove[0] 
					maxownmove=bestmove[1]
					maxownprio=bestmove[2]
					if target.effects[PBEffects::Rollout] > 0 && maxdam>0
						if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
							score+=140
						else
							score+=140 if targetSurvivesMove(maxownmove,user,target,maxownprio)
						end
					end
					score += 90 if target.effects[PBEffects::TwoTurnAttack]
				end
				score-=90 if target.pbHasMoveFunction?("024","025","026","036",
					"02B","02C","027", "028","01C",
					"02E","029","032","039","035") # Setup
			  if user.effects[PBEffects::ProtectRate]>1 
				if ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) &&
					targetSurvivesMove(maxmove,target,user,maxprio)
					score -= 300
				end
			#   else
			# 	if skill>=PBTrainerAI.mediumSkill
			# 	  score -= user.effects[PBEffects::ProtectRate]*40
			# 	end
			  end
			#---------------------------------------------------------------------------
		when "0DC" # Leech Seed
			attacker=user
			opponent=target
			if (opponent.effects[PBEffects::LeechSeed]<0 && !opponent.pbHasType?(:GRASS) && opponent.effects[PBEffects::Substitute]<=0) 
				if attacker.effects[PBEffects::Substitute]>0
					score+=30
				end
				if opponent.hp==opponent.totalhp
					score+=30
				# else
				# 	score*=(opponent.hp*(1.0/opponent.totalhp))
				end
				if attacker.hasActiveItem?(:LEFTOVERS) || attacker.hasActiveItem?(:BIGROOT) || (attacker.hasActiveItem?(:BLACKSLUDGE) && attacker.pbHasType?(:POISON))
					score+=10
				end
				if attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing]
					score+=10
				end
				if attacker.hasWorkingAbility(:RAINDISH) && @battle.pbWeather==:RAINDANCE
					score+=10
				end
				if opponent.status==:PARALYSIS || opponent.status==:SLEEP
					score+=10
				end
				if opponent.effects[PBEffects::Confusion]>0
					score+=10
				end
				if opponent.effects[PBEffects::Attract]>=0
					score+=10
				end
				if opponent.status==:POISON || opponent.status==:BURN
					score+=10
				end
				score+=80 if target.hasActiveAbility?(:WONDERGUARD)
				score-=50 if target.pbHasMoveFunction?("0EE") # U-Turn
				if opponent.hp*2<opponent.totalhp
					score-=10
					if opponent.hp*4<opponent.totalhp
						score-=80
					end
				end
				protectmove=false
				protectmove = true if attacker.pbHasMoveFunction?("168", "0AA", "14C")
				if protectmove
					score+=20
				end
				if opponent.hasWorkingAbility(:LIQUIDOOZE)
					score-=100
				end
			else
				score-=100
			end
			#---------------------------------------------------------------------------
		when "0D5", "0D6", "0D8", "16D" # Recover, Roost, Synthesis, Shore Up
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			fastermon=((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			fasterhealing=fastermon || user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE)
			if move.function == "0D8" 
				case @battle.pbWeather
				when :Sun, :HarshSun
					halfhealth=(user.totalhp*2/3)
				when :None
					halfhealth=(user.totalhp/2)
				else
					halfhealth=(user.totalhp/4)
				end
			elsif move.function == "16D" 
				case @battle.pbWeather
				when :Sandstorm
					halfhealth=(user.totalhp*2/3)
				else
					halfhealth=(user.totalhp/2)
				end   
			else     
				halfhealth=(user.totalhp/2)
			end    
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
			#if maxdam>user.hp
			if !targetSurvivesMove(maxmove,target,user)
				if maxdam>(user.hp+halfhealth)
					score=0
				else
					if maxdam>=halfhealth
						if fasterhealing
							score*=0.5
						else
							score*=0.1
						end
					else
						score*=2
					end
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if !fastermon
					if maxdam*2>user.hp
						score*=2
					end
				end
			end
			hpchange=(EndofTurnHPChanges(user,target,false,false,true)) # what % of our hp will change after end of turn effects go through
			opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
			if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
				oppchipdamage=((target.totalhp*(1-hpchange)))
			end
			thisdam=maxdam#*1.1
			hplost=(user.totalhp-user.hp)
			hplost+=maxdam if !fasterhealing
			if user.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,user)
				score *= 0.3 
			end	
			if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
				chipdamage=((user.totalhp*(1-hpchange)))
				thisdam+=chipdamage
			elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
				healing=((user.totalhp*(hpchange-1)))
				thisdam-=healing if !(thisdam>user.hp)
			elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
				score*=0
			end
			if thisdam>hplost
				score*=0.1
			else
				if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
					score*=0.01
				end
				if thisdam<=(halfhealth)
					score*=2
				else
					if fastermon
						if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
							score*=0.3
						end
					end
				end
			end
			score*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
				"02B","02C","027", "028","01C",
				"02E","029","032","039","035") # Setup
			if ((user.hp.to_f)<=halfhealth)
				score*=1.5
			else
				score*=0.5
			end
			score/=(user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]>0
			score*=0.8 if maxdam>halfhealth
			if target.hasActiveItem?(:METRONOME)
				met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
				score/=met
			end 
			score*=1.1 if user.status==:PARALYSIS || user.effects[PBEffects::Confusion]>0
			if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
				score*=1.3
				score*=1.3 if target.effects[PBEffects::Toxic]>0
				score*=1.3 if user.item == :BINDINGBAND
			end
			score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
			score*=0.6 if ((user.hp.to_f)/user.totalhp)>0.6
			score*=2 if ((user.hp.to_f)/user.totalhp)<0.25
			score=0 if @battle.positions[user.index].effects[PBEffects::Wish]>0	
			
			#---------------------------------------------------------------------------
		when "0D7" # Wish
			if @battle.positions[user.index].effects[PBEffects::Wish] == 0
				target=user.pbDirectOpposing(true)
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				fastermon=false#((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				fasterhealing=false#fastermon || user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE)
				halfhealth=(user.totalhp/2)
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] 
				maxmove=bestmove[1]
				maxdam=0 if (target.status == :SLEEP && target.statusCount>1)	
				mult=2
				mult=1 if user.pbHasMoveFunction?("0AA")	
				#if maxdam>user.hp
				if !targetSurvivesMove(maxmove,target,user,0,mult)
					# if maxdam>(user.hp+halfhealth)
						score=0
					# else
					# 	if maxdam>=halfhealth
					# 		if fasterhealing
					# 			score*=0.5
					# 		else
					# 			score*=0.1
					# 		end
					# 	else
					# 		score*=2
					# 	end
					# end
				# else
				# 	if maxdam*1.5>user.hp
				# 		score*=2
				# 	end
				# 	if !fastermon
				# 		if maxdam*2>user.hp
				# 			score*=2
				# 		end
				# 	end
				end
				hpchange=(EndofTurnHPChanges(user,target,false,false,true)) # what % of our hp will change after end of turn effects go through
				opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
				if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
					oppchipdamage=((target.totalhp*(1-hpchange)))
				end
				thisdam=maxdam#*1.1
				hplost=(user.totalhp-user.hp)
				hplost+=maxdam if !fasterhealing
				if user.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,user)
					score *= 0.3 
				end	
				if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
					chipdamage=((user.totalhp*(1-hpchange)))
					thisdam+=chipdamage
				elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
					healing=((user.totalhp*(hpchange-1)))
					thisdam-=healing if !(thisdam>user.hp)
				elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
					score*=0
				end
				# if thisdam>hplost
				# 	score*=0.1
				# else
					if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
						score*=0.01
					end
					if thisdam<=(halfhealth) && user.hp < thisdam*3 && user.hp > thisdam*mult
						score*=3
					# else
					# 	if fastermon
					# 		if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
					# 			score*=0.3
					# 		end
					# 	end
					end
				# end
				score*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
					"02B","02C","027", "028","01C",
					"02E","029","032","039","035") # Setup
				# if ((user.hp.to_f)/user.totalhp)<0.6
				# 	score*=1.5
				# else
				# 	score*=0.5
				# end
				score/=(user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]>0
				score*=0.8 if maxdam>halfhealth
				if target.hasActiveItem?(:METRONOME)
					met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
					score/=met
				end 
				score*=1.1 if user.status==:PARALYSIS || user.effects[PBEffects::Confusion]>0
				if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
					score*=1.3
					score*=1.3 if target.effects[PBEffects::Toxic]>0
					score*=1.3 if user.item == :BINDINGBAND
				end
				# score *=2 if user.totalhp-user.hp
				# score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
				# score*=1.5 if ((user.hp.to_f)/user.totalhp)>0.6
				# score*=2 if ((user.hp.to_f)/user.totalhp)<0.6
				score*=1.5 if user.pbHasMoveFunction?("0AA")
			else
				score=0 
			end
			#---------------------------------------------------------------------------
		when "160" # Strength Sap
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			fastermon=((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
			fasterhealing=fastermon || user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE) 
			healAmt=pbRoughStat(target,:ATTACK,skill)
			halfhealth=(healAmt/2)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			if !maxmove.nil?
				if maxmove.physicalMove?
					if target.hasActiveAbility?(:CONTRARY)
						maxdam *= 1.5 
					else
						maxdam *= 0.7 
					end
				end
				maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
				#if maxdam>user.hp
				if !targetSurvivesMove(maxmove,target,user)
					if maxdam>(user.hp+halfhealth)
						score=0
					else
						if maxdam>=halfhealth
							if fastermon
								score*=0.5
							else
								score*=0.1
							end
						else
							score*=2
						end
					end
				else
					if maxdam*1.5>user.hp
						score*=2
					end
					if !fastermon
						if maxdam*2>user.hp
							score*=2
						end
					end
				end
				hpchange=(EndofTurnHPChanges(user,target,false,false,true)) # what % of our hp will change after end of turn effects go through
				opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
				if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
					oppchipdamage=((target.totalhp*(1-hpchange)))
				end
				thisdam=maxdam#*1.1
				hplost=(user.totalhp-user.hp)
				hplost+=maxdam if !fasterhealing
				if user.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,user)
					score *= 0.3 
				end	
				if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
					chipdamage=((user.totalhp*(1-hpchange)))
					thisdam+=chipdamage
				elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
					healing=((user.totalhp*(hpchange-1)))
					thisdam-=healing if !(thisdam>user.hp)
				elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
					score*=0
				end
				if thisdam>hplost
					score*=0.1
				else
					if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
						score*=0.01
					end
					if thisdam<=(halfhealth)
						score*=2
					else
						if fastermon
							if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
								score*=0.3
							end
						end
					end
				end
				score*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
					"02B","02C","027", "028","01C",
					"02E","029","032","039","035") # Setup
				if ((user.hp.to_f)<=halfhealth)
					score*=1.5
				else
					score*=0.5
				end
				score/=(user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]>0
				score*=0.8 if maxdam>halfhealth
				if target.hasActiveItem?(:METRONOME)
					met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
					score/=met
				end 
				score*=1.1 if user.status==:PARALYSIS || user.effects[PBEffects::Confusion]>0
				if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
					score*=1.3
					score*=1.3 if target.effects[PBEffects::Toxic]>0
					score*=1.3 if user.item == :BINDINGBAND
				end
				score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
				score*=0.6 if ((user.hp.to_f)/user.totalhp)>0.6
				score*=2 if ((user.hp.to_f)/user.totalhp)<0.25
				score=0 if @battle.positions[user.index].effects[PBEffects::Wish]>0	
			end
			
			#---------------------------------------------------------------------------
		when "0D9" # Rest
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			fastermon=((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) || (user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE))         
			if user.hasActiveItem?(:CHESTOBERRY) || user.hasActiveItem?(:LUMBERRY)
				halfhealth=(user.totalhp*2/3)
			else    
				halfhealth=(user.totalhp/4)
			end    
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
			#if maxdam>user.hp
			if !targetSurvivesMove(maxmove,target,user)
				if maxdam>(user.hp+halfhealth)
					score=0
				else
					if maxdam>=halfhealth
						if fastermon
							score*=0.5
						else
							score*=0.1
						end
					else
						score*=2
					end
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if !fastermon
					if maxdam*2>user.hp
						score*=2
					end
				end
			end
			hpchange=(EndofTurnHPChanges(user,target,false,false,true,false,true)) # what % of our hp will change after end of turn effects go through
			opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
			if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
				oppchipdamage=((target.totalhp*(1-hpchange)))
			end
			thisdam=maxdam#*1.1
			hplost=(user.totalhp-user.hp)
			hplost+=maxdam if !fasterhealing
			if user.effects[PBEffects::LeechSeed]>=0 && !fastermon && canSleepTarget(target,user)
				score *= 0.3 
			end	
			if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
				chipdamage=((user.totalhp*(1-hpchange)))
				thisdam+=chipdamage
			elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
				healing=((user.totalhp*(hpchange-1)))
				thisdam-=healing if !(thisdam>user.hp)
			elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
				score*=0
			end
			if thisdam>hplost
				score*=0.1
			else
				if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
					score*=0.01
				end
				if thisdam<=(halfhealth)
					score*=2
				else
					if fastermon
						if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
							score*=0.3
						end
					end
				end
			end
			score*=0.7 if target.pbHasMoveFunction?("024","025","026","036",
				"02B","02C","027", "028","01C",
				"02E","029","032","039","035") # Setup
			if ((user.hp.to_f)<=halfhealth)
				score*=1.5
			else
				score*=0.8
			end
			score*=(user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]>0
			score*=0.8 if maxdam>halfhealth
			if target.hasActiveItem?(:METRONOME)
				met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
				score/=met
			end 
			score*=1.1 if user.status==:PARALYSIS || user.effects[PBEffects::Confusion]>0
			if target.status==:POISON || target.status==:BURN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse] || target.effects[PBEffects::Trapping]>0
				score*=1.3
				score*=1.3 if target.effects[PBEffects::Toxic]>0
				score*=1.3 if user.item == :BINDINGBAND
			end
			score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
			score*=0.6 if ((user.hp.to_f)/user.totalhp)>0.6
			score*=2 if ((user.hp.to_f)/user.totalhp)<0.25
			score=0 if @battle.positions[user.index].effects[PBEffects::Wish]>0	
			
		else
			score = stupidity_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
		end
		
		return score-initialscore
	end
	
	def EndofTurnHPChanges(user,target,heal,chips,both,switching=false,rest=false)
		#### Azery: function below sums up all the changes to hp that will occur after the battle round. Healing from various effects/items/statuses or damage from the same. 
		### the arguments above show which ones in specific we're looking for, both being the typical default for most but sometimes we're only looking to see how much damage will occur at the end or how much healing.
		### thus it will return at 3 different points; end of healing if heal is desired, end of chip if chip is desired or at the very end if both.
		healing = 1  
		chip = 0
		oppitemworks = target.itemActive?
		attitemworks = user.itemActive?
		skill=100
		if (user.effects[PBEffects::AquaRing])==true
			subscore = 0
			subscore *= 1.3 if attitemworks && user.item == :BIGROOT
			healing += subscore
		end
		if user.effects[PBEffects::Ingrain]
			subscore = 0
			subscore *= 1.3 if attitemworks && user.item == PBItems::BIGROOT
			healing += subscore
		end
		healing += 0.0625 if user.hasWorkingAbility(:DRYSKIN) &&  @battle.pbWeather==:Rain
		healing += 0.0625 if attitemworks && (user.item == :LEFTOVERS || (user.item == :BLACKSLUDGE && user.pbHasType?(:POISON)))
		healing += 0.0625 if user.hasWorkingAbility(:RAINDISH) && @battle.pbWeather==:Rain
		healing += 0.0625 if  user.hasWorkingAbility(:ICEBODY) && @battle.pbWeather==:Hail
		healing += 0.125 if user.status == :POISON && user.hasWorkingAbility(:POISONHEAL)
		healing += 0.125 if (target.effects[PBEffects::LeechSeed]>-1 && !target.hasWorkingAbility(:LIQUIDOOZE)) 
		healing*=0 if user.effects[PBEffects::HealBlock]>0
		return healing if heal
		if !(user.hasWorkingAbility(:MAGICGUARD)) 
			if !(attitemworks && user.item == :SAFETYGOGGLES) || !(user.hasWorkingAbility(:OVERCOAT)) 
				weatherchip = 0
				weatherchip += 0.0625 if @battle.pbWeather==:Sun && (user.hasWorkingAbility(:DRYSKIN))
				if @battle.pbWeather==:Sandstorm && !(user.pbHasType?(:ROCK) || user.pbHasType?(:STEEL) || user.pbHasType?(:GROUND)) && !(user.hasWorkingAbility(:SANDVEIL) || user.hasWorkingAbility(:SANDFORCE) || user.hasWorkingAbility(:SANDRUSH))				 
					weatherchip += 0.0625
				end	
				if @battle.pbWeather==:Hail && !(user.pbHasType?(:ICE)) && !(user.hasWorkingAbility(:ICEBODY) || user.hasWorkingAbility(:SNOWCLOAK) || user.hasWorkingAbility(:SLUSHRUSH)) 				 				 
					weatherchip += 0.0625
				end	 
				chip += weatherchip
			end
			if user.effects[PBEffects::Trapping]>0
				multiturnchip = 0.125 
				multiturnchip *= 1.3333 if (target.item == :BINDINGBAND)
				chip+=multiturnchip
			end
			chip += 0.125 if (user.effects[PBEffects::LeechSeed]>=0 || (target.effects[PBEffects::LeechSeed]>=0 && target.hasWorkingAbility(:LIQUIDOOZE))) 
			chip += 0.25  if (user.effects[PBEffects::Curse]) 
			if user.status!=:NONE && !rest
				statuschip = 0
				statuschip += 0.0625 if user.status==:BURN 
				statuschip += 0.125 if ((user.status==:POISON &&  !user.hasWorkingAbility(:POISONHEAL) && user.effects[PBEffects::Toxic]==0)) || (user.status == :SLEEP && target.hasWorkingAbility(:BADDREAMS)) 
				statuschip += (0.0625*user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]!=0 && !(user.hasWorkingAbility(:POISONHEAL)) 
				chip+=statuschip
			end
		end
		return chip if chips
		diff=(healing-chip)
		return diff if both
	end
	
    def targetSurvivesMove(move,attacker,opponent,priodamage=0,mult=1)
		return true if !move
		mold_broken=moldbroken(attacker,opponent,move.function)
		damage=pbRoughDamage(move,attacker,opponent,100)
		damage+=priodamage
		damage*=mult
		# if opponent.name=="Darkbat" && attacker.name=="Metarill" && move.name=="Play Rough"
		# 	print damage
		# 	print opponent.hp
		# end
		if !mold_broken && opponent.hasActiveAbility?(:DISGUISE) && opponent.turnCount==0	
			if ["0C0", "0BD", "175", "0BF"].include?(move.function)
				damage*=0.6
			else
				damage=1
			end
		end			
		return true if damage < opponent.hp
		return false if priodamage>0
		if (opponent.hasActiveItem?(:FOCUSSASH) || (!mold_broken && opponent.hasActiveAbility?(:STURDY))) && opponent.hp==opponent.totalhp
			return false if ["0C0", "0BD", "175", "0BF"].include?(move.function)
			return true
		end	
		return false
	end

	def canSleepTarget(attacker,opponent,berry=false)
		return false if opponent.effects[PBEffects::Substitute]>0
		return false if berry && (opponent.status==:SLEEP)# && opponent.statusCount>1)
		return false if (opponent.hasActiveItem?(:LUMBERRY) || opponent.hasActiveItem?(:CHESTOBERRY)) && berry
		return false if opponent.pbCanSleep?(attacker,false)
		return false if opponent.pbOwnSide.effects[PBEffects::Safeguard] > 0 && !attacker.hasActiveAbility?(:INFILTRATOR)
		for move in attacker.moves
			if ["003", "004"].include?(move.function)
				return false if move.powderMove? && opponent.pbHasType?(:GRASS)
				return true	
			end	
		end	
		return false
	end
	
	def bestMoveVsTarget(user,target,skill)
		maxdam=0
		maxmove=nil
		maxprio=0
		physorspec="none"
		for j in user.moves
			if moveLocked(user)
				if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
					next if j.id!=user.lastMoveUsed
				end
			end		
			tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
			tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
			if tempdam>maxdam
				maxdam=tempdam 
				maxmove=j
				physorspec="physical" if j.physicalMove?(j.type)
				physorspec="special" if j.specialMove?(j.type)
			end	
			if priorityAI(user,j) > 0
				maxprio=tempdam if tempdam>maxprio
			end	
		end 
		return [maxdam,maxmove,maxprio,physorspec]
	end	



	def priorityAI(user,move,switchin=false)
		turncount = user.turnCount
		turncount = 0 if switchin
		pri = move.priority
		pri +=1 if user.hasWorkingAbility(:GALEWINGS) && user.hp==user.totalhp && move.type==:FLYING
		pri +=1 if move.baseDamage==0 && user.hasActiveAbility?(:PRANKSTER)
		pri +=1 if move.function=="HigherPriorityInGrassyTerrain" && @battle.field.terrain==:Grassy && user.affectedByTerrain?
		pri +=3 if move.healingMove? && user.hasActiveAbility?(:TRIAGE)
		return pri
	end
	
	def moveLocked(user)
		return true if user.effects[PBEffects::ChoiceBand] && user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
		return true if user.usingMultiTurnAttack?
		return true if user.effects[PBEffects::Encore] > 0
		return true if user.hasActiveAbility?(:GORILLATACTICS)
		return false
	end

	# def statchangecounter(mon,initial,final,limiter=0)
	# 	count = 0
	# 	case limiter
	# 	when 0 #all stats
	# 		for i in initial..final
	# 			count += mon.stages[i]
	# 		end
	# 	when 1 #increases only
	# 		for i in initial..final
	# 			count += mon.stages[i] if mon.stages[i]>0
	# 		end
	# 	when -1 #decreases only
	# 		for i in initial..final
	# 			count += mon.stages[i] if mon.stages[i]<0
	# 		end
	# 	end
	# 	return count
	# end

end

class Pokemon
	
	def isAirborne?
		return false if @item == :IRONBALL
		return true if hasType?(:FLYING)
		return true if @ability == :LEVITATE
		return true if @item == :AIRBALLOON
		return false
	end
	
	def eachMove
		@moves.each { |m| yield m }
	end  
	
	def pbHasMoveFunction?(*arg)
		return false if !arg
		eachMove do |m|
			arg.each { |code| return true if m.function_code == code }
		end
		return false
	end    
	
end    


class PokeBattle_Battle
	
	def allOtherSideBattlers(idxBattler = 0)
		idxBattler = idxBattler.index if idxBattler.respond_to?("index")
		return @battlers.select { |b| b && !b.fainted? && b.opposes?(idxBattler) }
	end

	def allSameSideBattlers(idxBattler = 0)
		idxBattler = idxBattler.index if idxBattler.respond_to?("index")
		return @battlers.select { |b| b && !b.fainted? && !b.opposes?(idxBattler) }
	end

	
	def pbMakeFakeBattler(pokemon,batonpass=false,currentmon=nil,effectnegate=true)
		if @index.nil? || !currentmon.nil?
			@index=currentmon.index
		end
		wonderroom= @field.effects[PBEffects::WonderRoom]!=0
		battler = PokeBattle_Battler.new(self,@index)
		battler.pbInitPokemon(pokemon,@index)
		battler.pbInitEffects(batonpass)#,false,effectnegate)
		if batonpass
			battler.stages[:ATTACK]          = currentmon.stages[:ATTACK]
			battler.stages[:DEFENSE]         = currentmon.stages[:DEFENSE]
			battler.stages[:SPEED]           = currentmon.stages[:SPEED]
			battler.stages[:SPECIAL_ATTACK]  = currentmon.stages[:SPECIAL_ATTACK]
			battler.stages[:SPECIAL_DEFENSE] = currentmon.stages[:SPECIAL_DEFENSE]
			battler.stages[:ACCURACY]        = currentmon.stages[:ACCURACY]
			battler.stages[:EVASION]         = currentmon.stages[:EVASION]
		end	
		return battler
	end	


	def pbCanHardSwitchLax?(idxBattler, idxParty)
		return true if idxParty < 0
		party = pbParty(idxBattler)
		return false if idxParty >= party.length
		return false if !party[idxParty]
		if party[idxParty].egg?
		  return false
		end
		if !pbIsOwner?(idxBattler, idxParty)
		  return false
		end
		if party[idxParty].fainted?
		  return false
		end
		# if pbFindBattler(idxParty, idxBattler)
		#   partyScene.pbDisplay(_INTL("{1} is already in battle!",
		# 							 party[idxParty].name)) if partyScene
		#   return false
		# end
		return true
	  end	
end  


class PokeBattle_Battler

	# Returns an array containing all unfainted opposing Pokémon.
	def allOpposing
		return @battle.allOtherSideBattlers(@index)
	end	

	# Returns an array containing all unfainted ally Pokémon.
	def allAllies
		return @battle.allSameSideBattlers(@index).reject { |b| b.index == @index }
	end	

	# Yields each unfainted opposing Pokémon.
	# Unused
	def eachOpposing
		@battle.battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(@index) }
	end

	alias stupidity_hasActiveAbility? hasActiveAbility?
	def hasActiveAbility?(check_ability, ignore_fainted = false, mold_broken=false)
		return false if mold_broken
		return stupidity_hasActiveAbility?(check_ability, ignore_fainted) 
	end
	
	def pbCanLowerAttackStatStageIntimidateAI(user)
		return false if fainted?
		# NOTE: Substitute intentionally blocks Intimidate even if self has Contrary.
		return false if @effects[PBEffects::Substitute] > 0
		#return false if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:OBLIVIOUS, :OWNTEMPO, :INNERFOCUS, :SCRAPPY])
		# NOTE: These checks exist to ensure appropriate messages are shown if
		#       Intimidate is blocked somehow (i.e. the messages should mention the
		#       Intimidate ability by name).
		return false if !hasActiveAbility?(:CONTRARY)
		return false if !pbCanLowerStatStage?(:ATTACK, user)
	  end

end	