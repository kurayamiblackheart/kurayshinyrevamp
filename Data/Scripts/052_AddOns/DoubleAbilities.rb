class PokeBattle_Battler
  attr_accessor :ability_id
  attr_accessor :ability2_id

  #Primary ability utility methods for battlers class
  def ability
    return GameData::Ability.try_get(@ability_id)
  end

  def ability=(value)
    new_ability = GameData::Ability.try_get(value)
    @ability_id = (new_ability) ? new_ability.id : nil
  end

  def abilityName
    abil = self.ability
    return (abil) ? abil.name : ""
  end

  #Secondary ability utility methods for battlers class
  def ability2
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return GameData::Ability.try_get(@ability2_id)
  end

  def ability2=(value)
    return if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    new_ability = GameData::Ability.try_get(value)
    @ability2_id = (new_ability) ? new_ability.id : nil
  end

  def ability2Name
    abil = self.ability2
    return (abil) ? abil.name : ""
  end

  #Ability logic overrides

  def hasActiveAbility?(check_ability, ignore_fainted = false)
    return hasActiveAbilityDouble?(check_ability, ignore_fainted) if $game_switches[SWITCH_DOUBLE_ABILITIES]
    return false if !abilityActive?(ignore_fainted)
    return check_ability.include?(@ability_id) if check_ability.is_a?(Array)
    return self.ability == check_ability
  end

  def hasActiveAbilityDouble?(check_ability, ignore_fainted = false)
    return false if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return false if !abilityActive?(ignore_fainted)
    if check_ability.is_a?(Array)
      return check_ability.include?(@ability_id) || check_ability.include?(@ability2_id)
    end
    return self.ability == check_ability || self.ability2 == check_ability
  end

  def triggerAbilityEffectsOnHit(move, user, target)
    # Target's ability
    if target.abilityActive?(true)
      oldHP = user.hp
      BattleHandlers.triggerTargetAbilityOnHit(target.ability, user, target, move, @battle)
      BattleHandlers.triggerTargetAbilityOnHit(target.ability2, user, target, move, @battle) if $game_switches[SWITCH_DOUBLE_ABILITIES] && target.ability2
      user.pbItemHPHealCheck if user.hp < oldHP
    end
    # User's ability
    if user.abilityActive?(true)
      BattleHandlers.triggerUserAbilityOnHit(user.ability, user, target, move, @battle)
      BattleHandlers.triggerUserAbilityOnHit(user.ability2, user, target, move, @battle) if $game_switches[SWITCH_DOUBLE_ABILITIES] && user.ability2
      user.pbItemHPHealCheck
    end
  end

  def pbCheckDamageAbsorption(user, target)
    # Substitute will take the damage
    if target.effects[PBEffects::Substitute] > 0 && !ignoresSubstitute?(user) &&
      (!user || user.index != target.index)
      target.damageState.substitute = true
      return
    end
    # Disguise will take the damage
    if !@battle.moldBreaker && target.isFusionOf(:MIMIKYU) &&
      target.form == 0 && (target.ability == :DISGUISE || target.ability2 == :DISGUISE)
      target.damageState.disguise = true
      return
    end
  end

  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn = false)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Trace
    if $game_switches[SWITCH_DOUBLE_ABILITIES] && onSwitchIn
      displayOpponentDoubleAbilities()
    else
      if hasActiveAbility?(:TRACE)
        # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
        #       in and not at any later times, even if a traceable ability turns
        #       up later. Essentials ignores this, and allows Trace to trigger
        #       whenever it can even in the old battle mechanics.
        choices = []
        @battle.eachOtherSideBattler(@index) do |b|
          next if b.ungainableAbility? ||
            [:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(b.ability_id)
          choices.push(b)
        end
        if choices.length > 0
          choice = choices[@battle.pbRandom(choices.length)]
          @battle.pbShowAbilitySplash(self)
          self.ability = choice.ability
          @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), choice.abilityName))
          @battle.pbHideAbilitySplash(self)
          if !onSwitchIn && (unstoppableAbility? || abilityActive?)
            BattleHandlers.triggerAbilityOnSwitchIn(self.ability, self, @battle)
          end
        end
      end
    end
  end

  def displayOpponentDoubleAbilities()
    @battle.eachOtherSideBattler(@index) do |battler|
      @battle.pbShowPrimaryAbilitySplash(battler,true)
      @battle.pbShowSecondaryAbilitySplash(battler,true) if battler.isFusion?()
       @battle.pbHideAbilitySplash(battler)
    end
  end

