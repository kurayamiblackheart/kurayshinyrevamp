#===============================================================================
#
#===============================================================================
class PokemonSystem
  #=================
  # Vanilla Values
  #=================
  # Global
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :runstyle
  attr_accessor :bgmvolume
  attr_accessor :sevolume
  attr_accessor :textinput
  attr_accessor :quicksurf
  attr_accessor :download_sprites
  # Per-save file
  attr_accessor :battlestyle
  attr_accessor :battle_type
  #=================
  # Modded Values
  #=================
  # Global
  attr_accessor :shiny_icons_kuray
  attr_accessor :kurayfusepreview
  attr_accessor :kuraynormalshiny
  attr_accessor :kurayshinyanim
  attr_accessor :kurayfonts
  attr_accessor :kuraybigicons
  attr_accessor :kurayindividcustomsprite
  attr_accessor :typedisplay
  # Per-save file
  attr_accessor :force_double_wild
  attr_accessor :improved_pokedex # adds base form pkmn of fusions to pokedex when catching/evolving fusions
  attr_accessor :recover_consumables
  attr_accessor :expall_redist
  attr_accessor :kuray_no_evo
  attr_accessor :shinyfusedye
  attr_accessor :kuraylevelcap
  attr_accessor :kurayqol
  attr_accessor :self_fusion_boost
  attr_accessor :damage_variance
  attr_accessor :shiny_trainer_pkmn
  attr_accessor :kuraygambleodds
  attr_accessor :shenanigans
  attr_accessor :kuraystreamerdream
  attr_accessor :autobattler

  def initialize
    # Vanilla Global
    @textspeed = 1 # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene = 0 # Battle effects (animations) (0=on, 1=off)
    @frame = 0 # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin = 0 # Speech frame
    @screensize = (Settings::SCREEN_SCALE * 2).floor - 1 # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language = 0 # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle = 0 # Default movement speed (0=walk, 1=run)
    @bgmvolume = 100 # Volume of background music and ME
    @sevolume = 100 # Volume of sound effects
    @textinput = 1 # Text input mode (0=cursor, 1=keyboard)
    @quicksurf = 0
    @download_sprites = 0
    # Vanilla Per-save file
    @battlestyle = 0 # Battle style (0=switch, 1=set)
    @battle_type = 0
    # Modded Global
    @shiny_icons_kuray = 0
    @kurayfusepreview = 0
    @kuraynormalshiny = 0
    @kurayshinyanim = 0
    @kurayfonts = 0
    @kuraybigicons = 0
    @kurayindividcustomsprite = 0
    @typedisplay = 0
    # Modded Per-save file
    @force_double_wild = 0
    @improved_pokedex = 0
    @recover_consumables = 0
    @expall_redist = 0
    @kuray_no_evo = 0
    @shinyfusedye = 0
    @kuraylevelcap = 0
    @kuraygambleodds = 100
    @kurayqol = 1
    @self_fusion_boost = 0
    @damage_variance = 1
    @shiny_trainer_pkmn = 0
    @shenanigans = 0
    @kuraystreamerdream = 0
    @autobattler = 0
  end

  def load_bootup_data(saved)
    # Vanilla
    @textspeed = saved.textspeed if saved.textspeed
    @battlescene = saved.battlescene if saved.battlescene
    @frame = saved.frame if saved.frame
    @textskin = saved.textskin if saved.textskin
    @screensize = saved.screensize if saved.screensize
    @language = saved.language if saved.language
    @runstyle = saved.runstyle if saved.runstyle
    @bgmvolume = saved.bgmvolume if saved.bgmvolume
    @sevolume = saved.sevolume if saved.sevolume
    @textinput = saved.textinput if saved.textinput
    @quicksurf = saved.quicksurf if saved.quicksurf
    @download_sprites = saved.download_sprites if saved.download_sprites
    # Modded
    @shiny_icons_kuray = saved.shiny_icons_kuray if saved.shiny_icons_kuray
    @kurayfusepreview = saved.kurayfusepreview if saved.kurayfusepreview
    @kuraynormalshiny = saved.kuraynormalshiny if saved.kuraynormalshiny
    @kurayshinyanim = saved.kurayshinyanim if saved.kurayshinyanim
    @kurayfonts = saved.kurayfonts if saved.kurayfonts
    @kuraybigicons = saved.kuraybigicons if saved.kuraybigicons
    @kurayindividcustomsprite = saved.kurayindividcustomsprite if saved.kurayindividcustomsprite
    @typedisplay = saved.typedisplay if saved.typedisplay
  end

  def load_file_data(saved)
    # Vanilla
    @battlestyle = saved.battlestyle if saved.battlestyle
    @battle_type = saved.battle_type if saved.battle_type
    # Modded
    @force_double_wild = saved.force_double_wild if saved.force_double_wild
    @improved_pokedex = saved.improved_pokedex if saved.improved_pokedex
    @recover_consumables = saved.recover_consumables if saved.recover_consumables
    @expall_redist = saved.expall_redist if saved.expall_redist
    @kuray_no_evo = saved.kuray_no_evo if saved.kuray_no_evo
    @shinyfusedye = saved.shinyfusedye if saved.shinyfusedye
    @kuraylevelcap = saved.kuraylevelcap if saved.kuraylevelcap
    @kuraystreamerdream = saved.kuraystreamerdream if saved.kuraystreamerdream
    @kuraygambleodds = saved.kuraygambleodds if saved.kuraygambleodds
    @kurayqol = saved.kurayqol if saved.kurayqol
    @self_fusion_boost = saved.self_fusion_boost if saved.self_fusion_boost
    @damage_variance = saved.damage_variance if saved.damage_variance
    @shiny_trainer_pkmn = saved.shiny_trainer_pkmn if saved.shiny_trainer_pkmn
    @shenanigans = saved.shenanigans if saved.shenanigans
    @autobattler = saved.autobattler if saved.autobattler
  end
