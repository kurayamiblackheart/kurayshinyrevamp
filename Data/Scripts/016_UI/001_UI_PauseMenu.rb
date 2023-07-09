#===============================================================================
#
#===============================================================================
class PokemonPauseMenu_Scene
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["helpwindow"].visible = false
    @infostate = false
    @helpstate = false
    pbSEPlay("GUI menu open")
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text, Graphics.height)
    @sprites["infowindow"].text = text
    @sprites["infowindow"].visible = true
    @infostate = true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text, Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    pbBottomLeft(@sprites["helpwindow"])
    @helpstate = true
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = commands
    cmdwindow.index = [$PokemonTemp.menuLastChoice, commands.length - 1].min
    cmdwindow.resizeToFit(commands)
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    cmdwindow.visible = true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh; end
end

#===============================================================================
#
#===============================================================================
class PokemonPauseMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    if !$Trainer
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene = true
    commands = []
    cmdPokedex = -1
    cmdPokemon = -1
    cmdBag = -1
    #KurayX Creating kuray shop
    cmdKurayShop = -1
    cmdTrainer = -1
    cmdSave = -1
    cmdOption = -1
    cmdPokegear = -1
    cmdDebug = -1
    cmdQuit = -1
    cmdEndGame = -1
    cmdPC = -1
    cmdKurayHeal = -1
    if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
      commands[cmdPokedex = commands.length] = _INTL("Pokédex")
    end
    commands[cmdPokemon = commands.length] = _INTL("Pokémon") if $Trainer.party_count > 0
    commands[cmdBag = commands.length] = _INTL("Bag") if !pbInBugContest?
    #KurayX Creating kuray shop
    commands[cmdPC = commands.length] = _INTL("PC") if $PokemonSystem.kurayqol == 1
    commands[cmdKurayHeal = commands.length] = _INTL("Heal Pokémon") if $PokemonSystem.kurayqol == 1
    commands[cmdKurayShop = commands.length] = _INTL("Kuray Shop") if !pbInBugContest? && $PokemonSystem.kurayqol == 1
    commands[cmdPokegear = commands.length] = _INTL("Pokégear") if $Trainer.has_pokegear
    commands[cmdTrainer = commands.length] = $Trainer.name
    if pbInSafari?
      if Settings::SAFARI_STEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}", pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
                                pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length] = _INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
                                pbBugContestState.lastPokemon.speciesName,
                                pbBugContestState.lastPokemon.level,
                                pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}", pbBugContestState.ballcount))
      end
      commands[cmdQuit = commands.length] = _INTL("Quit Contest")
    else
      commands[cmdSave = commands.length] = _INTL("Save") if $game_system && !$game_system.save_disabled
    end
    commands[cmdOption = commands.length] = _INTL("Options")
    commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG
    commands[cmdEndGame = commands.length] = _INTL("Title screen")
    loop do
      command = @scene.pbShowCommands(commands)
      if cmdPokedex >= 0 && command == cmdPokedex
        pbPlayDecisionSE
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
        else
          #if $Trainer.pokedex.accessible_dexes.length == 1
          $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
          # else
          #   pbFadeOutIn {
          #     scene = PokemonPokedexMenu_Scene.new
          #     screen = PokemonPokedexMenuScreen.new(scene)
          #     screen.pbStartScreen
          #     @scene.pbRefresh
          #   }
          # end
        end
      # cmdPC = KurayPC #KurayX PC
      elsif cmdPC >= 0 && command == cmdPC
        # Prevent use in Elite 4 / Champion / Hall of Fame
        # invalidMaps = [315, 316, 317, 318, 328, 341]
        invalidMaps = [
          315,316,317,318,328,343,#Elite Four
          776,777,778,779,780,781,782,783,784, #Mt. Silver
          722,723,724,720 #Dream sequence
        ]
        if invalidMaps.include?($game_map.map_id)
          @scene.pbHideMenu
          pbMessage(_INTL("Can't use that here."))
          break
        end
        pbPlayDecisionSE
        $game_temp.fromkurayshop = 1
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
          $once = 0
        }
        $game_temp.fromkurayshop = nil
      elsif cmdPokemon >= 0 && command == cmdPokemon
        pbPlayDecisionSE
        hiddenmove = nil
        pbFadeOutIn {
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene, $Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if hiddenmove
          $game_temp.in_menu = false
          pbUseHiddenMove(hiddenmove[0], hiddenmove[1])
          return
        end
      elsif cmdBag >= 0 && command == cmdBag
        pbPlayDecisionSE
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $PokemonBag)
          item = screen.pbStartScreen
          (item) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if item
          $game_temp.in_menu = false
          pbUseKeyItemInField(item)
          return
        end
      elsif cmdKurayHeal >= 0 && command == cmdKurayHeal
        invalidMaps = [
          315,316,317,318,328,343,#Elite Four
          776,777,778,779,780,781,782,783,784, #Mt. Silver
          722,723,724,720 #Dream sequence
        ]
        if invalidMaps.include?($game_map.map_id)
          @scene.pbHideMenu
          pbMessage(_INTL("Can't use that here."))
          break
        end
        $Trainer.heal_party
        pbMessage(_INTL("Pokemons healed!"))
      elsif cmdKurayShop >= 0 && command == cmdKurayShop
        # Prevent use in Elite 4 / Champion / Hall of Fame
        invalidMaps = [315, 316, 317, 318, 328, 341]
        if invalidMaps.include?($game_map.map_id)
          @scene.pbHideMenu
          pbMessage(_INTL("Can't use that here."))
          break
        end
        #KurayX Creating kuray shop
        pbPlayDecisionSE
        oldmart = $game_temp.mart_prices.clone
        $game_temp.fromkurayshop = 1


        # 314 = TM Return
        # 329 = TM Facade
        # 335 = TM Round
        # 343 = TM Fling
        # 345 = TM Sky Drop
        # 346 = TM Incinerate
        # 356 = TM Rock Polish
        # 358 = TM Stone Edge
        # 367 = TM Rock Throw
        # 371 = TM Poison Jab
        # 618 = TM Spore
        # 619 = TM Toxic Spikes
        # 646 = TM Brutal Swing
        # 647 = TM Aurora Veil
        # 648 = TM Dazzling Gleam
        # 649 = TM Focus Punch
        # 650 = TM Infestation
        # 651 = TM Leech Life
        # 652 = TM Power Up Punch
        # 653 = TM Shock Wave
        # 654 = TM Smart Strike
        # 655 = TM Steel Wing
        # 656 = TM Stomping Tantrum
        # 657 = TM Throat Chop
        # 659 = TM Scald
        $game_temp.mart_prices[314] = [10000, 5000]
        $game_temp.mart_prices[329] = [10000, 5000]
        $game_temp.mart_prices[335] = [10000, 5000]
        $game_temp.mart_prices[343] = [10000, 5000]
        $game_temp.mart_prices[345] = [10000, 5000]
        $game_temp.mart_prices[346] = [10000, 5000]
        $game_temp.mart_prices[356] = [10000, 5000]
        $game_temp.mart_prices[358] = [10000, 5000]
        $game_temp.mart_prices[367] = [10000, 5000]
        $game_temp.mart_prices[371] = [10000, 5000]
        $game_temp.mart_prices[618] = [30000, 15000]
        $game_temp.mart_prices[619] = [30000, 15000]
        $game_temp.mart_prices[646] = [30000, 15000]
        $game_temp.mart_prices[647] = [30000, 15000]
        $game_temp.mart_prices[648] = [30000, 15000]
        $game_temp.mart_prices[649] = [30000, 15000]
        $game_temp.mart_prices[650] = [30000, 15000]
        $game_temp.mart_prices[651] = [30000, 15000]
        $game_temp.mart_prices[652] = [30000, 15000]
        $game_temp.mart_prices[653] = [30000, 15000]
        $game_temp.mart_prices[654] = [30000, 15000]
        $game_temp.mart_prices[655] = [30000, 15000]
        $game_temp.mart_prices[656] = [30000, 15000]
        $game_temp.mart_prices[657] = [30000, 15000]
        $game_temp.mart_prices[659] = [30000, 15000]
        # 570 = Transgender Stone
        # 604 = Secret Capsule
        # 568 = Mist Stone (evolve any Pokemon)
        # 569 = Devolution Spray
        # 249 = PPUP
        # 250 = PPMAX
        # 247 = Elixir
        # 248 = Elixir Max
        # 245 = Ether
        # 246 = Ether Max
        $game_temp.mart_prices[570] = [-1, 0] if $PokemonSystem.kuraystreamerdream != 0
        $game_temp.mart_prices[570] = [6900, 3450] if $PokemonSystem.kuraystreamerdream == 0
        # $game_temp.mart_prices[604] = [9100, 4550]
        $game_temp.mart_prices[568] = [999999, 24000] if !$game_switches[SWITCH_GOT_BADGE_8] && $PokemonSystem.kuraystreamerdream == 0
        $game_temp.mart_prices[568] = [42000, 24000] if $game_switches[SWITCH_GOT_BADGE_8] && $PokemonSystem.kuraystreamerdream == 0
        $game_temp.mart_prices[568] = [-1, 0] if $PokemonSystem.kuraystreamerdream != 0
        # $game_temp.mart_prices[569] = [8200, 4100]
        $game_temp.mart_prices[245] = [1200, 600]
        $game_temp.mart_prices[247] = [4000, 2000]
        $game_temp.mart_prices[249] = [9100, 4550]
        $game_temp.mart_prices[246] = [3600, 1800]
        $game_temp.mart_prices[248] = [12000, 6000]
        $game_temp.mart_prices[250] = [29120, 14560]
        # 114 = Focus Sash
        # 115 = Flame Orb
        # 116 = Toxic Orb
        # 100 = Life Orb
        $game_temp.mart_prices[114] = [6000, 3000]
        $game_temp.mart_prices[115] = [6000, 3000]
        $game_temp.mart_prices[116] = [6000, 3000]
        $game_temp.mart_prices[100] = [6000, 3000]
        # 263 = Rare Candy
        # 264 = Master Ball
        $game_temp.mart_prices[263] = [10000, 0] if $PokemonSystem.kuraystreamerdream == 0
        $game_temp.mart_prices[264] = [960000, 0] if $PokemonSystem.kuraystreamerdream == 0
        $game_temp.mart_prices[263] = [-1, 0] if $PokemonSystem.kuraystreamerdream != 0
        $game_temp.mart_prices[264] = [-1, 0] if $PokemonSystem.kuraystreamerdream != 0
        # allitems = [
        #   570, 604, 568, 569, 245, 247, 249, 246, 248, 250, 314, 371, 619, 618,
        #   114, 115, 116, 100
        # ]
        allitems = [
          570, 568, 245, 247, 249, 246, 248, 250,
          314, 329, 335, 343, 345, 346, 356, 358, 367, 371,
          618, 619, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656,
          657, 659,
          114, 115, 116, 100,
          263, 264
        ]
        # allitems.push(568) if $game_switches[SWITCH_GOT_BADGE_8]
        pbFadeOutIn {
          scene = PokemonMart_Scene.new
          screen = PokemonMartScreen.new(scene,allitems)
          screen.pbBuyScreen
        }
        $game_temp.mart_prices = oldmart.clone
        $game_temp.fromkurayshop = nil
        oldmart = []
      elsif cmdPokegear >= 0 && command == cmdPokegear
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdTrainer >= 0 && command == cmdTrainer
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdQuit >= 0 && command == cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave >= 0 && command == cmdSave
        @scene.pbHideMenu
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
        end
      elsif cmdOption >= 0 && command == cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
          @scene.pbRefresh
        }
      elsif cmdDebug >= 0 && command == cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdEndGame >= 0 && command == cmdEndGame
        @scene.pbHideMenu
        if pbConfirmMessage(_INTL("Are you sure you want to quit the game and return to the main menu?"))
          scene = PokemonSave_Scene.new
          screen = PokemonSaveScreen.new(scene)
          screen.pbSaveScreen
          $game_temp.to_title = true
          return
        else
          pbShowMenu
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene if endscene
  end
end