end




class Pokemon
  attr_writer :ability_index
  attr_writer :ability2_index

  #Primary ability utility methods for pokemon class
  def ability_index
    @ability_index = (@personalID & 1) if !@ability_index
    return @ability_index
  end

  def ability
    return GameData::Ability.try_get(ability_id())
  end

  def ability=(value)
    return if value && !GameData::Ability.exists?(value)
    @ability = (value) ? GameData::Ability.get(value).id : value
  end

  #Secondary ability utility methods for pokemon class
  def ability2_index
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    @ability2_index = (@personalID & 1) if !@ability2_index
    return @ability2_index
  end

  def ability2
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return GameData::Ability.try_get(ability2_id())
  end

  def ability2=(value)
    return if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return if value && !GameData::Ability.exists?(value)
    @ability2 = (value) ? GameData::Ability.get(value).id : value
  end


  def ability_id
    if !@ability
      sp_data = species_data
      abil_index = ability_index
      #echoln abil_index
      if abil_index >= 2 # Hidden ability
        @ability = sp_data.hidden_abilities[abil_index - 2]
        abil_index = (@personalID & 1) if !@ability
      end
      if !@ability # Natural ability or no hidden ability defined
        if $game_switches[SWITCH_NO_LEVELS_MODE]
          @ability = sp_data.abilities[0] || sp_data.abilities[0]
          @ability2 = sp_data.abilities[1] || sp_data.abilities[0]
        else
          @ability = sp_data.abilities[abil_index] || sp_data.abilities[0]
        end
      end
    end
    return @ability
  end

  def ability2_id
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    if !@ability2
      sp_data = species_data
      abil_index = ability_index
      if abil_index >= 2 # Hidden ability
        @ability2 = sp_data.hidden_abilities[abil_index - 2]
        abil_index = (@personalID & 1) if !@ability2
      end
      if !@ability2 # Natural ability or no hidden ability defined
        @ability2 = sp_data.abilities[abil_index] || sp_data.abilities[0]
      end
    end
    return @ability2
  end

  def adjustHPForWonderGuard(stats)
    return self.ability == :WONDERGUARD ? 1 : stats[:HP] || ($game_switches[SWITCH_DOUBLE_ABILITIES] && self.ability2 == :WONDERGUARD)
  end

end



class PokemonFusionScene

  def pbChooseAbility(ability1Id,ability2Id)
    ability1 = GameData::Ability.get(ability1Id)
    ability2 = GameData::Ability.get(ability2Id)
    availableNatures = []
    availableNatures << @pokemon1.nature
    availableNatures << @pokemon2.nature

    setAbilityAndNatureAndNickname([ability1,ability2], availableNatures)
  end


  def setAbilityAndNatureAndNickname(abilitiesList, naturesList)
    clearUIForMoves
    if $game_switches[SWITCH_DOUBLE_ABILITIES]
      scene = FusionSelectOptionsScene.new(nil, naturesList, @pokemon1, @pokemon2)
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen

      @pokemon1.ability = abilitiesList[0]
      @pokemon1.ability2 = abilitiesList[1]
    else
      scene = FusionSelectOptionsScene.new(abilitiesList, naturesList, @pokemon1, @pokemon2)
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen

      selectedAbility = scene.selectedAbility
      @pokemon1.body_original_ability_index = @pokemon1.ability_index
      @pokemon1.head_original_ability_index = @pokemon2.ability_index

      @pokemon1.ability = selectedAbility
      @pokemon1.ability_index = getAbilityIndexFromID(selectedAbility.id,@pokemon1)
    end

    @pokemon1.nature = scene.selectedNature
    if scene.hasNickname
      @pokemon1.name = scene.nickname
    end
  end

end