end

#===============================================================================
#
#===============================================================================
module PropertyMixin
  def get
    (@getProc) ? @getProc.call : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end

class Option
  attr_reader :description

  def initialize(description)
    @description = description
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption < Option
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name, options, getProc, setProc, description = "")
    super(description)
    @name = name
    @values = options
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    return index
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name, options, getProc, setProc)
    @name = name
    @values = options
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    return index
  end
end

#===============================================================================
#
#===============================================================================
class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, optstart, optend, getProc, setProc)
    @name = name
    @optstart = optstart
    @optend = optend
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current + @optstart
    index += 1
    index = @optstart if index > @optend
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= 1
    index = @optend if index < @optstart
    return index - @optstart
  end
end

#===============================================================================
#
#===============================================================================
class SliderOption < Option
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, optstart, optend, optinterval, getProc, setProc, description = "")
    super(description)
    @name = name
    @optstart = optstart
    @optend = optend
    @optinterval = optinterval
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current + @optstart
    index += @optinterval
    index = @optend if index > @optend
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= @optinterval
    index = @optstart if index < @optstart
    return index - @optstart
  end
end

#===============================================================================
#
#===============================================================================
class ButtonOption < Option
  include PropertyMixin
  attr_reader :name
  
  def initialize(name, selectProc, description = "")
    super(description)
    @name = name
    @selectProc = selectProc
  end

  def next(current)
    self.activate
    return current
  end

  def prev(current)
    return current
  end

  def activate
    @selectProc.call
  end
end

