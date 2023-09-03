class PokeBattle_AI
	
	alias stupidity_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
	
	def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
		initialscore=score
		attacker=user
		opponent=user.pbDirectOpposing(true)
		prankpri = false
		if move.baseDamage==0 && attacker.hasActiveAbility?(:PRANKSTER)
			prankpri = true
		end	
		if move.priority>0 || prankpri || (attacker.hasActiveAbility?(:GALEWINGS) && attacker.hp==attacker.totalhp && move.type==PBTypes::FLYING)
			aspeed = pbRoughStat(attacker,:SPEED,skill)
			ospeed = pbRoughStat(opponent,:SPEED,skill)
			if move.baseDamage>0  
				fastermon = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				if fastermon
					PBDebug.log(sprintf("AI Pokemon is faster.")) if $INTERNAL
				else
					PBDebug.log(sprintf("Player Pokemon is faster.")) if $INTERNAL
				end   
				pridamage=pbRoughDamage(move,attacker,opponent,skill,move.baseDamage)   
				if pridamage>=opponent.totalhp
					if fastermon
						score*=1.3
					else
						score*=2
					end
				end      
				movedamage = -1
				opppri = false     
				pridam = -1
				#if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				for j in opponent.moves
					tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
					if j.priority>0
						opppri=true
						if tempdam>pridam
							pridam = tempdam
						end              
					end    
					if tempdam>movedamage
						movedamage = tempdam
					end 
				end 
				#end
				PBDebug.log(sprintf("Expected damage taken: %d",movedamage)) if $INTERNAL
				if !fastermon
					maxdam=0
					if movedamage>attacker.hp
						score+=150
						for j in opponent.moves
							tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
							maxdam=tempdam if tempdam>maxdam
						end  
						if maxdam>=attacker.hp
							score+=30
						end
					end
				end      
				if opppri
					score*=1.1
					if pridam>attacker.hp
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
			if target.pbCanSleep?(user,false)
				score += 90
				if target.pbHasMoveFunction?("02B", "026", # Quiver Dance, Dragon Dance
						"036", "035",  # Shift Gear, Shell Smash
						"022", "034",   # Evasion Moves
						"103", "104", "105", "153", # Hazards
						"0D5", "0D6",  #  Recovery
						"0D8", "16D", "0D9")  # Synthesis, Shore up , Rest
					score += 40
				end
				if target.pbHasMoveFunction?("024", "025", "02C", # Bulk Up, Coil, Calm Mind
						"027", "028","02A", # Growth, Cosmoic Power
						"01C", "02E", "029", # Howl, Swords Dance, Hone Claws
						"032", "039") && # Nasty Plot, Tail Glow
					aspeed > ospeed
					score += 40
				end
				score-=50 if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:CHESTOBERRY)
				if skill >= PBTrainerAI.mediumSkill
					score -= 30 if target.effects[PBEffects::Yawn] > 0
				end
				if skill >= PBTrainerAI.highSkill
					score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
				end
				if skill >= PBTrainerAI.bestSkill
					if target.pbHasMoveFunction?("011","0B4")   # Snore, Sleep Talk
						score -= 50
					end
				end
			elsif skill >= PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
				score = 5 if target.effects[PBEffects::Yawn] > 0 && move.function == "004"
			end
			
			#---------------------------------------------------------------------------
		when "007", "008", "009"
			if target.pbCanParalyze?(user, false) &&
				!(skill >= PBTrainerAI.mediumSkill &&
					move.id == :THUNDERWAVE &&
					Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
				score += 30
				score-=50 if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:CHERIBERRY)
				if skill >= PBTrainerAI.mediumSkill
					aspeed = pbRoughStat(user, :SPEED, skill)
					ospeed = pbRoughStat(target, :SPEED, skill)
					if aspeed < ospeed
						score += 40
						score += 60 if move.statusMove?
					elsif aspeed > ospeed
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
		when "00A"
			if target.pbCanBurn?(user, false)
				score += 30    
				halfhealth=(user.totalhp/2)      
				maxdam=0
				maxphys=false
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
					maxphys=j.physicalMove?(j.type)
				end 
				halfdam= maxdam*0.5
				if move.statusMove? && maxphys
					score += 30 
					score += 80 if halfdam < halfhealth
				end   
				score-=50 if target.hasActiveItem?(:LUMBERRY) || target.hasActiveItem?(:RAWSTBERRY)
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					score -= 40 if aspeed<ospeed && maxdam>halfhealth
				end
				if skill >= PBTrainerAI.highSkill
					score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
				end
			elsif skill >= PBTrainerAI.mediumSkill
				score -= 90 if move.statusMove?
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
				if user.statStageAtMax?(:EVASION)
					score -= 90
				else
					target==user.pbDirectOpposing(true)
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					halfhealth=(user.totalhp/2)
					thirdhealth=(user.totalhp/3)
					if user.hp>maxdam || (target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if halfhealth>maxdam
						score += 40 if thirdhealth>maxdam
						if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
							score += 40
						end
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if aspeed<ospeed && maxdam>halfhealth
						end
					end 
					score -= user.stages[:EVASION] * 10
				end
			else
				score += 10 if user.turnCount == 0
				score += 20 if user.stages[:EVASION] < 0
			end
			#---------------------------------------------------------------------------
		when "10D"  # Curse
			if user.pbHasType?(:GHOST)
				score=5 if target.hasActiveAbility?(:MAGICGUARD)
			else    
				target=user.pbDirectOpposing(true)
				maxdam=0
				maxphys=false
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
					maxphys=j.physicalMove?(j.type)
				end 
				halfhealth=(user.totalhp/2)
				if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
					(target.status == :SLEEP && target.statusCount>1)
					score += 40
					score+=20 if maxphys
					if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
						score += 20
					end
					if skill>=PBTrainerAI.highSkill
						aspeed = pbRoughStat(user,:SPEED,skill)
						ospeed = pbRoughStat(target,:SPEED,skill)
						score -= 90 if aspeed<ospeed && maxdam>halfhealth
					end
				end 
				if user.statStageAtMax?(:ATTACK) &&
					user.statStageAtMax?(:DEFENSE)
					score -= 90
				else
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
			end    
			#---------------------------------------------------------------------------
		when "024"  # Bulk Up
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxphys=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxphys=j.physicalMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) || 
				(target.status == :SLEEP && target.statusCount>1)
				score += 40
				score+=20 if maxphys
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 20
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>halfhealth
				end
			end 
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:DEFENSE)
				score -= 90
			else
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxphys=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxphys=j.physicalMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 40
				score+=20 if maxphys
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 20
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>halfhealth
				end
			end 
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:ACCURACY)
				score -= 90
			else
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 20
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 40 if aspeed<ospeed && aspeed*1.5>ospeed
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=30 if prio && !selfprio
			end
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPEED)
				score -= 90
			else
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 20
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 40 if aspeed<ospeed && aspeed*2>ospeed
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=30 if prio && !selfprio
			end
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPEED)
				score -= 90
			else
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxspec=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxspec=j.specialMove?(j.type)
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 20
				score+= 20 if (target.status == :SLEEP && target.statusCount>1)
				score+=20 if maxspec
				if target.pbHasMoveFunction?("0D5", "0D6")   # Recovey
					score += 20
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 40 if aspeed<ospeed && aspeed*1.5>ospeed
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=30 if prio && !selfprio
			end
			if user.statStageAtMax?(:SPEED) &&
				user.statStageAtMax?(:SPECIAL_ATTACK) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)
				score -= 90
			else
				score -= user.stages[:SPECIAL_ATTACK]*10
				score -= user.stages[:SPECIAL_DEFENSE]*10
				score -= user.stages[:SPEED]*10
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxspec=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxspec=j.specialMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 40
				score+=20 if maxspec
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 20
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>halfhealth
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=30 if prio && !selfprio
			end 
			if user.statStageAtMax?(:SPECIAL_ATTACK) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)
				score -= 90
			else
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
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 30
				score += 40 if thirdhealth
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 40
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>thirdhealth
				end
			end 
			if user.statStageAtMax?(:DEFENSE) &&
				user.statStageAtMax?(:SPECIAL_DEFENSE)
				score -= 90
			else
				score -= user.stages[:DEFENSE] * 10
				score -= user.stages[:SPECIAL_DEFENSE] * 10
			end
			#---------------------------------------------------------------------------
		when "01D", "02F"  # Iron Defense
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxphys=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxspec=j.specialMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			if maxspec && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY)))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 30
				score += 40 if thirdhealth
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 40
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>thirdhealth
				end
			end 
			if move.statusMove?
				if user.statStageAtMax?(:DEFENSE)
					score -= 90
				else
					score -= user.stages[:DEFENSE] * 20
				end
			else
				score += 20 if user.stages[:DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "038"
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxphys=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxspec=j.specialMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			if maxspec && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY)))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 40
				score += 60 if thirdhealth
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 40
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>thirdhealth
				end
			end 
			if move.statusMove?
				if user.statStageAtMax?(:DEFENSE)
					score -= 90
				else
					score += 40 if user.turnCount == 0
					score -= user.stages[:DEFENSE] * 30
				end
			else
				score += 10 if user.turnCount == 0
				score += 30 if user.stages[:DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "033"  # Amnesia
			target=user.pbDirectOpposing(true)
			maxdam=0
			maxspec=false
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
				maxphys=j.physicalMove?(j.type)
			end 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			if maxphys && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY)))) ||
				(target.status == :SLEEP && target.statusCount>1)
				score += 30
				score += 40 if thirdhealth
				if target.pbHasMoveFunction?("0D5", "0D6")   #  Recovery
					score += 40
				end
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score -= 90 if aspeed<ospeed && maxdam>thirdhealth
				end
			end 
			if move.statusMove?
				if user.statStageAtMax?(:SPECIAL_DEFENSE)
					score -= 90
				else
					score -= user.stages[:SPECIAL_DEFENSE] * 20
				end
			else
				score += 20 if user.stages[:SPECIAL_DEFENSE] < 0
			end
			#---------------------------------------------------------------------------
		when "01F" # Flame Charge
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				#score += 40
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 100 if aspeed<ospeed && aspeed*1.5>ospeed
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=60 if prio && !selfprio
			end
			if move.statusMove?
				if user.statStageAtMax?(:SPEED)
					score -= 90
				else
					score -= user.stages[:SPEED] * 10
				end
			elsif user.stages[:SPEED] < 0
				score += 20
			end
			#---------------------------------------------------------------------------
		when "030", "031" # Agility, Autotomize
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
				(target.status == :SLEEP && target.statusCount>1)
				#score += 40
				if skill>=PBTrainerAI.highSkill
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 100 if aspeed<ospeed && aspeed*2>ospeed
				end
				prio=false
				@battle.allOtherSideBattlers(1).each do |b|
					for j in b.moves
						next if !j.damagingMove?
						prio= (j.priority>0) 
					end 
				end   
				selfprio=false
				user.eachMove do |m|
					next if !m.damagingMove?
					selfprio= (m.priority>0) 
				end    
				score-=60 if prio && !selfprio
			end
			if move.statusMove?
				if user.statStageAtMax?(:SPEED)
					score -= 90
				else
					score -= user.stages[:SPEED] * 10
				end
			else
				score += 20 if user.stages[:SPEED] < 0
			end
			#---------------------------------------------------------------------------
		when "027", "028"  # Growth
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:SPECIAL_ATTACK)
				score -= 90
			else
				target=user.pbDirectOpposing(true)
				maxdam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
				end 
				halfhealth=(user.totalhp/2)
				if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
					(target.status == :SLEEP && target.statusCount>1)
					score += 40
					score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
					if skill>=PBTrainerAI.highSkill
						aspeed = pbRoughStat(user,:SPEED,skill)
						ospeed = pbRoughStat(target,:SPEED,skill)
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if aspeed<ospeed && maxdam>halfhealth
					end
					prio=false
					@battle.allOtherSideBattlers(1).each do |b|
						for j in b.moves
							next if !j.damagingMove?
							prio= (j.priority>0) 
						end 
					end   
					selfprio=false
					user.eachMove do |m|
						next if !m.damagingMove?
						selfprio= (m.priority>0) 
					end    
					score-=30 if prio && !selfprio
				end 
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
				if user.statStageAtMax?(:ATTACK)
					score -= 90
				else
					target=user.pbDirectOpposing(true)
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					halfhealth=(user.totalhp/2)
					if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
						(target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if aspeed<ospeed && maxdam>halfhealth
						end
						prio=false
						@battle.allOtherSideBattlers(1).each do |b|
							for j in b.moves
								next if !j.damagingMove?
								prio= (j.priority>0) 
							end 
						end   
						selfprio=false
						user.eachMove do |m|
							next if !m.damagingMove?
							selfprio= (m.priority>0) 
						end    
						score-=30 if prio && !selfprio
					end 
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
				if user.statStageAtMax?(:ATTACK)
					score -= 90
				else
					target=user.pbDirectOpposing(true)
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					halfhealth=(user.totalhp/2)
					if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
						(target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if aspeed<ospeed && maxdam>halfhealth
						end
						prio=false
						@battle.allOtherSideBattlers(1).each do |b|
							for j in b.moves
								next if !j.damagingMove?
								prio= (j.priority>0) 
							end 
						end   
						selfprio=false
						user.eachMove do |m|
							next if !m.damagingMove?
							selfprio= (m.priority>0) 
						end    
						score-=30 if prio && !selfprio
					end 
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
			if user.statStageAtMax?(:ATTACK) &&
				user.statStageAtMax?(:ACCURACY)
				score -= 90
			else
				target=user.pbDirectOpposing(true)
				maxdam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
				end 
				halfhealth=(user.totalhp/2)
				if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
					(target.status == :SLEEP && target.statusCount>1)
					score += 40
					score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
					if skill>=PBTrainerAI.highSkill
						aspeed = pbRoughStat(user,:SPEED,skill)
						ospeed = pbRoughStat(target,:SPEED,skill)
						aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
						ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
						score -= 90 if aspeed<ospeed && maxdam>halfhealth
					end
					prio=false
					@battle.allOtherSideBattlers(1).each do |b|
						for j in b.moves
							next if !j.damagingMove?
							prio= (j.priority>0) 
						end 
					end   
					selfprio=false
					user.eachMove do |m|
						next if !m.damagingMove?
						selfprio= (m.priority>0) 
					end    
					score-=30 if prio && !selfprio
				end 
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
				if user.statStageAtMax?(:SPECIAL_ATTACK)
					score -= 90
				else
					target=user.pbDirectOpposing(true)
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					halfhealth=(user.totalhp/2)
					if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
						(target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if aspeed<ospeed && maxdam>halfhealth
						end
						prio=false
						@battle.allOtherSideBattlers(1).each do |b|
							for j in b.moves
								next if !j.damagingMove?
								prio= (j.priority>0) 
							end 
						end   
						selfprio=false
						user.eachMove do |m|
							next if !m.damagingMove?
							selfprio= (m.priority>0) 
						end    
						score-=30 if prio && !selfprio
					end 
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
				if user.statStageAtMax?(:SPECIAL_ATTACK)
					score -= 90
				else
					target=user.pbDirectOpposing(true)
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					halfhealth=(user.totalhp/2)
					if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
						(target.status == :SLEEP && target.statusCount>1)
						score += 40
						score += 20 if user.hasActiveAbility?(:SPEEDBOOST)
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							ospeed = pbRoughStat(target,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score -= 90 if aspeed<ospeed && maxdam>halfhealth
						end
						prio=false
						@battle.allOtherSideBattlers(1).each do |b|
							for j in b.moves
								next if !j.damagingMove?
								prio= (j.priority>0) 
							end 
						end   
						selfprio=false
						user.eachMove do |m|
							next if !m.damagingMove?
							selfprio= (m.priority>0) 
						end    
						score-=30 if prio && !selfprio
					end 
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
					maxdam=0
					for j in target.moves
						tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
						tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
						maxdam=tempdam if tempdam>maxdam
					end 
					if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) ||
						(target.status == :SLEEP && target.statusCount>1)
						score += 40
						if skill>=PBTrainerAI.highSkill
							aspeed = pbRoughStat(user,:SPEED,skill)
							aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
							ospeed = pbRoughStat(target,:SPEED,skill)
							ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
							score += 40 if aspeed<ospeed && aspeed*2>ospeed
						end
						prio=false
						@battle.allOtherSideBattlers(1).each do |b|
							for j in b.moves
								next if !j.damagingMove?
								prio= (j.priority>0) 
							end 
						end   
						selfprio=false
						user.eachMove do |m|
							next if !m.damagingMove?
							selfprio= (m.priority>0) 
						end    
						score-=60 if prio && !selfprio
					end
				end	
			end    
			#---------------------------------------------------------------------------
		when "071"  # Counter
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				maxdam=0
				maxphys=false
				maxspec=false
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
					maxphys=j.physicalMove?(j.type)
					maxspec=j.specialMove?(j.type)
				end 
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
				if maxphys && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))))
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					score += 30 if aspeed<ospeed
				end   
				score=0 if pbAIRandom(100) < 50
			end
			#---------------------------------------------------------------------------
		when "072"  # Mirror Coat
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				maxdam=0
				maxphys=false
				maxspec=false
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
					maxphys=j.physicalMove?(j.type)
					maxspec=j.specialMove?(j.type)
				end 
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
				if maxspec && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))))
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					score += 30 if aspeed<ospeed
				end   
				score=0 if pbAIRandom(100) < 50
			end   
			#---------------------------------------------------------------------------
		when "073"  # Metal Burst
			if target.effects[PBEffects::HyperBeam] > 0
				score -= 90
			else
				maxdam=0
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					maxdam=tempdam if tempdam>maxdam
				end 
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
				if maxspec && (user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))))
					damagePercentage = counterdam * 100.0 / target.hp
					damagePercentage=110 if damagePercentage>target.hp
					score+=damagePercentage
				end
				if maxowndam>=counterdam
					score-=90
				else
					if aspeed<ospeed
						score += 30 
					else  
						score-=90
					end        
				end  
				score=5 if aspeed<ospeed
				score=0 if pbAIRandom(100) < 50
			end    
			#---------------------------------------------------------------------------
		when "0B4"   # Sleep Talk
			if (user.asleep? && user.statusCount>1) || (user.hasActiveAbility?(:COMATOSE) && user.pbHasMoveFunction?("125"))
				score += 150   # Because it can only be used while asleep
			else
				score -= 90
			end 
			#---------------------------------------------------------------------------
		when "125" # Last Resort
			hasThisMove = false
			hasOtherMoves = false
			hasUnusedMoves = false
			user.eachMove do |m|
				hasThisMove    = true if m.id == @id
				hasOtherMoves  = true if m.id != @id
				hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
			end
			if !hasThisMove || !hasOtherMoves || hasUnusedMoves
				score=0
			end
			#---------------------------------------------------------------------------
		when "103" # Spikes
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			denier=false
			@battle.allOtherSideBattlers(1).each do |b|
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
				party = @battle.pbParty(0)
				inBattleIndices = @battle.allSameSideBattlers(0).map { |b| b.pokemonIndex }
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
			denier=false
			@battle.allOtherSideBattlers(1).each do |b|
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
				party = @battle.pbParty(0)
				inBattleIndices = @battle.allSameSideBattlers(0).map { |b| b.pokemonIndex }
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
			denier=false
			@battle.allOtherSideBattlers(1).each do |b|
				if b.effects[PBEffects::MagicCoat] || b.hasActiveAbility?(:MAGICBOUNCE) ||
					(b.pbHasMoveFunction?("110") && !user.pbHasType?(:GHOST)) ||
					b.pbHasMoveFunction?("049") 
					denier=true
				end
			end    
			if user.pbOpposingSide.effects[PBEffects::StealthRock] || denier
				score -= 90
			elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
				score -= 90   # Opponent can't switch in any Pokemon
			else
				party = @battle.pbParty(0)
				inBattleIndices = @battle.allSameSideBattlers(0).map { |b| b.pokemonIndex }
				count = 0
				party.each_with_index do |pkmn, idxParty|
					next if !pkmn || !pkmn.able?
					next if inBattleIndices.include?(idxParty)
					next if pkmn.item == :HEAVYDUTYBOOTS
					count += 1
					count += 1 if pkmn.item == :FOCUSSASH || pkmn.ability == :STURDY || pkmn.ability == :WONDERGUARD ||
					(pkmn.hasType?(:FIRE) && (pkmn.hasType?(:ICE) || pkmn.hasType?(:BUG) || pkmn.hasType?(:FLYING))) || 
					(pkmn.hasType?(:ICE) &&  (pkmn.hasType?(:BUG) || pkmn.hasType?(:FLYING))) || 
					(pkmn.hasType?(:BUG) && pkmn.hasType?(:FLYING)) 
				end
				score += 15 * count
			end
			#---------------------------------------------------------------------------
		when "153" # Sticky Web
			denier=false
			@battle.allOtherSideBattlers(1).each do |b|
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
				ownparty = @battle.pbParty(1)
				ownparty.each_with_index do |pkmn, idxParty|
					maxownspeed = pkmn.speed if pkmn.speed>maxownspeed
				end
				party = @battle.pbParty(0)
				inBattleIndices = @battle.allSameSideBattlers(0).map { |b| b.pokemonIndex }
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
			maxdam=0
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					maxdam=tempdam if tempdam>maxdam
					maxphys=j.physicalMove?(j.type)
				end 
			end    
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxphys
				score+=40 if halfhealth>maxdam
				score+=60
				if aspeed<ospeed
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && aspeed<ospeed)
			score = 5 if user.pbOwnSide.effects[PBEffects::Reflect] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			
			#---------------------------------------------------------------------------
		when "0A3" # Light Screen
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxspec=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxspec
				score+=40 if halfhealth>maxdam
				score+=60
				if aspeed<ospeed
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && aspeed<ospeed)
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			#---------------------------------------------------------------------------
		when "167" # Aurora Veil
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					maxdam=tempdam if tempdam>maxdam
				end 
			end    
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			score+=40 if halfhealth>maxdam
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			else
				halfdam=maxdam/2
				score+=80 if halfdam<user.hp
			end    
			score-=90 if target.pbHasMoveFunction?("0B2", "10A", "049") || 
			(target.pbHasMoveFunction?("0BA") && aspeed<ospeed)
			score =5 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || @battle.pbWeather != :Hail || 
			user.pbOwnSide.effects[PBEffects::Reflect] > 1 || user.pbOwnSide.effects[PBEffects::LightScreen] > 1
			#---------------------------------------------------------------------------
		when "0FF" # Sunny Day
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			water=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=40 if water && aspeed>ospeed
			if aspeed<ospeed
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
				score+=40 if aspeed<ospeed && aspeed*2>ospeed
			end    
			score+=20 if user.hasActiveAbility?(:FLOWERGIFT) || user.hasActiveAbility?(:SOLARPOWER) || user.hasActiveAbility?(:PROTOSYNTHESIS)
			score-=50 if user.hasActiveAbility?(:DRYSKIN)
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
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
			party = @battle.pbParty(0)
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
				score = 5
			elsif @battle.pbWeather == :Sun
				score = 5
			end
			#---------------------------------------------------------------------------
		when "100"  # Rain Dance
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			fire=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=40 if fire && aspeed>ospeed
			if aspeed<ospeed
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
				score+=40 if aspeed<ospeed && aspeed*2>ospeed
			end    
			score+=20 if user.hasActiveAbility?(:RAINDISH) || user.hasActiveAbility?(:DRYSKIN) || user.hasActiveAbility?(:HYDRATION)
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
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
			party = @battle.pbParty(0)
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
				score = 5
			elsif @battle.pbWeather == :Rain
				score = 5
			end
			#---------------------------------------------------------------------------
		when "101"  # Sandstorm
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxspec=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=20 if maxspec && aspeed>ospeed && user.pbHasType?(:ROCK)
			score+=20 if user.pbHasType?(:ROCK)
			if !user.hasActiveItem?(:SAFETYGOGGLES) && !user.hasActiveItem?(:UTILITYUMBRELLA) && 
				!user.pbHasType?(:ROCK) && !user.pbHasType?(:STEEL) && !user.pbHasType?(:GROUND) &&
				!user.hasActiveAbility?(:MAGICGUARD) && !user.hasActiveAbility?(:OVERCOAT) && 
				!user.hasActiveAbility?(:SANDVEIL) && !user.hasActiveAbility?(:SANDRUSH) && !user.hasActiveAbility?(:SANDFORCE)
				score-=10
				score-=40 if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
			end    
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			score-=20 if user.pbHasMoveFunction?("0D8", "028", "0C4")
			score+=20 if user.pbHasMoveFunction?("16D")
			if user.hasActiveAbility?(:SANDRUSH)
				score+=20
				score+=40 if aspeed<ospeed && aspeed*2>ospeed
			end    
			score+=20 if user.hasActiveAbility?(:SANDVEIL) || user.hasActiveAbility?(:SANDFORCE)
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SANDRUSH
				score+=20 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
				score+=20 if pkmn.hasType?(:ROCK)
				score-=10 if pkmn.pbHasMoveFunction?("0D8", "028", "0C4") && @battle.pbWeather == :Sun
				score+=20 if pkmn.pbHasMoveFunction?("16D") 
			end
			party = @battle.pbParty(0)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if (pkmn.ability == :CHLOROPHYLL && @battle.pbWeather == :Sun) || (pkmn.ability == :SWIFTSWIM && @battle.pbWeather == :Rain)
					score+=40
				end 
				if (pkmn.ability == :SLUSHRUSH && @battle.pbWeather == :Hail)
					score+=20
				end 
			end
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score = 5
			elsif @battle.pbWeather == :Sandstorm
				score = 5
			end
			#------------------------------------------------------------------
		when "102"  # Hail
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxphys=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			score-=20 if user.pbHasMoveFunction?("0D8", "028", "0C4")
			score+=20 if user.pbHasMoveFunction?("00D")
			score+=40 if user.pbHasMoveFunction?("167")
			if user.hasActiveAbility?(:SLUSHRUSH)
				score+=20
				score+=40 if aspeed<ospeed && aspeed*2>ospeed
			end    
			score+=20 if user.hasActiveAbility?(:SNOWCLOAK) || user.hasActiveAbility?(:ICEBODY)
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
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
			party = @battle.pbParty(0)
			party.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				if (pkmn.ability == :CHLOROPHYLL && @battle.pbWeather == :Sun) || (pkmn.ability == :SWIFTSWIM && @battle.pbWeather == :Rain)
					score+=40
				end 
				if (pkmn.ability == :SANDRUSH && @battle.pbWeather == :Sandstorm)
					score+=20
				end 
			end
			if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
				@battle.pbCheckGlobalAbility(:CLOUDNINE)
				score = 5
			elsif @battle.pbWeather == :Hail
				score = 5
			end   
			#---------------------------------------------------------------------------
		when "154"  # Electric Terrain
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			maxdam=0
			maxphys=false
			maxspec=false
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=20 if aspeed>ospeed && user.hasActiveItem?(:ELECTRICSEED) & maxphys
			score+=20 if aspeed>ospeed && target.pbHasMoveFunction?("003","004")
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :ELECTRIC
				score += 10
			end  
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
			# score+=30 if user.pbHasMoveFunction?("DoublePowerInElectricTerrain")
			if user.hasActiveAbility?(:SURGESURFER)
				score+=20
				score+=40 if aspeed<ospeed && aspeed*2>ospeed
			end    
			score+=20 if user.hasActiveAbility?(:QUARKDRIVE)
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=40 if pkmn.ability == :SURGESURFER
				score+=20 if pkmn.ability == :QUARKDRIVE
				score+=20 if pkmn.item == :ELECTRICSEED
				# score+=20 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
				# score+=30 if pkmn.pbHasMoveFunction?("DoublePowerInElectricTerrain") 
			end
			party = @battle.pbParty(0)
			if @battle.field.terrain == :Electric
				score = 5
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
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=20 if aspeed>ospeed && user.hasActiveItem?(:GRASSYSEED) & maxphys
			score+=20 if aspeed>ospeed && (maxmove == "076" || maxmove == "095" || maxmove == "044") # Earthquake, Magnitude, Bulldoze
			user.eachMove do |m|
				next if !m.damagingMove? || m.type != :GRASS
				score += 10
			end  
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			score+=20 if user.pbHasMoveFunction?("16E") # Floral Healing
			#score+=30 if user.pbHasMoveFunction?("HigherPriorityInGrassyTerrain")
			if user.hasActiveAbility?(:GRASSPELT)
				score+=20
				score+=20 if maxphys && aspeed<ospeed && aspeed*2>ospeed
			end    
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
			ownparty.each_with_index do |pkmn, idxParty|
				next if !pkmn || !pkmn.able?
				next if inBattleIndices.include?(idxParty)
				score+=20 if pkmn.ability == :GRASSPELT
				score+=20 if pkmn.item == :GRASSYSEED
				score-=20 if pkmn.pbHasMoveFunction?("076", "095","044") # Earthquake, Magnitude, Bulldoze
				score+=20 if pkmn.pbHasMoveFunction?("16E")
				#score+=40 if pkmn.pbHasMoveFunction?("HigherPriorityInGrassyTerrain") 
			end
			party = @battle.pbParty(0)
			if @battle.field.terrain == :Grassy
				score = 5
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
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
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
			score+=40 if dragon && aspeed>ospeed
			score+=20 if aspeed>ospeed && user.hasActiveItem?(:MISTYSEED) & maxspec
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			target.eachMove do |m|
				next if m.baseDamage>20
				score += 20 if aspeed>ospeed && (m.function=="007")
				score+=20 if aspeed>ospeed && target.pbHasMoveFunction?("003", "004")
			end                                                        
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
			# score+=30 if user.pbHasMoveFunction?("UserFaintsPowersUpInMistyTerrainExplosive")
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
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
			party = @battle.pbParty(0)
			if @battle.field.terrain == :Misty
				score = 5
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
			@battle.allOtherSideBattlers(1).each do |b|
				for j in b.moves
					tempdam = pbRoughDamage(j,b,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,b,user,100)
					if tempdam>maxdam
						maxdam=tempdam 
						prio= (j.priority>0)
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
			score+=20 if aspeed>ospeed && user.hasActiveItem?(:PSYCHICSEED) & maxspec
			score+=30 if user.hasActiveItem?(:TERRAINEXTENDER)
			score+=20 if halfhealth>maxdam
			score+=20 if target.pbHasMoveFunction?("116")                                       
			if aspeed<ospeed
				score -= 50 if maxdam>thirdhealth
			end
			# score+=20 if user.pbHasMoveFunction?("TypeAndPowerDependOnTerrain")
			# score+=30 if user.pbHasMoveFunction?("HitsAllFoesAndPowersUpInPsychicTerrain")
			ownparty = @battle.pbParty(1)
			inBattleIndices = @battle.allSameSideBattlers(1).map { |b| b.pokemonIndex }
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
			party = @battle.pbParty(0)
			if @battle.field.terrain == :Psychic
				score = 5
			end 
			#---------------------------------------------------------------------------
		when "0EE"  # U-Turn , Volt Switch , Flip Turn
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			score -= 30 if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
			user.pbOwnSide.effects[PBEffects::Spikes]>0 || user.pbOwnSide.effects[PBEffects::StickyWeb]
			if aspeed>ospeed && !(target.status == :SLEEP && target.statusCount>1)
				score -= 30 # DemICE: Switching AI is dumb so if you're faster, don't sack a healthy mon. Better use another move.
			else
				score +=30 if user.hasActiveAbility?(:REGENERATOR)
				score +=30 if user.effects[PBEffects::Toxic]>3
				score +=30 if user.effects[PBEffects::Curse]
				score +=30 if user.effects[PBEffects::PerishSong]==1
				score +=30 if user.effects[PBEffects::LeechSeed]>0
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
			# score +=30 if user.effects[PBEffects::LeechSeed]>0
			# score +=30 if target.status == :SLEEP && target.statusCount>1
			#---------------------------------------------------------------------------
		when "05B" # Tailwind
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) || 
				(target.status == :SLEEP && target.statusCount>1)
				#score += 40
				pspeed=0
				espeed=0
				if skill>=PBTrainerAI.highSkill
					minspeed=0
					user.allAllies.each do |b|
						pspeed = pbRoughStat(b,:SPEED,skill)
						pspeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						minspeed=pspeed if pspeed<minspeed
					end
					maxspeed=0
					target.allAllies.each do |b|
						espeed = pbRoughStat(b,:SPEED,skill)
						espeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						maxspeed=espeed if espeed>maxspeed
					end
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 100 if (aspeed<ospeed && aspeed*2>ospeed) || (aspeed<espeed && aspeed*2>espeed) ||
					(pspeed<espeed && pspeed*2>espeed) || (pspeed<ospeed && pspeed*2>ospeed)
				end
			end
			score = 5 if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
			#---------------------------------------------------------------------------
		when "11F" # Trick Room
			target=user.pbDirectOpposing(true)
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			if user.hp>maxdam || (user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH)	|| user.hasActiveAbility?(:STURDY))) || 
				(target.status == :SLEEP && target.statusCount>1)
				#score += 40
				pspeed=0
				espeed=0
				if skill>=PBTrainerAI.highSkill
					minspeed=0
					user.allAllies.each do |b|
						pspeed = pbRoughStat(b,:SPEED,skill)
						pspeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						minspeed=pspeed if pspeed<minspeed
					end
					maxspeed=0
					target.allAllies.each do |b|
						espeed = pbRoughStat(b,:SPEED,skill)
						espeed*=1.5 if b.hasActiveAbility?(:SPEEDBOOST)
						maxspeed=espeed if espeed>maxspeed
					end
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					aspeed*=1.5 if user.hasActiveAbility?(:SPEEDBOOST)
					ospeed*=1.5 if target.hasActiveAbility?(:SPEEDBOOST)
					score += 100 if aspeed<ospeed || aspeed<espeed ||
					pspeed<espeed|| pspeed<ospeed
				end
			end
			#---------------------------------------------------------------------------
		when "0D5", "0D6", "0D8", "16D" # Recover, Roost, Synthesis, Shore Up
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			fastermon=((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) || (user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE))      
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
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 	
			maxdam=0 if (target.status == :SLEEP && target.statusCount>1)		
			if maxdam>user.hp
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
			hplost+=maxdam if !fastermon
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
			score=0 if user.effects[PBEffects::Wish]>0	
			
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
			maxdam=0
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
				maxdam=tempdam if tempdam>maxdam
			end 
			maxdam=0 if (target.status == :SLEEP && target.statusCount>1)				
			if maxdam>user.hp
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
			hplost+=maxdam if !fastermon
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
			score=0 if user.effects[PBEffects::Wish]>0	
			
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
				statuschip += 0.125 if ((user.status==:POISON &&  (user.hasWorkingAbility(:POISONHEAL) || !(user.hasWorkingAbility(:POISONHEAL))) && (user.effects[PBEffects::Toxic]==0))) || (user.status == :SLEEP && target.hasWorkingAbility(:BADDREAMS)) 
				statuschip += (0.0625*user.effects[PBEffects::Toxic]) if user.effects[PBEffects::Toxic]!=0 && !(user.hasWorkingAbility(:POISONHEAL)) 
				chip+=statuschip
			end
		end
		return chip if chips
		diff=(healing-chip)
		return diff if both
	end
	
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
	
end	