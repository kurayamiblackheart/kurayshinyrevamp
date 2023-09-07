$aiberrycheck=false
class PokeBattle_AI
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
      #Console.echo_h2(choices)
	    print choices if  $DEBUG && Input.press?(Input::CTRL)
      # Figure out useful information about the choices
      totalScore = 0
      maxScore   = 0
      choices.each do |c|
        totalScore += c[1]
        maxScore = c[1] if maxScore < c[1]
      end
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
        score *= accuracy / 100.0
        score = 0 if score <= 10 && skill >= PBTrainerAI.highSkill
      end
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
        if miss && pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
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
	    realDamage*=0.9 #DemICE encourage AI to use stronger moves to avoid opponent surviving from low damage roll.
      # Account for accuracy of move
      accuracy = pbRoughAccuracy(move, user, target, skill)
      accuracy*= 1.3 if $game_switches[850] # Endgame Challenge enabled
      #realDamage *= accuracy / 100.0 # DemICE
      # Two-turn attacks waste 2 turns to deal one lot of damage
      # if move.chargingTurnMove? || move.function == "0C2"   # Hyper Beam # DemICE this shit does more bad than good.
        # realDamage *= 2 / 3   # Not halved because semi-invulnerable during use or hits first turn
      # end
      # Prefer flinching external effects (note that move effects which cause
      # flinching are dealt with in the function code part of score calculation)
    if skill>=PBTrainerAI.mediumSkill
      if !target.hasActiveAbility?(:INNERFOCUS) &&
          !target.hasActiveAbility?(:SHIELDDUST) &&
          target.effects[PBEffects::Substitute]==0
        canFlinch = false
        if move.canKingsRock? && user.hasActiveItem?([:KINGSROCK,:RAZORFANG])
          canFlinch = true
        end
        if user.hasActiveAbility?(:STENCH) && !move.flinchingMove?
          canFlinch = true
        end
        realDamage *= 1.1 if canFlinch
      end
      # Convert damage to percentage of target's remaining HP
      damagePercentage = realDamage * 100.0 / target.hp
      # Don't prefer weak attacks
     #    damagePercentage /= 2 if damagePercentage<20
      # Prefer damaging attack if level difference is significantly high
      #damagePercentage *= 1.2 if user.level - 10 > target.level
      # Adjust score
      if damagePercentage > 100   # Treat all lethal moves the same   # DemICE
        damagePercentage = 120 
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
    # Get the move's type
    type = pbRoughType(move,user,skill)
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
      if target.item #&& !target.item.is_berry?
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
      if c>=0
        c = 4 if c>4
        damage += damage*0.1*c
      end
    end
    return damage.floor
  end 


  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(score,move,user,target,skill)
    type = pbRoughType(move,user,skill)
    typeMod = pbCalcTypeMod(type,user,target)
    # Type effectiveness
    if Effectiveness.ineffective?(typeMod) || score<=0
		if move.baseDamage>0 || move.name=="Thunder Wave"
			return true
		end
	end	
    # Immunity due to ability/item/other effects
    if skill>=PBTrainerAI.mediumSkill
      case type
      when :GROUND
        return true if target.airborne? && !move.hitsFlyingTargets?
      when :FIRE
        return true if target.hasActiveAbility?(:FLASHFIRE)
      when :WATER
        return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
      when :GRASS
        return true if target.hasActiveAbility?(:SAPSIPPER)
      when :ELECTRIC
        return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
      end
      return true if Effectiveness.not_very_effective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && user.index!=target.index && !target.opposes?(user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if target.hasActiveAbility?(:OVERCOAT)
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

end

def pbBattleTypeWeakingBerry(type,moveType,target,mults)
  return if moveType != type
  return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
  mults[:final_damage_multiplier] /= 2
  target.damageState.berryWeakened = true
  target.battle.pbCommonAnimation("EatBerry",target) if !$aiberrycheck
end  