#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions
  attr_reader :mustUpdateDescription
  attr_reader :selected_position

  def initialize(options, x, y, width, height)
    @previous_Index = 0
    @options = options
    @nameBaseColor = Color.new(24 * 8, 15 * 8, 0)
    @nameShadowColor = Color.new(31 * 8, 22 * 8, 10 * 8)
    @selBaseColor = Color.new(31 * 8, 6 * 8, 3 * 8)
    @selShadowColor = Color.new(31 * 8, 17 * 8, 16 * 8)
    @optvalues = []
    @mustUpdateOptions = false
    @mustUpdateDescription = false
    @selected_position = 0
    @allow_arrows_jump=false
    for i in 0...@options.length
      @optvalues[i] = 0
    end
    super(x, y, width, height)
  end

  def changedPosition
    @mustUpdateDescription = true
    super
  end

  def descriptionUpdated
    @mustUpdateDescription = false
  end

  def nameBaseColor=(value)
    @nameBaseColor = value
  end

  def nameShadowColor=(value)
    @nameShadowColor = value
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i, value)
    @optvalues[i] = value
    refresh
  end

  def setValueNoRefresh(i, value)
    @optvalues[i] = value
  end

  def itemCount
    return @options.length + 1
  end

  def dont_draw_item(index)
    return false
  end

  def drawItem(index, _count, rect)
    return if dont_draw_item(index)
    rect = drawCursor(index, rect)
    optionname = (index == @options.length) ? _INTL("Confirm") : @options[index].name
    optionwidth = rect.width * 9 / 20
    if @options[index] && @options[index].is_a?(ButtonOption)
      optionwidth = rect.width
    end
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     @nameBaseColor, @nameShadowColor)
    return if index == @options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length > 1
        totalwidth = 0
        for value in @options[index].values
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        for value in @options[index].values
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? @selBaseColor : self.baseColor,
                           (ivalue == self[index]) ? @selShadowColor : self.shadowColor
          )
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value = _INTL("Type {1}/{2}", @options[index].optstart + self[index],
                    @options[index].optend - @options[index].optstart + 1)
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    elsif @options[index].is_a?(SliderOption)
      value = sprintf(" %d", @options[index].optend)
      sliderlength = optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + rect.height / 2,
                              optionwidth - self.contents.text_size(value).width, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + (sliderlength - 8) * (@options[index].optstart + self[index]) / @options[index].optend,
        rect.y - 8 + rect.height / 2,
        8, 16, @selBaseColor)
      value = sprintf("%d", @options[index].optstart + self[index])
      xpos += optionwidth - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    elsif @options[index].is_a?(ButtonOption)
      # Print no value
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    end
  end

  def update
    oldindex = self.index
    @mustUpdateOptions = false
    super
    dorefresh = (self.index != oldindex)
    if self.active && self.index < @options.length
      if Input.repeat?(Input::LEFT)
        self[self.index] = @options[self.index].prev(self[self.index])
        dorefresh =
          @selected_position = self[self.index]
        @mustUpdateOptions = true
        @mustUpdateDescription = true
      elsif Input.repeat?(Input::RIGHT)
        self[self.index] = @options[self.index].next(self[self.index])
        dorefresh = true
        @selected_position = self[self.index]
        @mustUpdateOptions = true
        @mustUpdateDescription = true
      elsif Input.trigger?(Input::USE)
        if @options[self.index].is_a?(ButtonOption)
          @options[self.index].activate
          dorefresh = true
          @mustUpdateOptions = true
          @mustUpdateDescription = true
        end
      end
    end
    refresh if dorefresh
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class PokemonOption_Scene
  def getDefaultDescription
    return _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["option"].mustUpdateDescription
      updateDescription(@sprites["option"].index)
      @sprites["option"].descriptionUpdated
    end
  end

  def initialize
    @autosave_menu = false
  end

  def initUIElements
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Options"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
  end

  def pbStartScene(inloadscreen = false)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    initUIElements
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = pbGetOptions(inloadscreen)
    @PokemonOptions = pbAddOnOptions(@PokemonOptions)
    @sprites["option"] = initOptionsWindow
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"].setValueNoRefresh(i, (@PokemonOptions[i].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def initOptionsWindow
    optionsWindow = Window_PokemonOption.new(@PokemonOptions, 0,
                                             @sprites["title"].height, Graphics.width,
                                             Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end

  def updateDescription(index)
    index = 0 if !index
    begin
      horizontal_position = @sprites["option"].selected_position
      optionDescription = @PokemonOptions[index].description
      if optionDescription.is_a?(Array)
        if horizontal_position < optionDescription.size
          new_description = optionDescription[horizontal_position]
        else
          new_description = getDefaultDescription
        end
      else
        new_description = optionDescription
      end

      new_description = getDefaultDescription if new_description == ""
      @sprites["textbox"].text = _INTL(new_description)
    rescue
      @sprites["textbox"].text = getDefaultDescription
    end
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    options << SliderOption.new(_INTL("Music Volume"), 0, 100, 5,
                                proc { $PokemonSystem.bgmvolume },
                                proc { |value|
                                  if $PokemonSystem.bgmvolume != value
                                    $PokemonSystem.bgmvolume = value
                                    if $game_system.playing_bgm != nil && !inloadscreen
                                      playingBGM = $game_system.getPlayingBGM
                                      $game_system.bgm_pause
                                      $game_system.bgm_resume(playingBGM)
                                    end
                                  end
                                }, "Sets the volume for background music"
    )

    options << SliderOption.new(_INTL("SE Volume"), 0, 100, 5,
                                proc { $PokemonSystem.sevolume },
                                proc { |value|
                                  if $PokemonSystem.sevolume != value
                                    $PokemonSystem.sevolume = value
                                    if $game_system.playing_bgs != nil
                                      $game_system.playing_bgs.volume = value
                                      playingBGS = $game_system.getPlayingBGS
                                      $game_system.bgs_pause
                                      $game_system.bgs_resume(playingBGS)
                                    end
                                    pbPlayCursorSE
                                  end
                                }, "Sets the volume for sound effects"
    )
    options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast")],
                              proc { $PokemonSystem.textspeed },
                              proc { |value|
                                $PokemonSystem.textspeed = value
                                MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
                              }, "Sets the speed at which the text is displayed"
    )
    # if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) #beat the league
    #   options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast"), _INTL("Instant")],
    #                             proc { $PokemonSystem.textspeed },
    #                             proc { |value|
    #                               $PokemonSystem.textspeed = value
    #                               MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    #                             }, "Sets the speed at which the text is displayed"
    #   )
    # else
    #   options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast")],
    #                             proc { $PokemonSystem.textspeed },
    #                             proc { |value|
    #                               $PokemonSystem.textspeed = value
    #                               MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    #                             }, "Sets the speed at which the text is displayed"
    #   )
    # end
    options <<
      EnumOption.new(_INTL("Download sprites"), [_INTL("On"), _INTL("Off")],
                     proc { $PokemonSystem.download_sprites},
                     proc { |value|
                       $PokemonSystem.download_sprites = value
                     },
                     "Automatically download custom sprites from the internet"
      )




    if $game_switches
      options <<
        EnumOption.new(_INTL("Autosave"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[AUTOSAVE_ENABLED_SWITCH] ? 0 : 1 },
                       proc { |value|
                         if !$game_switches[AUTOSAVE_ENABLED_SWITCH] && value == 0
                           @autosave_menu = true
                           openAutosaveMenu()
                         end
                         $game_switches[AUTOSAVE_ENABLED_SWITCH] = value == 0
                       },
                       "Automatically saves when healing at Pokémon centers"
        )
    end

    if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) #beat the league
      options <<
        EnumOption.new(_INTL("Battle type"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
                       proc { $PokemonSystem.battle_type },
                       proc { |value|
                         if value == 0
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         elsif value == 1
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [2, 2]
                         elsif value == 2
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [3, 3]
                         else
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         end
                         $PokemonSystem.battle_type = value
                       }, "Sets the number of Pokémon sent out in battles (when possible)"
        )
    end

    # options <<
    #   EnumOption.new(_INTL("Double Wild"), [_INTL("Off"), _INTL("On")],
    #                   proc { $PokemonSystem.force_double_wild },
    #                   proc { |value|
    #                     if value == 0
    #                       $PokemonSystem.force_double_wild = 0
    #                     elsif value == 1
    #                       $PokemonSystem.force_double_wild = 1
    #                     end
    #                     $PokemonSystem.force_double_wild = value
    #                   }, "Double wild or nah ?"
    # )

    options << EnumOption.new(_INTL("Battle Effects"), [_INTL("On"), _INTL("Off")],
                              proc { $PokemonSystem.battlescene },
                              proc { |value| $PokemonSystem.battlescene = value },
                              "Display move animations in battles"
    )

    options << EnumOption.new(_INTL("Battle Style"), [_INTL("Switch"), _INTL("Set")],
                              proc { $PokemonSystem.battlestyle },
                              proc { |value| $PokemonSystem.battlestyle = value },
                              ["Prompts to switch Pokémon before the opponent sends out the next one",
                              "No prompt to switch Pokémon before the opponent sends the next one"]
    )

    options << EnumOption.new(_INTL("Default Movement"), [_INTL("Walking"), _INTL("Running")],
                              proc { $PokemonSystem.runstyle },
                              proc { |value| $PokemonSystem.runstyle = value },
                              ["Default to walking when not holding the Run key",
                               "Default to running when not holding the Run key"]
    )

    options << NumberOption.new(_INTL("Speech Frame"), 1, Settings::SPEECH_WINDOWSKINS.length,
                                proc { $PokemonSystem.textskin },
                                proc { |value|
                                  $PokemonSystem.textskin = value
                                  MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
                                }
    )
    # NumberOption.new(_INTL("Menu Frame"),1,Settings::MENU_WINDOWSKINS.length,
    #   proc { $PokemonSystem.frame },
    #   proc { |value|
    #     $PokemonSystem.frame = value
    #     MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    #   }
    # ),
    options << EnumOption.new(_INTL("Text Entry"), [_INTL("Cursor"), _INTL("Keyboard")],
                              proc { $PokemonSystem.textinput },
                              proc { |value| $PokemonSystem.textinput = value },
                              ["Enter text by selecting letters on the screen",
                               "Enter text by typing on the keyboard"]
    )
    if $game_variables
      options << EnumOption.new(_INTL("Fusion icons"), [_INTL("Combined"), _INTL("DNA")],
                                proc { $game_variables[VAR_FUSION_ICON_STYLE] },
                                proc { |value| $game_variables[VAR_FUSION_ICON_STYLE] = value },
                                ["Combines both Pokémon's party icons",
                                 "Uses the same party icon for all fusions"]
      )
    end
    options << EnumOption.new(_INTL("Screen Size"), [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
                              proc { [$PokemonSystem.screensize, 4].min },
                              proc { |value|
                                if $PokemonSystem.screensize != value
                                  $PokemonSystem.screensize = value
                                  pbSetResizeFactor($PokemonSystem.screensize)
                                end
                              }, "Sets the size of the screen"
    )
    options << EnumOption.new(_INTL("Quick Field Moves"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksurf },
                              proc { |value| $PokemonSystem.quicksurf = value },
                              "Use Field Moves quicker"
    )

    options << ButtonOption.new(_INTL("Kuray's PIF Revamp Settings"),
                              proc {
                                @kuray_menu = true
                                openKurayMenu()
                              }, "Customize modded features"
    )

    return options
  end

  def pbAddOnOptions(options)
    return options
  end

  def openAutosaveMenu()
    return if !@autosave_menu
    pbFadeOutIn {
      scene = AutosaveOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @autosave_menu = false
  end

  def openKurayMenu()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end

  def pbOptions
    oldSystemSkin = $PokemonSystem.frame # Menu
    oldTextSkin = $PokemonSystem.textskin # Speech
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          for i in 0...@PokemonOptions.length
            @PokemonOptions[i].set(@sprites["option"][i])
          end
          if $PokemonSystem.textskin != oldTextSkin
            @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
            @sprites["textbox"].text = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
            oldTextSkin = $PokemonSystem.textskin
          end
          if $PokemonSystem.frame != oldSystemSkin
            @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
            @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
            oldSystemSkin = $PokemonSystem.frame
          end
        end
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          break if isConfirmedOnKeyPress
        end
      end
    }
  end

  def isConfirmedOnKeyPress
    return @sprites["option"].index == @PokemonOptions.length
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@PokemonOptions.length
      @PokemonOptions[i].set(@sprites["option"][i])
    end
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonOptionScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(inloadscreen = false)
    @scene.pbStartScene(inloadscreen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
class KurayOptionsScene < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Kuray's PIF Revamp settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    options << EnumOption.new(_INTL("Shiny Revamp"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.kuraynormalshiny },
                      proc { |value| $PokemonSystem.kuraynormalshiny = value },
                      ["Use Shiny Revamping (shiny Pokemons look better)",
                      "Don't use Shiny Revamping (shiny Pokemons look worse)"]
    )
    options << EnumOption.new(_INTL("Shiny Animation"), [_INTL("On"), _INTL("Off"), _INTL("All")],
                      proc { $PokemonSystem.kurayshinyanim },
                      proc { |value| $PokemonSystem.kurayshinyanim = value },
                      ["Display the shiny animations in battles",
                      "Don't display the shiny animations in battles",
                      "Display shiny animations on non-shiny as well"]
    )
    options << EnumOption.new(_INTL("Shiny Icons"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.shiny_icons_kuray },
                      proc { |value| $PokemonSystem.shiny_icons_kuray = value },
                      ["Shinies don't have a shiny icon",
                      "Shinies have shiny icons (reduces performances!)"]
    )
    options << EnumOption.new(_INTL("Big Pokémon Icons"), [_INTL("Off"), _INTL("Limited"), _INTL("All")],
                      proc { $PokemonSystem.kuraybigicons },
                      proc { |value| $PokemonSystem.kuraybigicons = value },
                      ["Pokémon will use their small box sprites for icons",
                      "Pokémon icons will use their full-size battle sprites (except in boxes)",
                      "Pokémon icons will use their full-size battle sprites"]
    )
    options << EnumOption.new(_INTL("Fusion Preview"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kurayfusepreview },
                      proc { |value| $PokemonSystem.kurayfusepreview = value },
                      ["Don't preview what unknown fusions look like",
                      "Preview what unknown fusions look like"]
    )
    options << EnumOption.new(_INTL("Ind. Custom Sprites"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.kurayindividcustomsprite },
                      proc { |value| $PokemonSystem.kurayindividcustomsprite = value },
                      ["Two of the same Pokemons can use different sprites (mod)",
                      "Two of the same Pokemons will use the same sprite (vanilla)"]
    )
    options << EnumOption.new(_INTL("Type Display"), [_INTL("Off"), _INTL("Icons"), _INTL("TCG"), _INTL("Sqr"), _INTL("Txt")],
                      proc { $PokemonSystem.typedisplay },
                      proc { |value| $PokemonSystem.typedisplay = value },
                      ["Don't draw the type indicator in battle",
                      "Draws handmade custom type icons in battle | Artwork by Lolpy1",
                      "Draws TCG themed type icons in battle",
                      "Draws the square type icons in battle | Triple Fusion artwork by Lolpy1",
                      "Draws the text type display in battle"]
    )
    options << EnumOption.new(_INTL("Game's Font"), [_INTL("Default "), _INTL("FR/LG "), _INTL("D/P "), _INTL("R/B")],
                      proc { $PokemonSystem.kurayfonts },
                      proc { |value|
                        if value == 0
                          $PokemonSystem.kurayfonts = 0
                          # MessageConfig::FONT_SIZE = 29
                          # MessageConfig::NARROW_FONT_SIZE = 29
                          MessageConfig.pbGetSystemFontSizeset(29)
                          MessageConfig.pbGetSmallFontSizeset(25)
                          MessageConfig.pbGetNarrowFontSizeset(29)
                          MessageConfig.pbSetSystemFontName("Power Green")
                          MessageConfig.pbSetSmallFontName("Power Green Small")
                          MessageConfig.pbSetNarrowFontName("Power Green Narrow")
                          MessageConfig.pbGetSystemFontSizeset(29)
                          MessageConfig.pbGetSmallFontSizeset(25)
                          MessageConfig.pbGetNarrowFontSizeset(29)
                        elsif value == 1
                          $PokemonSystem.kurayfonts = 1
                          # MessageConfig::FONT_SIZE = 26
                          # MessageConfig::NARROW_FONT_SIZE = 26
                          MessageConfig.pbGetSystemFontSizeset(26)
                          MessageConfig.pbGetSmallFontSizeset(25)
                          MessageConfig.pbGetNarrowFontSizeset(26)
                          MessageConfig.pbSetSystemFontName("Power Red and Green")
                          MessageConfig.pbSetSmallFontName("Power Green Small")
                          MessageConfig.pbSetNarrowFontName("Power Green Small")
                        elsif value == 2
                          $PokemonSystem.kurayfonts = 2
                          MessageConfig.pbGetSystemFontSizeset(29)
                          MessageConfig.pbGetSmallFontSizeset(25)
                          MessageConfig.pbGetNarrowFontSizeset(29)
                          MessageConfig.pbSetSystemFontName("Power Clear")
                          MessageConfig.pbSetSmallFontName("Power Clear")
                          MessageConfig.pbSetNarrowFontName("Power Clear")
                        elsif value == 3
                          $PokemonSystem.kurayfonts = 3
                          MessageConfig.pbGetSystemFontSizeset(29)
                          MessageConfig.pbGetSmallFontSizeset(25)
                          MessageConfig.pbGetNarrowFontSizeset(29)
                          MessageConfig.pbSetSystemFontName("Power Red and Blue")
                          MessageConfig.pbSetSmallFontName("Power Red and Blue")
                          MessageConfig.pbSetNarrowFontName("Power Red and Blue")
                        end
                        $PokemonSystem.kurayfonts = value
                      }, "Changes the Game's font"
    )
    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    end
    return options
  end

  def pbGetInGameOptions()
    options = []
    options << EnumOption.new(_INTL("Shiny Fuse Dye"), [_INTL("Off"), _INTL("On"), _INTL("Random")],
                      proc { $PokemonSystem.shinyfusedye },
                      proc { |value| $PokemonSystem.shinyfusedye = value },
                      ["Don't use the shiny fusion color dye system",
                      "Use the shiny fusion color dye system",
                      "Re-roll shiny color after each fusion/unfusion"]
    )
    options << EnumOption.new(_INTL("Wild Battles"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
                      proc { $PokemonSystem.force_double_wild },
                      proc { |value| $PokemonSystem.force_double_wild = value },
                      ["Wild battles always 1v1",
                      "Wild battles in 2v2 when possible",
                      "Wild battles in 3v3 'cause it's cool"]
    )
    options << EnumOption.new(_INTL("Improved Pokedex"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.improved_pokedex },
                      proc { |value| $PokemonSystem.improved_pokedex = value },
                      ["Don't use the Improved Pokedex",
                      "Registers a fusions base Pokemon to the Pokedex when catching/evolving"]
    )
    options << EnumOption.new(_INTL("Recover Consumables"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.recover_consumables },
                      proc { |value| $PokemonSystem.recover_consumables = value },
                      ["Don't recover consumable items after battle",
                      "Recover consumable items after battle"]
    )
    options << SliderOption.new(_INTL("ExpAll Redistribution"), 0, 10, 1,
                      proc { $PokemonSystem.expall_redist },
                      proc { |value| $PokemonSystem.expall_redist = value },
                      "0 = Off, 10 = Max | Redistributes total exp from expAll to lower level pokemon"
    )
    options << EnumOption.new(_INTL("Enable EvoLock"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kuray_no_evo },
                      proc { |value| $PokemonSystem.kuray_no_evo = value },
                      ["Can't EvoLock a Pokemon without holding everstone",
                      "Can EvoLock Pokemons in the PC"]
    )
    options << EnumOption.new(_INTL("Level Cap"), [_INTL("Off"), _INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
                      proc { $PokemonSystem.kuraylevelcap },
                      proc { |value| $PokemonSystem.kuraylevelcap = value },
                      ["No Forced Level Cap",
                      "Easy Level Cap, for children",
                      "Normal Level Cap, for normal people",
                      "Hard Level Cap, for nerds"]
    )
    options << EnumOption.new(_INTL("Self-Fusion Stat Boost"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.self_fusion_boost },
                      proc { |value| $PokemonSystem.self_fusion_boost = value },
                      ["Stat boost for self-fusions is disabled.",
                      "Stat boost for self-fusions is enabled."]
    )
    options << EnumOption.new(_INTL("Damage Variance"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.damage_variance },
                      proc { |value| $PokemonSystem.damage_variance = value },
                      ["Damage Variance is disabled.",
                      "Damage Variance is enabled."]
    )
    options << EnumOption.new(_INTL("Shiny Trainer Pokemon"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.shiny_trainer_pkmn },
                      proc { |value| $PokemonSystem.shiny_trainer_pkmn = value },
                      ["Trainer pokemon will have their normal shiny rates",
                      "All trainers pokemon in their party will be shiny"]
    )
    options << SliderOption.new(_INTL("Shiny Gamble Odds"), 0, 1000, 10,
                      proc { $PokemonSystem.kuraygambleodds },
                      proc { |value|
                        if $PokemonSystem.kuraygambleodds != value
                          $PokemonSystem.kuraygambleodds = value
                        end
                      }, "1 out of <x> | Choose the odds of Shinies from Gamble | 0 = Always"
    )
    options << EnumOption.new(_INTL("Kuray QoL"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kurayqol },
                      proc { |value| $PokemonSystem.kurayqol = value },
                      ["Kuray's QoL features OFF",
                      "Kuray's QoL features ON"]
    )
    options << EnumOption.new(_INTL("Kuray's Shenanigans"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.shenanigans },
                      proc { |value| $PokemonSystem.shenanigans = value },
                      ["You're playing with Shenanigans! (Easter Eggs)",
                      "You're playing normally! (No Easter Eggs)"]
    )
    options << EnumOption.new(_INTL("Streamer's Dream"), [_INTL("Off"), _INTL("On"), _INTL("Dream more!")],
                      proc { $PokemonSystem.kuraystreamerdream },
                      proc { |value|
                        if value == 0
                          $PokemonSystem.kuraystreamerdream = 0
                        elsif value == 1
                          $PokemonSystem.kuraystreamerdream = 1
                        elsif value == 2
                          $PokemonSystem.kuraystreamerdream = 2
                          $game_switches[252]=true
                          # $game_variables[VAR_PREMIUM_WONDERTRADE_LEFT] = 999999
                          # $game_variables[VAR_STANDARD_WONDERTRADE_LEFT] = 999999
                        end
                        $PokemonSystem.kuraystreamerdream = value
                      },
                      ["No Rare Candies/Master Balls/etc free in Kuray Shop",
                      "Rare Candies/Master Balls and more are free in Kuray Shop",
                      "Also Unlimited WonderTrades (need 1 badge)"]
    )
    options << EnumOption.new(_INTL("Auto-Battle"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.autobattler },
                      proc { |value| $PokemonSystem.autobattler = value },
                      ["You fight your own battles",
                      "Allows Trapstarr to take control of your pokemon"]
    )
    return options
  end
end
