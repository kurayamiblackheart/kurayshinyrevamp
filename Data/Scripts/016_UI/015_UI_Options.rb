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
  attr_accessor :max_nb_sprites_download
  attr_accessor :on_mobile
  attr_accessor :type_icons
  attr_accessor :use_generated_dex_entries
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
  attr_accessor :battlegui
  attr_accessor :darkmode
  attr_accessor :globalvalues # allows to disable the per-save file functionnality
  attr_accessor :quicksave
  # Per-save file
  attr_accessor :force_double_wild
  attr_accessor :improved_pokedex # adds base form pkmn of fusions to pokedex when catching/evolving fusions
  attr_accessor :recover_consumables
  attr_accessor :expall_redist
  attr_accessor :kuray_no_evo
  attr_accessor :shinyfusedye
  attr_accessor :kuraylevelcap
  attr_accessor :kurayqol
  attr_accessor :tutornet # DemICE
  attr_accessor :self_fusion_boost
  attr_accessor :dominant_fusion_types
  attr_accessor :damage_variance
  attr_accessor :shiny_trainer_pkmn
  attr_accessor :kuraygambleodds
  attr_accessor :shenanigans
  attr_accessor :kuraystreamerdream
  attr_accessor :autobattler
  attr_accessor :autobattleshortcut
  attr_accessor :autobattlershiny
  attr_accessor :kurayeggs_fusionpool
  attr_accessor :kurayeggs_instanthatch
  attr_accessor :kurayeggs_rarity
  attr_accessor :kurayeggs_fusionodds
  attr_accessor :shinyodds # overwrite the shiny odds
  attr_accessor :unfusetraded # allow to unfuse traded pokemons


  attr_accessor :nomoneylost # temp variable for self-battles


  attr_accessor :sb_maxing # allows to have more pokemons than the opponent
  attr_accessor :sb_soullinked # pokemons of the team are soul-linked (not recommended)

  attr_accessor :sb_randomizeteam
  attr_accessor :sb_randomizeshare
  attr_accessor :sb_randomizesize
  attr_accessor :sb_battlesize
  attr_accessor :sb_select
  attr_accessor :sb_level
  attr_accessor :sb_playerfolder

  attr_accessor :debugfeature

  attr_accessor :debug

  attr_accessor :is_in_battle

  attr_accessor :sb_stat_tracker
  attr_accessor :player_wins
  attr_accessor :enemy_wins

  attr_accessor :sb_loopinput
  attr_accessor :sb_loopbreaker

  attr_accessor :importnodelete
  attr_accessor :exportdelete
  attr_accessor :savefolder

  attr_accessor :importlvl
  attr_accessor :importdevolve

  attr_accessor :importegg

  attr_accessor :nopngexport
  attr_accessor :nopngimport

  attr_accessor :raiser
  attr_accessor :raiserb

  attr_accessor :legendarybreed

  attr_accessor :eventmoves

  attr_accessor :shinyadvanced

  attr_accessor :custom_bst
  attr_accessor :custom_bst_sliders
  attr_accessor :custom_bst_npc
  attr_accessor :custom_bst_sliders_npc
  attr_accessor :pokeradarplus

  #Made by Blue Wuppo
  attr_accessor :walkingpoison
  attr_accessor :modernhail
  attr_accessor :frostbite
  attr_accessor :drowsy
  attr_accessor :bugbuff
  attr_accessor :icebuff
  #End of By Blue Wuppo

  attr_accessor :ch_metronome
  attr_accessor :ch_letdownplayer
  attr_accessor :ch_letdown
  attr_accessor :ch_berserker

  attr_accessor :dexspriteselect

  attr_accessor :speedvalue
  attr_accessor :speedtoggle
  attr_accessor :speedvaluedef
  attr_accessor :speeduplimit
  attr_accessor :shiny_cache

  attr_accessor :skipcaughtprompt
  attr_accessor :skipcaughtnickname

  attr_accessor :levelcapbehavior

  attr_accessor :optionsnames

  attr_accessor :noevsmode
  attr_accessor :maxivsmode
  attr_accessor :showlevel_nolevelmode
  attr_accessor :evstrain

  attr_accessor :rocketballsteal

  attr_accessor :trainerexpboost

  attr_accessor :playerage_temp

  attr_accessor :trainerprogress
  attr_accessor :gymrewardeggs

  def initialize
    # Vanilla Global
    @raiser = 1
    @raiserb = 0
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
    @max_nb_sprites_download = 5
    @on_mobile = false
    @type_icons = true
    @use_generated_dex_entries = true
    @quicksave = 1
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
    @kurayindividcustomsprite = 1
    @typedisplay = 0
    @battlegui = 0
    @darkmode = 1
    # Modded Per-save file
    @force_double_wild = 0
    @improved_pokedex = 0
    @recover_consumables = 0
    @expall_redist = 0
    @kuray_no_evo = 0
    @shinyfusedye = 0
    @kuraylevelcap = 0
    @levelcapbehavior = 0
    @optionsnames = Array.new(12) { |i| "Slot #{i + 1}" }
    @kuraygambleodds = 100
    @kurayqol = 1
    @tutornet = 1 # DemICE
    @self_fusion_boost = 0
    @dominant_fusion_types = 0
    @damage_variance = 1
    @shiny_trainer_pkmn = 0
    @shenanigans = 0
    @kuraystreamerdream = 0
    @autobattler = 0
    @autobattleshortcut = 0
    @autobattlershiny = 0
    @kurayeggs_fusionodds = 20
    @kurayeggs_fusionpool = 0
    @kurayeggs_instanthatch = 0
    @kurayeggs_rarity = 0
    @sb_maxing = 1
    @unfusetraded = 0
    @sb_soullinked = 0
    @globalvalues = 0
    @sb_randomizeteam = 0
    @sb_randomizeshare = 1
    @sb_randomizesize = 5
    @sb_battlesize = 5
    @importlvl = 0
    @importegg = 0
    @importdevolve = 0
    @sb_select = 1
    @sb_playerfolder = 0
    @sb_level = 0
    @debugfeature = 0
    @debug = 0
    @dexspriteselect = 0
    @legendarybreed = 0
    @eventmoves = 0
    @nopngexport = 0
    @nopngimport = 0
    
    # Challenges
    @ch_metronome = 0
    @ch_letdownplayer = 0
    @ch_letdown = 0
    @ch_berserker = 0

    @custom_bst = 0
    @custom_bst_sliders = {
      :HP => 67,
      :HP_BODY => 33,
      :ATTACK => 33,
      :ATTACK_BODY => 67,
      :DEFENSE => 33,
      :DEFENSE_BODY => 67,
      :SPECIAL_ATTACK => 67,
      :SPECIAL_ATTACK_BODY => 33,
      :SPECIAL_DEFENSE => 67,
      :SPECIAL_DEFENSE_BODY => 33,
      :SPEED => 33,
      :SPEED_BODY => 67
    }
    @custom_bst_npc = 0
    @custom_bst_sliders_npc = {
      :HP => 65,
      :HP_BODY => 35,
      :ATTACK => 35,
      :ATTACK_BODY => 65,
      :DEFENSE => 35,
      :DEFENSE_BODY => 65,
      :SPECIAL_ATTACK => 65,
      :SPECIAL_ATTACK_BODY => 35,
      :SPECIAL_DEFENSE => 65,
      :SPECIAL_DEFENSE_BODY => 35,
      :SPEED => 35,
      :SPEED_BODY => 65
    }
    @pokeradarplus = 0
    @importnodelete = 0
	@sb_stat_tracker = 0
	@player_wins = 0
    @enemy_wins = 0
    @sb_loopinput = 0
    @sb_loopbreaker = 0
    @savefolder = 0
    @exportdelete = 0
    @shinyadvanced = 1
    @is_in_battle = false
    if Settings::SHINY_POKEMON_CHANCE
      @shinyodds = Settings::SHINY_POKEMON_CHANCE
    else
      @shinyodds = 16
    end
    #Made by Blue Wuppo
    @walkingpoison = 0
    @modernhail = 0
    @frostbite = 0
    @drowsy = 0
    @bugbuff = 0
    @icebuff = 0
    #End of By Blue Wuppo
    @speedvalue = 2
    @speedtoggle = 0#0 = Old way (Old PIF speedup system), 1 = HOLD (new way)
    @speeduplimit = 4
    @shiny_cache = 0#0 = ON, 1 = OFF
    @speedvaluedef = 0
    @skipcaughtnickname = 0#0 = false, 1 = true
    @skipcaughtprompt = 0#0 = false, 1 = true

    @noevsmode = 0
    @maxivsmode = 0
    @evstrain = 0
    @showlevel_nolevelmode = 0
    @rocketballsteal = 0
    @trainerexpboost = 50
    @playerage_temp = 0
    @gymrewardeggs = 3

    @trainerprogress = []
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
    @quicksave = saved.quicksave if saved.quicksave
    @download_sprites = saved.download_sprites if saved.download_sprites
    @on_mobile = saved.on_mobile if saved.on_mobile
    # Modded
    @shiny_icons_kuray = saved.shiny_icons_kuray if saved.shiny_icons_kuray
    @kurayfusepreview = saved.kurayfusepreview if saved.kurayfusepreview
    @kuraynormalshiny = saved.kuraynormalshiny if saved.kuraynormalshiny
    @kurayshinyanim = saved.kurayshinyanim if saved.kurayshinyanim
    @kurayfonts = saved.kurayfonts if saved.kurayfonts
    @kuraybigicons = saved.kuraybigicons if saved.kuraybigicons
    @kurayindividcustomsprite = saved.kurayindividcustomsprite if saved.kurayindividcustomsprite
    @typedisplay = saved.typedisplay if saved.typedisplay
    @battlegui = saved.battlegui if saved.battlegui
    @darkmode = saved.darkmode if saved.darkmode
    @debugfeature = saved.debugfeature if saved.debugfeature
    @debug = saved.debug if saved.debug
    @dexspriteselect = saved.dexspriteselect if saved.dexspriteselect
    @speedtoggle = saved.speedtoggle if saved.speedtoggle
    @speedvalue = saved.speedvalue if saved.speedvalue
    @speeduplimit = saved.speeduplimit if saved.speeduplimit
    @speedvaluedef = saved.speedvaluedef if saved.speedvaluedef
    @shiny_cache = saved.shiny_cache if saved.shiny_cache


    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed($PokemonSystem.textspeed))
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[$PokemonSystem.textskin])
    # pbSetResizeFactor($PokemonSystem.screensize)
    if $PokemonSystem.kurayfonts == 0
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
    elsif $PokemonSystem.kurayfonts == 1
      # MessageConfig::FONT_SIZE = 26
      # MessageConfig::NARROW_FONT_SIZE = 26
      MessageConfig.pbGetSystemFontSizeset(26)
      MessageConfig.pbGetSmallFontSizeset(25)
      MessageConfig.pbGetNarrowFontSizeset(26)
      MessageConfig.pbSetSystemFontName("Power Red and Green")
      MessageConfig.pbSetSmallFontName("Power Green Small")
      MessageConfig.pbSetNarrowFontName("Power Green Small")
    elsif $PokemonSystem.kurayfonts == 2
      MessageConfig.pbGetSystemFontSizeset(29)
      MessageConfig.pbGetSmallFontSizeset(25)
      MessageConfig.pbGetNarrowFontSizeset(29)
      MessageConfig.pbSetSystemFontName("Power Clear")
      MessageConfig.pbSetSmallFontName("Power Clear")
      MessageConfig.pbSetNarrowFontName("Power Clear")
    elsif $PokemonSystem.kurayfonts == 3
      MessageConfig.pbGetSystemFontSizeset(29)
      MessageConfig.pbGetSmallFontSizeset(25)
      MessageConfig.pbGetNarrowFontSizeset(29)
      MessageConfig.pbSetSystemFontName("Power Red and Blue")
      MessageConfig.pbSetSmallFontName("Power Red and Blue")
      MessageConfig.pbSetNarrowFontName("Power Red and Blue")
    end
    # if saved.globalvalues
    #   @globalvalues = saved.globalvalues
    #   if saved.globalvalues != 0
    #     load_file_data(saved)#also load per-savefile datas
    #   end
    # end
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
    @levelcapbehavior = saved.levelcapbehavior if saved.levelcapbehavior
    @optionsnames = saved.optionsnames if saved.optionsnames
    @kuraystreamerdream = saved.kuraystreamerdream if saved.kuraystreamerdream
    @kuraygambleodds = saved.kuraygambleodds if saved.kuraygambleodds
    @kurayqol = saved.kurayqol if saved.kurayqol
    @tutornet = saved.tutornet if saved.tutornet # DemICE
    @self_fusion_boost = saved.self_fusion_boost if saved.self_fusion_boost
    @dominant_fusion_types = saved.dominant_fusion_types if saved.dominant_fusion_types
    @damage_variance = saved.damage_variance if saved.damage_variance
    @shiny_trainer_pkmn = saved.shiny_trainer_pkmn if saved.shiny_trainer_pkmn
    @shenanigans = saved.shenanigans if saved.shenanigans
    @autobattler = saved.autobattler if saved.autobattler
    @autobattleshortcut = saved.autobattleshortcut if saved.autobattleshortcut
    @autobattlershiny = saved.autobattlershiny if saved.autobattlershiny
    @kurayeggs_fusionpool = saved.kurayeggs_fusionpool if saved.kurayeggs_fusionpool
    @kurayeggs_instanthatch = saved.kurayeggs_instanthatch if saved.kurayeggs_instanthatch
    @kurayeggs_rarity = saved.kurayeggs_rarity if saved.kurayeggs_rarity
    @kurayeggs_fusionodds = saved.kurayeggs_fusionodds if saved.kurayeggs_fusionodds
    @shinyodds = saved.shinyodds if saved.shinyodds
    @sb_maxing = saved.sb_maxing if saved.sb_maxing
    @sb_soullinked = saved.sb_soullinked if saved.sb_soullinked
    @sb_randomizeshare = saved.sb_randomizeshare if saved.sb_randomizeshare
    @sb_randomizeteam = saved.sb_randomizeteam if saved.sb_randomizeteam
    @sb_randomizesize = saved.sb_randomizesize if saved.sb_randomizesize
    @sb_battlesize = saved.sb_battlesize if saved.sb_battlesize
    @sb_select = saved.sb_select if saved.sb_select
    @sb_playerfolder = saved.sb_playerfolder if saved.sb_playerfolder
    @sb_level = saved.sb_level if saved.sb_level
    @sb_stat_tracker = saved.sb_stat_tracker if saved.sb_stat_tracker
    @unfusetraded = saved.unfusetraded if saved.unfusetraded
    @importlvl = saved.importlvl if saved.importlvl
    @importegg = saved.importegg if saved.importegg
    @importdevolve = saved.importdevolve if saved.importdevolve
    @importnodelete = saved.importnodelete if saved.importnodelete
    @exportdelete = saved.exportdelete if saved.exportdelete
    @shinyadvanced = saved.shinyadvanced if saved.shinyadvanced
    @savefolder = saved.savefolder if saved.savefolder
    @nopngexport = saved.nopngexport if saved.nopngexport
    @nopngimport = saved.nopngimport if saved.nopngimport
    @legendarybreed = saved.legendarybreed if saved.legendarybreed
    @eventmoves = saved.eventmoves if saved.eventmoves
    @custom_bst = saved.custom_bst if saved.custom_bst
    @custom_bst_sliders = saved.custom_bst_sliders if saved.custom_bst_sliders
    @custom_bst_npc = saved.custom_bst_npc if saved.custom_bst_npc
    @custom_bst_sliders_npc = saved.custom_bst_sliders_npc if saved.custom_bst_sliders_npc
    @pokeradarplus = saved.pokeradarplus if saved.pokeradarplus
    #Made by Blue Wuppo
    @walkingpoison = saved.walkingpoison if saved.walkingpoison
    @modernhail = saved.modernhail if saved.modernhail
    @frostbite = saved.frostbite if saved.frostbite
    @drowsy = saved.drowsy if saved.drowsy
    @bugbuff = saved.bugbuff if saved.bugbuff
    @icebuff = saved.icebuff if saved.icebuff
    #End of By Blue Wuppo
    # Challenges
    @ch_metronome = saved.ch_metronome if saved.ch_metronome
    @ch_letdownplayer = saved.ch_letdownplayer if saved.ch_letdownplayer
    @ch_letdown = saved.ch_letdown if saved.ch_letdown
    @ch_berserker = saved.ch_berserker if saved.ch_berserker
    # End of Challenges
    @skipcaughtnickname = saved.skipcaughtnickname if saved.skipcaughtnickname
    @skipcaughtprompt = saved.skipcaughtprompt if saved.skipcaughtprompt
    @noevsmode = saved.noevsmode if saved.noevsmode
    @maxivsmode = saved.maxivsmode if saved.maxivsmode
    @evstrain = saved.evstrain if saved.evstrain
    @showlevel_nolevelmode = saved.showlevel_nolevelmode if saved.showlevel_nolevelmode
    @rocketballsteal = saved.rocketballsteal if saved.rocketballsteal
    @trainerexpboost = saved.trainerexpboost if saved.trainerexpboost
    @gymrewardeggs = saved.gymrewardeggs if saved.gymrewardeggs
    @trainerprogress = saved.trainerprogress if saved.trainerprogress
  end
end

def options_as_json(options={})
  {
    "json_version" => "0.8",
    "textspeed" => $PokemonSystem.textspeed,
    "battlescene" => $PokemonSystem.battlescene,
    "frame" => $PokemonSystem.frame,
    "textskin" => $PokemonSystem.textskin,
    "screensize" => $PokemonSystem.screensize,
    "language" => $PokemonSystem.language,
    "runstyle" => $PokemonSystem.runstyle,
    "bgmvolume" => $PokemonSystem.bgmvolume,
    "sevolume" => $PokemonSystem.sevolume,
    "textinput" => $PokemonSystem.textinput,
    "quicksurf" => $PokemonSystem.quicksurf,
    "download_sprites" => $PokemonSystem.download_sprites,
    "on_mobile" => $PokemonSystem.on_mobile,
    "battlestyle" => $PokemonSystem.battlestyle,
    "battle_type" => $PokemonSystem.battle_type,
    "shiny_icons_kuray" => $PokemonSystem.shiny_icons_kuray,
    "kurayfusepreview" => $PokemonSystem.kurayfusepreview,
    "kuraynormalshiny" => $PokemonSystem.kuraynormalshiny,
    "kurayshinyanim" => $PokemonSystem.kurayshinyanim,
    "kurayfonts" => $PokemonSystem.kurayfonts,
    "kuraybigicons" => $PokemonSystem.kuraybigicons,
    "kurayindividcustomsprite" => $PokemonSystem.kurayindividcustomsprite,
    "typedisplay" => $PokemonSystem.typedisplay,
    "battlegui" => $PokemonSystem.battlegui,
    "darkmode" => $PokemonSystem.darkmode,
    "globalvalues" => $PokemonSystem.globalvalues,
    "quicksave" => $PokemonSystem.quicksave,
    "force_double_wild" => $PokemonSystem.force_double_wild,
    "improved_pokedex" => $PokemonSystem.improved_pokedex,
    "recover_consumables" => $PokemonSystem.recover_consumables,
    "expall_redist" => $PokemonSystem.expall_redist,
    "kuray_no_evo" => $PokemonSystem.kuray_no_evo,
    "shinyfusedye" => $PokemonSystem.shinyfusedye,
    "kuraylevelcap" => $PokemonSystem.kuraylevelcap,
    "kurayqol" => $PokemonSystem.kurayqol,
    "tutornet" => $PokemonSystem.tutornet,
    "self_fusion_boost" => $PokemonSystem.self_fusion_boost,
    "dominant_fusion_types" => $PokemonSystem.dominant_fusion_types,
    "damage_variance" => $PokemonSystem.damage_variance,
    "shiny_trainer_pkmn" => $PokemonSystem.shiny_trainer_pkmn,
    "kuraygambleodds" => $PokemonSystem.kuraygambleodds,
    "shenanigans" => $PokemonSystem.shenanigans,
    "kuraystreamerdream" => $PokemonSystem.kuraystreamerdream,
    "autobattler" => $PokemonSystem.autobattler,
    "autobattleshortcut" => $PokemonSystem.autobattleshortcut,
    "kurayeggs_fusionpool" => $PokemonSystem.kurayeggs_fusionpool,
    "kurayeggs_instanthatch" => $PokemonSystem.kurayeggs_instanthatch,
    "kurayeggs_rarity" => $PokemonSystem.kurayeggs_rarity,
    "kurayeggs_fusionodds" => $PokemonSystem.kurayeggs_fusionodds,
    "autobattlershiny" => $PokemonSystem.autobattlershiny,
    "shinyodds" => $PokemonSystem.shinyodds,
    "unfusetraded" => $PokemonSystem.unfusetraded,
    "sb_maxing" => $PokemonSystem.sb_maxing,
    "sb_soullinked" => $PokemonSystem.sb_soullinked,
    "sb_randomizeteam" => $PokemonSystem.sb_randomizeteam,
    "sb_randomizeshare" => $PokemonSystem.sb_randomizeshare,
    "sb_randomizesize" => $PokemonSystem.sb_randomizesize,
    "sb_battlesize" => $PokemonSystem.sb_battlesize,
    "sb_select" => $PokemonSystem.sb_select,
    "sb_level" => $PokemonSystem.sb_level,
    "sb_playerfolder" => $PokemonSystem.sb_playerfolder,
    "debugfeature" => $PokemonSystem.debugfeature,
    "debug" => $PokemonSystem.debug,
    "is_in_battle" => $PokemonSystem.is_in_battle,
    "sb_stat_tracker" => $PokemonSystem.sb_stat_tracker,
    "player_wins" => $PokemonSystem.player_wins,
    "enemy_wins" => $PokemonSystem.enemy_wins,
    "sb_loopinput" => $PokemonSystem.sb_loopinput,
    "sb_loopbreaker" => $PokemonSystem.sb_loopbreaker,
    "importnodelete" => $PokemonSystem.importnodelete,
    "exportdelete" => $PokemonSystem.exportdelete,
    "savefolder" => $PokemonSystem.savefolder,
    "importlvl" => $PokemonSystem.importlvl,
    "importegg" => $PokemonSystem.importegg,
    "importdevolve" => $PokemonSystem.importdevolve,
    "nopngexport" => $PokemonSystem.nopngexport,
    "nopngimport" => $PokemonSystem.nopngimport,
    "raiser" => $PokemonSystem.raiser,
    "raiserb" => $PokemonSystem.raiserb,
    "legendarybreed" => $PokemonSystem.legendarybreed,
    "eventmoves" => $PokemonSystem.eventmoves,
    "shinyadvanced" => $PokemonSystem.shinyadvanced,
    "custom_bst" => $PokemonSystem.custom_bst,
    "custom_bst_sliders" => $PokemonSystem.custom_bst_sliders,
    "custom_bst_npc" => $PokemonSystem.custom_bst_npc,
    "custom_bst_sliders_npc" => $PokemonSystem.custom_bst_sliders_npc,
    "pokeradarplus" => $PokemonSystem.pokeradarplus,
    "walkingpoison" => $PokemonSystem.walkingpoison,
    "modernhail" => $PokemonSystem.modernhail,
    "frostbite" => $PokemonSystem.frostbite,
    "drowsy" => $PokemonSystem.drowsy,
    "bugbuff" => $PokemonSystem.bugbuff,
    "icebuff" => $PokemonSystem.icebuff,
    "ch_metronome" => $PokemonSystem.ch_metronome,
    "ch_letdownplayer" => $PokemonSystem.ch_letdownplayer,
    "ch_letdown" => $PokemonSystem.ch_letdown,
    "ch_berserker" => $PokemonSystem.ch_berserker,
    "dexspriteselect" => $PokemonSystem.dexspriteselect,
    "speedvalue" => $PokemonSystem.speedvalue,
    "speedtoggle" => $PokemonSystem.speedtoggle,
    "speedvaluedef" => $PokemonSystem.speedvaluedef,
    "speeduplimit" => $PokemonSystem.speeduplimit,
    "shiny_cache" => $PokemonSystem.shiny_cache,
    "skipcaughtprompt" => $PokemonSystem.skipcaughtprompt,
    "skipcaughtnickname" => $PokemonSystem.skipcaughtnickname,
    "levelcapbehavior" => $PokemonSystem.levelcapbehavior,
    "var_fusion_icon_style" => $game_variables[VAR_FUSION_ICON_STYLE],
    "var_default_battle_type" => $game_variables[VAR_DEFAULT_BATTLE_TYPE],
    "autosave_enabled_switch" => $game_switches[AUTOSAVE_ENABLED_SWITCH],
    "autosave_healing_var" => $game_switches[AUTOSAVE_HEALING_VAR],
    "autosave_catch_switch" => $game_switches[AUTOSAVE_CATCH_SWITCH],
    "autosave_win_switch" => $game_switches[AUTOSAVE_WIN_SWITCH],
    "autosave_steps_switch" => $game_switches[AUTOSAVE_STEPS_SWITCH],
    "noevsmode" => $PokemonSystem.noevsmode,
    "maxivsmode" => $PokemonSystem.maxivsmode,
    "evstrain" => $PokemonSystem.evstrain,
    "showlevel_nolevelmode" => $PokemonSystem.showlevel_nolevelmode,
    "rocketballsteal" => $PokemonSystem.rocketballsteal,
    "trainerexpboost" => $PokemonSystem.trainerexpboost,
    "gymrewardeggs" => $PokemonSystem.gymrewardeggs
  }
end

def options_load_json(jsonparse)
  json_ver = options_convertjsonver(jsonparse)
  $PokemonSystem.textspeed = jsonparse['textspeed']
  $PokemonSystem.battlescene = jsonparse['battlescene']
  $PokemonSystem.frame = jsonparse['frame']
  $PokemonSystem.textskin = jsonparse['textskin']
  # $PokemonSystem.screensize = jsonparse['screensize']
  $PokemonSystem.language = jsonparse['language']
  $PokemonSystem.runstyle = jsonparse['runstyle']
  $PokemonSystem.bgmvolume = jsonparse['bgmvolume']
  $PokemonSystem.sevolume = jsonparse['sevolume']
  $PokemonSystem.textinput = jsonparse['textinput']
  $PokemonSystem.quicksurf = jsonparse['quicksurf']
  $PokemonSystem.download_sprites = jsonparse['download_sprites']
  $PokemonSystem.on_mobile = jsonparse['on_mobile']
  $PokemonSystem.battlestyle = jsonparse['battlestyle']
  $PokemonSystem.battle_type = jsonparse['battle_type']
  $PokemonSystem.shiny_icons_kuray = jsonparse['shiny_icons_kuray']
  $PokemonSystem.kurayfusepreview = jsonparse['kurayfusepreview']
  $PokemonSystem.kuraynormalshiny = jsonparse['kuraynormalshiny']
  $PokemonSystem.kurayshinyanim = jsonparse['kurayshinyanim']
  $PokemonSystem.kurayfonts = jsonparse['kurayfonts']
  $PokemonSystem.kuraybigicons = jsonparse['kuraybigicons']
  $PokemonSystem.kurayindividcustomsprite = jsonparse['kurayindividcustomsprite']
  $PokemonSystem.typedisplay = jsonparse['typedisplay']
  $PokemonSystem.battlegui = jsonparse['battlegui']
  $PokemonSystem.darkmode = jsonparse['darkmode']
  $PokemonSystem.globalvalues = jsonparse['globalvalues']
  $PokemonSystem.quicksave = jsonparse['quicksave']
  $PokemonSystem.force_double_wild = jsonparse['force_double_wild']
  $PokemonSystem.improved_pokedex = jsonparse['improved_pokedex']
  $PokemonSystem.recover_consumables = jsonparse['recover_consumables']
  $PokemonSystem.expall_redist = jsonparse['expall_redist']
  $PokemonSystem.kuray_no_evo = jsonparse['kuray_no_evo']
  $PokemonSystem.shinyfusedye = jsonparse['shinyfusedye']
  $PokemonSystem.kuraylevelcap = jsonparse['kuraylevelcap']
  $PokemonSystem.kurayqol = jsonparse['kurayqol']
  $PokemonSystem.tutornet = jsonparse['tutornet']
  $PokemonSystem.self_fusion_boost = jsonparse['self_fusion_boost']
  $PokemonSystem.dominant_fusion_types = jsonparse['dominant_fusion_types']
  $PokemonSystem.damage_variance = jsonparse['damage_variance']
  $PokemonSystem.shiny_trainer_pkmn = jsonparse['shiny_trainer_pkmn']
  $PokemonSystem.kuraygambleodds = jsonparse['kuraygambleodds']
  $PokemonSystem.shenanigans = jsonparse['shenanigans']
  $PokemonSystem.kuraystreamerdream = jsonparse['kuraystreamerdream']
  $PokemonSystem.autobattler = jsonparse['autobattler']
  $PokemonSystem.shinyodds = jsonparse['shinyodds']
  $PokemonSystem.unfusetraded = jsonparse['unfusetraded']
  # $PokemonSystem.nomoneylost = jsonparse['nomoneylost']
  $PokemonSystem.sb_maxing = jsonparse['sb_maxing']
  $PokemonSystem.sb_soullinked = jsonparse['sb_soullinked']
  $PokemonSystem.sb_randomizeteam = jsonparse['sb_randomizeteam']
  $PokemonSystem.sb_randomizeshare = jsonparse['sb_randomizeshare']
  $PokemonSystem.sb_randomizesize = jsonparse['sb_randomizesize']
  $PokemonSystem.sb_battlesize = jsonparse['sb_battlesize']
  $PokemonSystem.sb_select = jsonparse['sb_select']
  $PokemonSystem.sb_level = jsonparse['sb_level']
  $PokemonSystem.sb_playerfolder = jsonparse['sb_playerfolder']
  $PokemonSystem.debugfeature = jsonparse['debugfeature']
  $PokemonSystem.debug = jsonparse['debug']
  $PokemonSystem.is_in_battle = jsonparse['is_in_battle']
  $PokemonSystem.sb_stat_tracker = jsonparse['sb_stat_tracker']
  $PokemonSystem.player_wins = jsonparse['player_wins']
  $PokemonSystem.enemy_wins = jsonparse['enemy_wins']
  $PokemonSystem.sb_loopinput = jsonparse['sb_loopinput']
  $PokemonSystem.sb_loopbreaker = jsonparse['sb_loopbreaker']
  $PokemonSystem.importnodelete = jsonparse['importnodelete']
  $PokemonSystem.exportdelete = jsonparse['exportdelete']
  $PokemonSystem.savefolder = jsonparse['savefolder']
  $PokemonSystem.importlvl = jsonparse['importlvl']
  $PokemonSystem.importdevolve = jsonparse['importdevolve']
  $PokemonSystem.nopngexport = jsonparse['nopngexport']
  $PokemonSystem.nopngimport = jsonparse['nopngimport']
  $PokemonSystem.raiser = jsonparse['raiser']
  $PokemonSystem.raiserb = jsonparse['raiserb']
  $PokemonSystem.legendarybreed = jsonparse['legendarybreed']
  $PokemonSystem.eventmoves = jsonparse['eventmoves']
  $PokemonSystem.shinyadvanced = jsonparse['shinyadvanced']
  $PokemonSystem.custom_bst = jsonparse['custom_bst']
  $PokemonSystem.custom_bst_sliders = jsonparse['custom_bst_sliders']
  $PokemonSystem.custom_bst_npc = jsonparse['custom_bst_npc']
  $PokemonSystem.custom_bst_sliders_npc = jsonparse['custom_bst_sliders_npc']
  $PokemonSystem.pokeradarplus = jsonparse['pokeradarplus']
  $PokemonSystem.walkingpoison = jsonparse['walkingpoison']
  $PokemonSystem.modernhail = jsonparse['modernhail']
  $PokemonSystem.frostbite = jsonparse['frostbite']
  $PokemonSystem.drowsy = jsonparse['drowsy']
  $PokemonSystem.bugbuff = jsonparse['bugbuff']
  $PokemonSystem.icebuff = jsonparse['icebuff']
  $PokemonSystem.ch_metronome = jsonparse['ch_metronome']
  $PokemonSystem.ch_letdownplayer = jsonparse['ch_letdownplayer']
  $PokemonSystem.ch_letdown = jsonparse['ch_letdown']
  $PokemonSystem.ch_berserker = jsonparse['ch_berserker']
  $PokemonSystem.dexspriteselect = jsonparse['dexspriteselect']
  $PokemonSystem.speedvalue = jsonparse['speedvalue']
  $PokemonSystem.speedtoggle = jsonparse['speedtoggle']
  $PokemonSystem.speedvaluedef = jsonparse['speedvaluedef']
  $PokemonSystem.speeduplimit = jsonparse['speeduplimit']
  $PokemonSystem.shiny_cache = jsonparse['shiny_cache']
  $PokemonSystem.skipcaughtprompt = jsonparse['skipcaughtprompt']
  $PokemonSystem.skipcaughtnickname = jsonparse['skipcaughtnickname']
  $PokemonSystem.levelcapbehavior = jsonparse['levelcapbehavior']
  $game_variables[VAR_FUSION_ICON_STYLE] = jsonparse['var_fusion_icon_style']
  $game_variables[VAR_DEFAULT_BATTLE_TYPE] = jsonparse['var_default_battle_type']
  $game_switches[AUTOSAVE_ENABLED_SWITCH] = jsonparse['autosave_enabled_switch']
  $game_switches[AUTOSAVE_HEALING_VAR] = jsonparse['autosave_healing_var']
  $game_switches[AUTOSAVE_CATCH_SWITCH] = jsonparse['autosave_catch_switch']
  $game_switches[AUTOSAVE_WIN_SWITCH] = jsonparse['autosave_win_switch']
  $game_switches[AUTOSAVE_STEPS_SWITCH] = jsonparse['autosave_steps_switch']
  if $game_system.playing_bgm != nil
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgm_resume(playingBGM)
  end
  if $game_system.playing_bgs != nil
    $game_system.playing_bgs.volume = $PokemonSystem.sevolume
    playingBGS = $game_system.getPlayingBGS
    $game_system.bgs_pause
    $game_system.bgs_resume(playingBGS)
  end
  MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed($PokemonSystem.textspeed))
  MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[$PokemonSystem.textskin])
  # pbSetResizeFactor($PokemonSystem.screensize)
  if $PokemonSystem.kurayfonts == 0
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
  elsif $PokemonSystem.kurayfonts == 1
    # MessageConfig::FONT_SIZE = 26
    # MessageConfig::NARROW_FONT_SIZE = 26
    MessageConfig.pbGetSystemFontSizeset(26)
    MessageConfig.pbGetSmallFontSizeset(25)
    MessageConfig.pbGetNarrowFontSizeset(26)
    MessageConfig.pbSetSystemFontName("Power Red and Green")
    MessageConfig.pbSetSmallFontName("Power Green Small")
    MessageConfig.pbSetNarrowFontName("Power Green Small")
  elsif $PokemonSystem.kurayfonts == 2
    MessageConfig.pbGetSystemFontSizeset(29)
    MessageConfig.pbGetSmallFontSizeset(25)
    MessageConfig.pbGetNarrowFontSizeset(29)
    MessageConfig.pbSetSystemFontName("Power Clear")
    MessageConfig.pbSetSmallFontName("Power Clear")
    MessageConfig.pbSetNarrowFontName("Power Clear")
  elsif $PokemonSystem.kurayfonts == 3
    MessageConfig.pbGetSystemFontSizeset(29)
    MessageConfig.pbGetSmallFontSizeset(25)
    MessageConfig.pbGetNarrowFontSizeset(29)
    MessageConfig.pbSetSystemFontName("Power Red and Blue")
    MessageConfig.pbSetSmallFontName("Power Red and Blue")
    MessageConfig.pbSetNarrowFontName("Power Red and Blue")
  end

  $PokemonSystem.noevsmode = 0
  $PokemonSystem.maxivsmode = 0
  $PokemonSystem.evstrain = 0
  $PokemonSystem.showlevel_nolevelmode = 0
  $PokemonSystem.rocketballsteal = 0
  $PokemonSystem.trainerexpboost = 50
  $PokemonSystem.gymrewardeggs = 3
  $PokemonSystem.autobattleshortcut = 0
  $PokemonSystem.autobattlershiny = 0
  $PokemonSystem.kurayeggs_fusionpool = 0
  $PokemonSystem.kurayeggs_instanthatch = 0
  $PokemonSystem.kurayeggs_rarity = 0
  $PokemonSystem.kurayeggs_fusionodds = 20
  if json_ver >= 2
    $PokemonSystem.noevsmode = jsonparse['noevsmode']
    $PokemonSystem.maxivsmode = jsonparse['maxivsmode']
    $PokemonSystem.showlevel_nolevelmode = jsonparse['showlevel_nolevelmode']
  end
  if json_ver >= 3
    $PokemonSystem.rocketballsteal = jsonparse['rocketballsteal']
  end
  if json_ver >= 4
    $PokemonSystem.trainerexpboost = jsonparse['trainerexpboost']
  end
  if json_ver >= 5
    $PokemonSystem.importegg = jsonparse['importegg']
  end
  if json_ver >= 6
    $PokemonSystem.evstrain = jsonparse['evstrain']
    $PokemonSystem.autobattleshortcut = jsonparse['autobattleshortcut']
    $PokemonSystem.autobattlershiny = jsonparse['autobattlershiny']
  end
  if json_ver >= 7
    $PokemonSystem.kurayeggs_fusionpool = jsonparse['kurayeggs_fusionpool']
    $PokemonSystem.kurayeggs_instanthatch = jsonparse['kurayeggs_instanthatch']
    $PokemonSystem.kurayeggs_rarity = jsonparse['kurayeggs_rarity']
    $PokemonSystem.kurayeggs_fusionodds = jsonparse['kurayeggs_fusionodds']
  end
  if json_ver >= 8
    $PokemonSystem.gymrewardeggs = jsonparse['gymrewardeggs']
  end

end

def options_to_json(*options)
  current = options_as_json(*options)
  return current
end

def options_convertjsonver(jsonparse)
  if jsonparse.key?('json_version')
    json_version = jsonparse['json_version']
    case json_version
    when '0.1'
      return 1
    when '0.2'
      return 2
    when '0.3'
      return 3
    when '0.4'
      return 4
    when '0.5'
      return 5
    when '0.6'
      return 6
    when '0.7'
      return 7
    when '0.8'
      return 8
    end
  else
    return 0
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
#
#===============================================================================
class ButtonsOption < Option
  include PropertyMixin
  attr_reader :name
  attr_reader :values

  def initialize(name, options, selectProc, description = "")
    super(description)
    @name = name
    @values = options
    @selectProc = selectProc
    @index = 0
  end

  def next(current)
    @index = current + 1
    @index = @values.length - 1 if @index > @values.length - 1
    # @selectProc.call(index)
    return @index
  end

  def prev(current)
    @index = current - 1
    @index = 0 if @index < 0
    # @selectProc.call(index)
    return @index
  end

  def activate
    @selectProc.call(@index)
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
    if @options[index].is_a?(EnumOption) || @options[index].is_a?(ButtonsOption)
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
        if @options[self.index].is_a?(ButtonOption) || @options[self.index].is_a?(ButtonsOption)
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
    @manually_changed_difficulty=false
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

    options << ButtonOption.new(_INTL("PIF Settings"),
                              proc {
                                @vanilla_menu = true
                                openVanilla()
                              }, "Customize PIF features"
    )
    options << ButtonOption.new(_INTL("KIF Settings"),
                              proc {
                                @kuray_menu = true
                                openKurayMenu()
                              }, "Customize modded features"
    )
    if $scene && $scene.is_a?(Scene_Map)
      options << ButtonOption.new(_INTL("Save & Load Options"),
                                proc {
                                  @saveload_menu = true
                                  openSLMenu()
                                }, "Save / Load options"
      )
    end
    return options
  end

  # def pbGetInGameOptions()
  #   options = []
  # end

  def openKurayMenu()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end

  def openVanilla()
    return if !@vanilla_menu
    pbFadeOutIn {
      scene = VanillaOptSc_1.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @vanilla_menu = false
  end

  def openSLMenu()
    return if !@saveload_menu
    pbFadeOutIn {
      scene = SLOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @saveload_menu = false
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
      _INTL("KIF Settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    options << ButtonOption.new(_INTL("Shinies"),
      proc {
        @kuray_menu = true
        openKuray1()
      }, "Customize shinies features"
    )
    options << ButtonOption.new(_INTL("Battles & Pokemons"),
      proc {
        @kuray_menu = true
        openKuray2()
      }, "Customize battles & pokemons features"
    )
    options << ButtonOption.new(_INTL("Graphics"),
      proc {
        @kuray_menu = true
        openKuray3()
      }, "Customize graphics features"
    )
    options << ButtonOption.new(_INTL("Self-Battle & Import"),
      proc {
        @kuray_menu = true
        openKuray5()
      }, "Self-battling & import features"
    )
    options << ButtonOption.new(_INTL("Challenges"),
      proc {
        @kuray_menu = true
        openKuray6()
      }, "Challenges"
    )
    options << ButtonOption.new(_INTL("Others"),
      proc {
        @kuray_menu = true
        openKuray4()
      }, "Customize others features"
    )
    options <<
    EnumOption.new(_INTL("Increment Slider by"), [_INTL("1"), _INTL("10"), _INTL("100"), _INTL("1000"), _INTL("10000")],
                   proc { $PokemonSystem.raiserb },
                   proc { |value|
                     if value == 0
                      $PokemonSystem.raiser = 1
                     elsif value == 1
                      $PokemonSystem.raiser = 10
                     elsif value == 2
                      $PokemonSystem.raiser = 100
                     elsif value == 3
                      $PokemonSystem.raiser = 1000
                     elsif value == 4
                      $PokemonSystem.raiser = 10000
                     end
                     $PokemonSystem.raiserb = value
                   }, "For shiny gamble and shiny odds, changes the increment rate of those sliders."
    )
    options <<
    EnumOption.new(_INTL("DEBUG"), [_INTL("Off"), _INTL("On")],
      proc { $PokemonSystem.debug },
      proc { |value| $PokemonSystem.debug = value },
      ["Doesn't force debug to be activated",
      "Force debug to be activated"]
    )

    # if $scene && $scene.is_a?(Scene_Map)
    #   options.concat(pbGetInGameOptions())
    # end
    return options
  end

  # def pbGetInGameOptions()
  #   options = []
  #   return options
  # end

  def openKuray1()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_1.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
  def openKuray2()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_2.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
  def openKuray3()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_3.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
  def openKuray4()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_4.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
  def openKuray5()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_5.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
  def openKuray6()
    return if !@kuray_menu
    pbFadeOutIn {
      scene = KurayOptSc_6.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @kuray_menu = false
  end
end

#===============================================================================
#
#===============================================================================
class SLOptionsScene < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(200, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(115, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Save & Load Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Save / Load options")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbLoadKO(index=1)
    # pbPlayCursorSE
    if File.exists?(RTP.getSaveFolder + "\\Options_" + index.to_s + ".kro")
      data = File.read(RTP.getSaveFolder + "\\Options_" + index.to_s + ".kro")
      options_load_json(eval(data))
      pbMessage(_INTL("Loaded options from Preset {1}.", $PokemonSystem.optionsnames[index]))
    else
      pbPlayBuzzerSE
      pbMessage(_INTL("No options found in {1}.", $PokemonSystem.optionsnames[index]))
    end
    return
  end

  def pbSaveKO(index=1)
    # pbPlayCursorSE
    File.open(RTP.getSaveFolder + "\\Options_" + index.to_s + ".kro", 'w') { |f| f.write(options_to_json()) }
    pbMessage(_INTL("Saved current options into Preset {1}.", $PokemonSystem.optionsnames[index]))
    return
  end

  def pbRenKO(index=1)
    $PokemonSystem.optionsnames[index] = pbEnterText("Enter name for Preset", 0, 12, $PokemonSystem.optionsnames[index])
    buildKO()
    refreshOption(index)
    return
  end

  def buildKO()
    kurayjson_save(RTP.getSaveFolder + "\\Options_Names.kro", $PokemonSystem.optionsnames)
  end
  
  def createButtonsOption(index)
    if !$KURAY_OPTIONSNAME_LOADED
      $KURAY_OPTIONSNAME_LOADED = true
      tempload = kurayjson_load(RTP.getSaveFolder + "\\Options_Names.kro")
      if !tempload.nil?
        if tempload.is_a?(Array) and tempload.length == 12
          $PokemonSystem.optionsnames = tempload
        end
      end
    end
    ButtonsOption.new(_INTL($PokemonSystem.optionsnames[index]), [_INTL("Load"), _INTL("Save"), _INTL("Name")],
      proc {
        |value|
        if value == 0
          pbLoadKO(index)
        elsif value == 1
          pbSaveKO(index)
        elsif value == 2
          pbRenKO(index)
        end
      }, ["Load " + $PokemonSystem.optionsnames[index], "Save " + $PokemonSystem.optionsnames[index], "Rename " + $PokemonSystem.optionsnames[index]]
    )
  end
  
  def refreshOption(index)
    @PokemonOptions[index] = createButtonsOption(index)
    @sprites["option"].refresh
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    12.times do |i|
      options << createButtonsOption(i)
    end
    return options
  end

  # def pbGetInGameOptions()
  #   options = []
  #   return options
  # end
end

#===============================================================================
# VANILLA
#===============================================================================
class VanillaOptSc_1 < PokemonOption_Scene
  def initialize
    @changedColor = false
    @autosave_menu = false
    @manually_changed_difficulty=false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(130, 130, 130)
    @sprites["option"].nameShadowColor = Color.new(75, 75, 75)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("PIF Settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize PIF features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    options << ButtonOption.new(_INTL("### GLOBAL ###"),
      proc {}
    )

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

    options << EnumOption.new(_INTL("Default Movement"), [_INTL("Walking"), _INTL("Running")],
                              proc { $PokemonSystem.runstyle },
                              proc { |value| $PokemonSystem.runstyle = value },
                              ["Default to walking when not holding the Run key",
                               "Default to running when not holding the Run key"]
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
      EnumOption.new(_INTL("Download data"), [_INTL("On"), _INTL("Off")],
                     proc { $PokemonSystem.download_sprites },
                     proc { |value|
                       $PokemonSystem.download_sprites = value
                     },
                     "Automatically download missing custom sprites and Pokédex entries from the internet"
      )
    #
    generated_entries_option_selected=$PokemonSystem.use_generated_dex_entries ? 1 : 0
    options << EnumOption.new(_INTL("Autogen dex entries"), [_INTL("Off"), _INTL("On")],
                              proc { generated_entries_option_selected },
                              proc { |value|
                                $PokemonSystem.use_generated_dex_entries = value == 1
                              },
                              [
                                "Fusions without a custom Pokédex entry display nothing.",
                                "Fusions without a custom Pokédex entry display an auto-generated placeholder."

                              ]
    )

    device_option_selected=$PokemonSystem.on_mobile ? 1 : 0
    options << EnumOption.new(_INTL("Device"), [_INTL("PC"), _INTL("Mobile")],
                              proc { device_option_selected },
                              proc { |value| $PokemonSystem.on_mobile = value == 1 },
                              ["The intended device on which to play the game.",
                                "Disables some options that aren't supported when playing on mobile."]
    )

    options << EnumOption.new(_INTL("Battle Effects"), [_INTL("On"), _INTL("Off")],
    proc { $PokemonSystem.battlescene },
    proc { |value| $PokemonSystem.battlescene = value },
    "Display move animations in battles"
    )

    options << NumberOption.new(_INTL("Speech Frame"), 1, Settings::SPEECH_WINDOWSKINS.length,
                                proc { $PokemonSystem.textskin },
                                proc { |value|
                                  $PokemonSystem.textskin = value
                                  MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
                                }
    )

    options << EnumOption.new(_INTL("Text Entry"), [_INTL("Cursor"), _INTL("Keyboard")],
                              proc { $PokemonSystem.textinput },
                              proc { |value| $PokemonSystem.textinput = value },
                              ["Enter text by selecting letters on the screen",
                               "Enter text by typing on the keyboard"]
    )

    options << EnumOption.new(_INTL("Screen Size"), [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
                              proc { [$PokemonSystem.screensize, 4].min },
                              proc { |value|
                                if $PokemonSystem.screensize != value
                                  $PokemonSystem.screensize = value
                                  pbSetResizeFactor($PokemonSystem.screensize)
                                  echoln $PokemonSystem.screensize
                                end
                              }, "Sets the size of the screen"
    )
    options << EnumOption.new(_INTL("Quick Field Moves"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksurf },
                              proc { |value| $PokemonSystem.quicksurf = value },
                              "Use Field Moves quicker"
    )

    options << EnumOption.new(_INTL("Dex Sprite Select"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.dexspriteselect },
                              proc { |value| $PokemonSystem.dexspriteselect = value },
                              ["Not used",
                              "Each new pokemon/fusion prompts a sprite selection"]
    )

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    end
    return options
  end

  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
      proc {}
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


    options << EnumOption.new(_INTL("Battle Style"), [_INTL("Switch"), _INTL("Set")],
                              proc { $PokemonSystem.battlestyle },
                              proc { |value| $PokemonSystem.battlestyle = value },
                              ["Prompts to switch Pokémon before the opponent sends out the next one",
                              "No prompt to switch Pokémon before the opponent sends the next one"]
    )
    if $game_switches
      options << EnumOption.new(_INTL("Difficulty"), [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
                                proc { $Trainer.selected_difficulty },
                                proc { |value|
                                  setDifficulty(value)
                                  @manually_changed_difficulty=true
                                }, ["All Pokémon in the team gain experience. Otherwise the same as Normal difficulty.",
                                    "The default experience. Levels are similar to the official games.",
                                    "Higher levels and smarter AI. All trainers have access to healing items."]
      )
    end

    # NumberOption.new(_INTL("Menu Frame"),1,Settings::MENU_WINDOWSKINS.length,
    #   proc { $PokemonSystem.frame },
    #   proc { |value|
    #     $PokemonSystem.frame = value
    #     MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    #   }
    # ),
    if $game_variables
      options << EnumOption.new(_INTL("Fusion Icons"), [_INTL("Combined"), _INTL("DNA")],
                                proc { $game_variables[VAR_FUSION_ICON_STYLE] },
                                proc { |value| $game_variables[VAR_FUSION_ICON_STYLE] = value },
                                ["Combines both Pokémon's party icons",
                                 "Uses the same party icon for all fusions"]
      )
    end

    return options
  end

  def pbEndScene
    echoln "Selected Difficulty: #{$Trainer.selected_difficulty}, lowest difficutly: #{$Trainer.lowest_difficulty}" if $Trainer
    if $Trainer && $Trainer.selected_difficulty < $Trainer.lowest_difficulty
      $Trainer.lowest_difficulty = $Trainer.selected_difficulty
      echoln "lowered difficulty (#{$Trainer.selected_difficulty})"
      if @manually_changed_difficulty
        pbMessage(_INTL("The savefile's lowest selected difficulty was changed to #{getDisplayDifficulty()}."))
        @manually_changed_difficulty = false
      end
    end
    super
  end
end

#===============================================================================
# SHINIES
#===============================================================================
class KurayOptSc_1 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(200, 200, 35)
    @sprites["option"].nameShadowColor = Color.new(115, 115, 20)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Shiny settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    options << ButtonOption.new(_INTL("### GLOBAL ###"),
    proc {}
    )


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
    options << EnumOption.new(_INTL("Shiny Cache"), [_INTL("Permanent"), _INTL("Per Session"), _INTL("Off")],
                      proc { $PokemonSystem.shiny_cache },
                      proc { |value| $PokemonSystem.shiny_cache = value },
                      ["Shinies are cached permanently",
                      "Shinies are cached per session",
                      "Shinies are not cached"]
    )

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    end
    return options
  end


  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
    proc {}
    )

    options << EnumOption.new(_INTL("Shiny Colors"), [_INTL("Simple"), _INTL("Normal"), _INTL("Advanced")],
                      proc { $PokemonSystem.shinyadvanced },
                      proc { |value| $PokemonSystem.shinyadvanced = value },
                      ["Shinies only have hue shifting (best performances)",
                      "Shinies have hue and channels shifting (mid performances)",
                      "Most powerful shiny system (low performances)"]
    )
    options << SliderOption.new(_INTL("Shiny Gamble Odds"), 0, 1000, $PokemonSystem.raiser,
                      proc { $PokemonSystem.kuraygambleodds },
                      proc { |value|
                        if $PokemonSystem.kuraygambleodds != value
                          $PokemonSystem.kuraygambleodds = value
                        end
                      }, "1 out of <x> | Choose the odds of Shinies from Gamble | 0 = Always"
    )
    options << SliderOption.new(_INTL("Wild Shiny Odds"), 0, 65536, $PokemonSystem.raiser,
                      proc { $PokemonSystem.shinyodds },
                      proc { |value|
                        if $PokemonSystem.shinyodds != value
                          $PokemonSystem.shinyodds = value
                          $PokemonSystem.shinyodds = 1 if $PokemonSystem.shinyodds < 1
                          # Settings::SHINY_POKEMON_CHANCE = $PokemonSystem.shinyodds
                        end
                      }, "<x> out of 65536 | Choose the Shiny Odds"
    )
    options << EnumOption.new(_INTL("Shiny Fuse Dye"), [_INTL("Off"), _INTL("On"), _INTL("Random")],
                      proc { $PokemonSystem.shinyfusedye },
                      proc { |value| $PokemonSystem.shinyfusedye = value },
                      ["Don't use the shiny fusion color dye system",
                      "Use the shiny fusion color dye system",
                      "Re-roll shiny color after each fusion/unfusion"]
    )

    options << EnumOption.new(_INTL("Shiny Trainer Pokemon"), [_INTL("Off"), _INTL("Ace"), _INTL("All"), _INTL("Disabled")],
                      proc { $PokemonSystem.shiny_trainer_pkmn },
                      proc { |value| $PokemonSystem.shiny_trainer_pkmn = value },
                      ["Trainer pokemon will have their normal shiny rates",
                      "Draws the opposing trainers ace pokemon as shiny",
                      "All trainers pokemon in their party will be shiny",
                      "Trainer pokemon will never be shiny"]
    )
    return options
  end
end

#===============================================================================
# BATTLE
#===============================================================================
class KurayOptSc_2 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(200, 35, 35)
    @sprites["option"].nameShadowColor = Color.new(115, 20, 20)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Battles & Pokemons settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    options << ButtonOption.new(_INTL("### GLOBAL ###"),
    proc {}
    )

    options << ButtonOption.new(_INTL("Powerful AI"),
    proc {}
    )

    options << EnumOption.new(_INTL("Ind. Custom Sprites"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.kurayindividcustomsprite },
                      proc { |value| $PokemonSystem.kurayindividcustomsprite = value },
                      ["Two of the same Pokemons can use different sprites (mod)",
                      "Two of the same Pokemons will use the same sprite (vanilla)"]
    )

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    end
    return options
  end


  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
    proc {}
    )

    options << EnumOption.new(_INTL("Wild Battles"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
                      proc { $PokemonSystem.force_double_wild },
                      proc { |value| $PokemonSystem.force_double_wild = value },
                      ["Wild battles always 1v1",
                      "Wild battles in 2v2 when possible",
                      "Wild battles in 3v3 'cause it's cool"]
    )
    options << EnumOption.new(_INTL("Level Cap"), [_INTL("Off"), _INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
                      proc { $PokemonSystem.kuraylevelcap },
                      proc { |value| 
                        $PokemonSystem.kuraylevelcap = value; 
                        #printGymLeaderLvls(); 
                      },
                      ["No Forced Level Cap",
                      "Easy Level Cap, for children",
                      "Normal Level Cap, for normal people",
                      "Hard Level Cap, for nerds"]
    )
    options << EnumOption.new(_INTL("Cap Behavior"), [_INTL("Smart"), _INTL("Lock"), _INTL("RC")],
                      proc { $PokemonSystem.levelcapbehavior },
                      proc { |value| $PokemonSystem.levelcapbehavior = value },
                      ["The Pokemons can still earn exp.",
                      "The Pokemon can't earn exp.",
                      "Earn rare candies instead of going over the cap."]
    )
    options << EnumOption.new(_INTL("Self-Fusion Stat Boost"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.self_fusion_boost },
                      proc { |value| $PokemonSystem.self_fusion_boost = value },
                      ["Stat boost for self-fusions is disabled.",
                      "Stat boost for self-fusions is enabled."]
    )
    options << EnumOption.new(_INTL("Fusion BaseStats"), [_INTL("Off"), _INTL("Head"), _INTL("Better")],
                      proc { $PokemonSystem.custom_bst },
                      proc { |value| $PokemonSystem.custom_bst = value },
                      ["Default fusion base stats.",
                      "Sliders determine what % of each stat comes from the head pokemon.",
                      "Sliders determine what % of each stat comes from the better base stat."]
    )
    options << SliderOption.new(_INTL("    HP (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:HP] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:HP] = value },
      "Percentage of base HP contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    HP (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:HP_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:HP_BODY] = value },
      "Percentage of base HP contributed by Body/Worse."
    )

    options << SliderOption.new(_INTL("    Attack (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:ATTACK] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:ATTACK] = value },
      "Percentage of base Attack contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    Attack (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:ATTACK_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:ATTACK_BODY] = value },
      "Percentage of base Attack contributed by Body/Worse."
    )

    options << SliderOption.new(_INTL("    Defense (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:DEFENSE] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:DEFENSE] = value },
      "Percentage of base Defense contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    Defense (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:DEFENSE_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:DEFENSE_BODY] = value },
      "Percentage of base Defense contributed by Body/Worse."
    )

    options << SliderOption.new(_INTL("    Sp.Atk (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPECIAL_ATTACK] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPECIAL_ATTACK] = value },
      "Percentage of base Special Attack contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    Sp.Atk (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPECIAL_ATTACK_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPECIAL_ATTACK_BODY] = value },
      "Percentage of base Special Attack contributed by Body/Worse."
    )

    options << SliderOption.new(_INTL("    Sp.Def (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPECIAL_DEFENSE] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPECIAL_DEFENSE] = value },
      "Percentage of base Special Defense contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    Sp.Def (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPECIAL_DEFENSE_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPECIAL_DEFENSE_BODY] = value },
      "Percentage of base Special Defense contributed by Body/Worse."
    )

    options << SliderOption.new(_INTL("    Speed (Head/Btr)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPEED] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPEED] = value },
      "Percentage of base Speed contributed by Head/Better."
    )
    options << SliderOption.new(_INTL("    Speed (Body/Wse)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders[:SPEED_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders[:SPEED_BODY] = value },
      "Percentage of base Speed contributed by Body/Worse."
    )
    options << EnumOption.new(_INTL("NPC Fusion BaseStats"), [_INTL("Off"), _INTL("Head"), _INTL("Better")],
    proc { $PokemonSystem.custom_bst_npc },
    proc { |value| $PokemonSystem.custom_bst_npc = value },
    ["Default NPC fusion base stats.",
    "Sliders determine what % of each stat comes from the head pokemon.",
    "Sliders determine what % of each stat comes from the better base stat."]
    )
    options << SliderOption.new(_INTL("    HP (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:HP] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:HP] = value },
      "NPC's base HP from Head/Better."
    )
    options << SliderOption.new(_INTL("    HP (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:HP_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:HP_BODY] = value },
      "NPC's base HP from Body/Worse."
    )

    options << SliderOption.new(_INTL("    Attack (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:ATTACK] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:ATTACK] = value },
      "NPC's base Attack from Head/Better."
    )
    options << SliderOption.new(_INTL("    Attack (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:ATTACK_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:ATTACK_BODY] = value },
      "NPC's base Attack from Body/Worse."
    )

    options << SliderOption.new(_INTL("    Defense (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:DEFENSE] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:DEFENSE] = value },
      "NPC's base Defense from Head/Better."
    )
    options << SliderOption.new(_INTL("    Defense (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:DEFENSE_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:DEFENSE_BODY] = value },
      "NPC's base Defense from Body/Worse."
    )

    options << SliderOption.new(_INTL("    Sp.Atk (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_ATTACK] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_ATTACK] = value },
      "NPC's base Sp.Atk from Head/Better."
    )
    options << SliderOption.new(_INTL("    Sp.Atk (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_ATTACK_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_ATTACK_BODY] = value },
      "NPC's base Sp.Atk from Body/Worse."
    )

    options << SliderOption.new(_INTL("    Sp.Def (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_DEFENSE] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_DEFENSE] = value },
      "NPC's base Sp.Def from Head/Better."
    )
    options << SliderOption.new(_INTL("    Sp.Def (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_DEFENSE_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPECIAL_DEFENSE_BODY] = value },
      "NPC's base Sp.Def from Body/Worse."
    )

    options << SliderOption.new(_INTL("    Speed (Head/Btr NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPEED] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPEED] = value },
      "NPC's base Speed from Head/Better."
    )
    options << SliderOption.new(_INTL("    Speed (Body/Wse NPC)"), 0, 120, 1,
      proc { $PokemonSystem.custom_bst_sliders_npc[:SPEED_BODY] },
      proc { |value| $PokemonSystem.custom_bst_sliders_npc[:SPEED_BODY] = value },
      "NPC's base Speed from Body/Worse."
    )
    options << EnumOption.new(_INTL("Dominant Fusion Types"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.dominant_fusion_types },
                      proc { |value| $PokemonSystem.dominant_fusion_types = value },
                      ["Brings back the dominant/inverse fusion types from pre-v6.",
                      "Brings back the dominant/inverse fusion types from pre-v6."]
    )

    options << EnumOption.new(_INTL("Improved Pokedex"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.improved_pokedex },
                      proc { |value| $PokemonSystem.improved_pokedex = value },
                      ["Don't use the Improved Pokedex",
                      "Registers a fusions base Pokemon to the Pokedex when catching/evolving"]
    )

    options << EnumOption.new(_INTL("Enable EvoLock"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kuray_no_evo },
                      proc { |value| $PokemonSystem.kuray_no_evo = value },
                      ["Can't EvoLock a Pokemon without holding everstone",
                      "Can EvoLock Pokemons in the PC"]
    )
    options << EnumOption.new(_INTL("Unfuse Traded"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.unfusetraded },
                      proc { |value| $PokemonSystem.unfusetraded = value },
                      ["You cannot unfuse traded Pokemons.",
                      "You can unfuse traded Pokemons."]
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
    options << EnumOption.new(_INTL("Auto-Battle"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.autobattler },
                      proc { |value| $PokemonSystem.autobattler = value },
                      ["You fight your own battles",
                      "Allows Trapstarr to take control of your pokemon"]
    )
    options << EnumOption.new(_INTL("Auto-Battle Shortcut"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.autobattleshortcut },
                      proc { |value| $PokemonSystem.autobattleshortcut = value },
                      ["Allows to toggle Auto-Battle in battles with the X key.",
                      "Disable the Auto-Battle toggle shortcut."]
    )
    options << EnumOption.new(_INTL("Auto-Battle Shiny Stop"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.autobattlershiny },
                      proc { |value| $PokemonSystem.autobattlershiny = value },
                      ["Do NOT stop Auto-Battle if a shiny enemy is detected.",
                      "Automatically stops Auto-Battle if a shiny enemy is detected."]
    )

    options << EnumOption.new(_INTL("Damage Variance"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.damage_variance },
                      proc { |value| $PokemonSystem.damage_variance = value },
                      ["Damage Variance is disabled.",
                      "Damage Variance is enabled."]
    )
    options << EnumOption.new(_INTL("Head Legendary Breeding"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.legendarybreed },
                      proc { |value| $PokemonSystem.legendarybreed = value },
                      ["Legendary Head cannot breed (like new PIF).",
                      "Legendary Head can breed (like old PIF)."]
    )
    options << EnumOption.new(_INTL("Event Moves"), [_INTL("Off"), _INTL("On")],
      proc { $PokemonSystem.eventmoves },
      proc { |value| $PokemonSystem.eventmoves = value },
      "Event Moves are available at the Battle Factory Egg Move Tutor."
    )
    # Made by Blue Woppo
    options << EnumOption.new(_INTL("Modern Hail"), [_INTL("Off"), _INTL("Hail"), _INTL("Snow")],
    proc { $PokemonSystem.modernhail },
    proc { |value| $PokemonSystem.modernhail = value },
    ["Vanilla hail.",
    "Ice types receive a defensive boost during hail.",
    "Hail becomes Snow, behaves like Gen 9+."]
    )
    options << EnumOption.new(_INTL("Frostbite"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.frostbite },
    proc { |value| $PokemonSystem.frostbite = value },
    ["Vanilla Frozen Status.",
    "Frostbite Status from Gen 9+ replaces Frozen Status."]
    )
    options << EnumOption.new(_INTL("Drowsy"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.drowsy },
    proc { |value| $PokemonSystem.drowsy = value },
    ["Vanilla Sleep Status.",
    "Drowsy Status from Gen 9+ replaces Sleep Status."]
    )
    options << EnumOption.new(_INTL("Bug Type Buffs"), [_INTL("Off"), _INTL("Defensive"), _INTL("+ Offensive")],
    proc { $PokemonSystem.bugbuff },
    proc { |value| $PokemonSystem.bugbuff = value },
    ["Vanilla Bug Types.",
    "Bug Types resist Fairy, Psychic, and Dark.",
    "Fairy Types are weak to Bug Type Moves."]
    )
    options << EnumOption.new(_INTL("Ice Type Buffs"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.icebuff },
    proc { |value| $PokemonSystem.icebuff = value },
    ["Vanilla Ice Types.",
    "Ice Types now resist Water and Flying."]
    )
    # End of made By Blue Woppo

    options << EnumOption.new(_INTL("Skip Caught Prompt"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.skipcaughtprompt },
    proc { |value| $PokemonSystem.skipcaughtprompt = value },
    ["If your party is full, allows you to put the caught pokemon on your party.",
    "If your party is full, always send the caught pokemon to the PC."]
    )
    options << EnumOption.new(_INTL("Skip Caught Nickname"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.skipcaughtnickname },
    proc { |value| $PokemonSystem.skipcaughtnickname = value },
    ["Prompts you to nickname newly caught pokemon.",
    "Never prompts to nickname newly caught pokemon."]
    )
    options << EnumOption.new(_INTL("Show Lv. in BSM"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.showlevel_nolevelmode },
    proc { |value| $PokemonSystem.showlevel_nolevelmode = value },
    ["Base Stats Mode hides the level of Pokemons in battle.",
    "Base Stats Mode shows the level of Pokemons (level don't reflect stats!)."]
    )
    options << EnumOption.new(_INTL("No-EVs Mode"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.noevsmode },
    proc { |value| $PokemonSystem.noevsmode = value },
    ["Pokemon EVs exist.",
    "Pokemon EVs are disabled."]
    )
    options << EnumOption.new(_INTL("Max IVs Mode"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.maxivsmode },
    proc { |value| $PokemonSystem.maxivsmode = value },
    ["Disabled.",
    "Pokemon IVs are always at max."]
    )
    options << EnumOption.new(_INTL("EVs Train Mode"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.evstrain },
    proc { |value| $PokemonSystem.evstrain = value },
    ["EVs yielding works as expected.",
    "Enemies do not yield EVs (except yielding from held Power-items)."]
    )
    options << EnumOption.new(_INTL("Rocket Mode"), [_INTL("Off"), _INTL("On"), _INTL("All Balls")],
    proc { $PokemonSystem.rocketballsteal },
    proc { |value| $PokemonSystem.rocketballsteal = value },
    ["Rocket Balls don't steal Pokemons.",
    "Rocket Balls can steal Pokemons.",
    "Every Balls can steal Pokemons."]
    )
    options << SliderOption.new(_INTL("Trainer Exp. Boost"), 0, 1000, 50,
                      proc { $PokemonSystem.trainerexpboost },
                      proc { |value| $PokemonSystem.trainerexpboost = value },
                      "+x% | Boosts exp. gained in trainer battles (Default: +50%)"
    )
    options << EnumOption.new(_INTL("K-Eggs Fusion Pool"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.kurayeggs_fusionpool },
    proc { |value| $PokemonSystem.kurayeggs_fusionpool = value },
    ["In case of fusion, the other Pokemon is random.",
    "In case of fusion, the other Pokemon must be from k-egg's pool as well."]
    )
    options << EnumOption.new(_INTL("K-Eggs Rarity"), [_INTL("On"), _INTL("Off")],
    proc { $PokemonSystem.kurayeggs_rarity },
    proc { |value| $PokemonSystem.kurayeggs_rarity = value },
    ["Pokemons' rarity in k-eggs depend of their catch rate.",
    "All Pokemons have the same odds to come from the k-eggs."]
    )
    options << SliderOption.new(_INTL("K-Eggs Fusion Odds"), 0, 100, 1,
                      proc { $PokemonSystem.kurayeggs_fusionodds },
                      proc { |value| $PokemonSystem.kurayeggs_fusionodds = value },
                      "x% | Probability that a fusion hatches from Kuray Eggs (Default: 20%)"
    )
    options << EnumOption.new(_INTL("K-Eggs Usage"), [_INTL("Pokemon"), _INTL("Egg")],
    proc { $PokemonSystem.kurayeggs_instanthatch },
    proc { |value| $PokemonSystem.kurayeggs_instanthatch = value },
    ["When Kuray Egg item used, spawns a Pokemon.",
    "When Kuray Egg item used, spawns an Egg that contains a Pokemon."]
    )
    options << SliderOption.new(_INTL("K-Eggs Rewards"), 0, 10, 1,
                      proc { $PokemonSystem.gymrewardeggs },
                      proc { |value| $PokemonSystem.gymrewardeggs = value },
                      "Numbers of obtained K-Eggs upon unlocking each one through progression (Default: 3)"
    )

    return options
  end
end


#===============================================================================
# GRAPHICS
#===============================================================================
class KurayOptSc_3 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 200, 35)
    @sprites["option"].nameShadowColor = Color.new(20, 115, 20)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Graphics settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    options << ButtonOption.new(_INTL("### GLOBAL ###"),
    proc {}
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

    options << EnumOption.new(_INTL("Type Display"), [_INTL("Off"), _INTL("Ico"), _INTL("TCG"), _INTL("Sqr"), _INTL("FGM"), _INTL("Txt")],
                      proc { $PokemonSystem.typedisplay },
                      proc { |value| $PokemonSystem.typedisplay = value },
                      ["Don't draw the type indicator in battle",
                      "Draws handmade custom type icons in battle | By Lolpy1",
                      "Draws TCG themed type icons in battle",
                      "Draws the square type icons in battle | Triple Fusion by Lolpy1",
                      "Draws handmade custom type icons in battle | By FairyGodmother",
                      "Draws the text type display in battle"]
    )

    options << EnumOption.new(_INTL("Swap BattleGUI"), [_INTL("Off"), _INTL("Type 1"), _INTL("Type 2")],
                      proc { $PokemonSystem.battlegui },
                      proc { |value| $PokemonSystem.battlegui = value },
                      ["This feature is a work in progress, more to come soon",
                      "Swaps the HP/Exp bar to v1 | created by Mirasein",
                      "Swaps the HP/Exp bar to v2 | created by Mirasein"]
   )

    options << EnumOption.new(_INTL("Dark Mode"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.darkmode },
                      proc { |value| $PokemonSystem.darkmode = value },
                      ["Default UI",
                      "Swaps the message graphics during battle"]
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

    return options
  end
end

#===============================================================================
# CHALLENGES
#===============================================================================
class KurayOptSc_6 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 35, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 20, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Challenges settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    else
      options << ButtonOption.new(_INTL("### EMPTY ###"),
      proc {}
      )
    end
    return options
  end

  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
    proc {}
    )

    options << EnumOption.new(_INTL("Metronome Madness"), [_INTL("Off"), _INTL("Normal"), _INTL("Hard")],
                      proc { $PokemonSystem.ch_metronome },
                      proc { |value| $PokemonSystem.ch_metronome = value },
                      ["Metronome disabled.",
                      "All Pokemons are forced to use Metronome. [Normal]",
                      "Only your Pokemons are forced to use Metronome. [Hard]"]
    )
    options << EnumOption.new(_INTL("Letdown"), [_INTL("Off"), _INTL("1%"), _INTL("5%"), _INTL("10%"), _INTL("25%"), _INTL("50%")],
                      proc { $PokemonSystem.ch_letdown },
                      proc { |value| $PokemonSystem.ch_letdown = value },
                      ["Letdown disabled.",
                        "1% chance that Pokemons use Splash instead.",
                        "5% chance that Pokemons use Splash instead.",
                        "10% chance that Pokemons use Splash instead.",
                        "25% chance that Pokemons use Splash instead.",
                        "50% chance that Pokemons use Splash instead."]
    )
    options << EnumOption.new(_INTL("Letdown Player Only"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.ch_letdownplayer },
                      proc { |value| $PokemonSystem.ch_letdownplayer = value },
                      ["Letdown doesn't only affect the player.",
                        "Letdown only affects the player."]
    )
    options << EnumOption.new(_INTL("Berserker"), [_INTL("Off"), _INTL("Easy"), _INTL("Normal"), _INTL("Hard"), _INTL("Chaos")],
                      proc { $PokemonSystem.ch_berserker },
                      proc { |value| $PokemonSystem.ch_berserker = value },
                      ["Berserker disabled.",
                      "Opponent stats raise by 1 every 3 turns. [Easy]",
                      "Opponent stats raise by 1 every 2 turns. [Normal]",
                      "Opponent stats raise by 1 every turn. [Hard]",
                      "Opponent stats raise by 2 every turn. [Hardcore]"]
    )

    return options
  end
end

#===============================================================================
# OTHERS
#===============================================================================
class KurayOptSc_4 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 200, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 115, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Others settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    options << ButtonOption.new(_INTL("### GLOBAL ###"),
    proc {}
    )

    # options << EnumOption.new(_INTL("Global Options"), [_INTL("Off"), _INTL("On")],
    #                   proc { $PokemonSystem.globalvalues },
    #                   proc { |value| $PokemonSystem.globalvalues = value },
    #                   ["Some options stays per-save file",
    #                   "All options are applied globally"]
    # )
    options << EnumOption.new(_INTL("Debug Exclusive"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.debugfeature },
                      proc { |value| $PokemonSystem.debugfeature = value },
                      ["Some debug features are available without debug (magic boots)",
                      "All debug features requires debug (magic boots)"]
    )
    options << EnumOption.new(_INTL("Quicksave with S"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksave },
                              proc { |value| $PokemonSystem.quicksave = value },
                              "Quicksave with S"
    )
    options << EnumOption.new(_INTL("Speed-up Type"), [_INTL("Toggle"), _INTL("Hold")],
                              proc { $PokemonSystem.speedtoggle },
                              proc { |value|
                                $PokemonSystem.speedtoggle = value
                              },
                              ["Button toggles the speed-up",
                                "Hold the button to speed-up the game"]
    )

    options << SliderOption.new(_INTL("Default Speed (Hold)"), 1, 10, 1,
                              proc { $PokemonSystem.speedvaluedef },
                              proc { |value|
                                $PokemonSystem.speedvaluedef = value
                              }, "Sets the default speed when not holding the speed-up button (Default: 1x)"
    )

    options << SliderOption.new(_INTL("Speed-up Speed (Hold)"), 1, 10, 1,
                              proc { $PokemonSystem.speedvalue },
                              proc { |value|
                                $PokemonSystem.speedvalue = value
                              }, "Sets by how much to speed-up the game when holding the speed-up button (Default: 2x)"
    )

    options << SliderOption.new(_INTL("Speed-up Limit (Toggle)"), 1, 10, 1,
                              proc { $PokemonSystem.speeduplimit },
                              proc { |value|
                                $PokemonSystem.speeduplimit = value
                              }, "Sets the limit of speed-up when using toggle mode (Default: 5x)"
    )

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    end
    return options
  end


  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
    proc {}
    )

    options << EnumOption.new(_INTL("Kuray QoL"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kurayqol },
                      proc { |value| $PokemonSystem.kurayqol = value },
                      ["Kuray's QoL features OFF",
                      "Kuray's QoL features ON"]
    )
    options << EnumOption.new(_INTL("Tutor.net"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.tutornet },
                      proc { |value| $PokemonSystem.tutornet = value },
                      ["Save Tutors/TMs in a handy list: OFF",
                      "Save Tutors/TMs in a handy list: ON"]
    )
    options << EnumOption.new(_INTL("Kuray's Shenanigans"), [_INTL("On"), _INTL("Off")],
                      proc { $PokemonSystem.shenanigans },
                      proc { |value| $PokemonSystem.shenanigans = value },
                      ["You're playing with Shenanigans! (Easter Eggs)",
                      "You're playing normally! (No Easter Eggs)"]
    )
    # options << EnumOption.new(_INTL("Streamer's Dream"), [_INTL("Off"), _INTL("On"), _INTL("Dream more!")],
    options << EnumOption.new(_INTL("Streamer's Dream"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.kuraystreamerdream },
                      proc { |value|
                        if value == 0
                          $PokemonSystem.kuraystreamerdream = 0
                        elsif value == 1
                          $PokemonSystem.kuraystreamerdream = 1
                        # elsif value == 2
                          # $PokemonSystem.kuraystreamerdream = 2
                          # $game_switches[252]=true
                          # $game_variables[VAR_PREMIUM_WONDERTRADE_LEFT] = 999999
                          # $game_variables[VAR_STANDARD_WONDERTRADE_LEFT] = 999999
                        end
                        $PokemonSystem.kuraystreamerdream = value
                      },
                      ["No Rare Candies/Master Balls/etc free in Kuray Shop",
                      "Rare Candies/Master Balls and more are free in Kuray Shop",
                      "Also Unlimited WonderTrades (need 1 badge)"]
    )
    #Made by Blue Wuppo
    options << EnumOption.new(_INTL("Overworld Poison"), [_INTL("Off"), _INTL("On"), _INTL("On+Healing")],
                      proc { $PokemonSystem.walkingpoison },
                      proc { |value| $PokemonSystem.walkingpoison = value },
                      ["Everyone takes dmg on overworld poison.",
                      "Some abilities immune to dmg on overworld poison.",
                      "Some abilities heal instead of taking dmg on overworld poison."]
    )
    #End of By Blue Wuppo
    options << EnumOption.new(_INTL("PokeRadar+"), [_INTL("Off"), _INTL("On")],
      proc { $PokemonSystem.pokeradarplus },
      proc { |value| $PokemonSystem.pokeradarplus = value },
        "Adds a chain count display. Chains won't randomly drop."
    )

    return options
  end
end

#===============================================================================
# SELF BATTLE
#===============================================================================
class KurayOptSc_5 < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(200, 35, 200)
    @sprites["option"].nameShadowColor = Color.new(115, 20, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Self-Battle & Import settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize modded features")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []

    if $scene && $scene.is_a?(Scene_Map)
      options.concat(pbGetInGameOptions())
    else
      options << ButtonOption.new(_INTL("### EMPTY ###"),
      proc {}
      )
    end
    return options
  end


  def pbGetInGameOptions()
    options = []
    options << ButtonOption.new(_INTL("### PER-SAVE FILE ###"),
    proc {}
    )

    options << EnumOption.new(_INTL("Battle Size"), [_INTL("1"), _INTL("2"), _INTL("3"), _INTL("4"), _INTL("5"), _INTL("6")],
                      proc { $PokemonSystem.sb_battlesize },
                      proc { |value| $PokemonSystem.sb_battlesize = value },
                      ["1 enemy Pokemon",
                        "2 enemy Pokemons",
                        "3 enemy Pokemons",
                        "4 enemy Pokemons",
                        "5 enemy Pokemons",
                        "6 enemy Pokemons"]
    )
    options << EnumOption.new(_INTL("Player Size"), [_INTL("1"), _INTL("2"), _INTL("3"), _INTL("4"), _INTL("5"), _INTL("6")],
                      proc { $PokemonSystem.sb_randomizesize },
                      proc { |value| $PokemonSystem.sb_randomizesize = value },
                      ["1 player Pokemon",
                        "2 player Pokemons",
                        "3 player Pokemons",
                        "4 player Pokemons",
                        "5 player Pokemons",
                        "6 player Pokemons"]
    )
    options << EnumOption.new(_INTL("Level"), [_INTL("Default"), _INTL("1"), _INTL("5"), _INTL("10"), _INTL("50"), _INTL("70"), _INTL("100")],
                      proc { $PokemonSystem.sb_level },
                      proc { |value| $PokemonSystem.sb_level = value },
                      ["Pokemons keep their original level",
                        "Pokemons are level 1",
                        "Pokemons are level 5",
                        "Pokemons are level 10",
                        "Pokemons are level 50",
                        "Pokemons are level 70",
                        "Pokemons are level 100"]
    )
    options << EnumOption.new(_INTL("Randomize Team"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.sb_randomizeteam },
                      proc { |value| $PokemonSystem.sb_randomizeteam = value },
                      ["Doesn't randomize your player team",
                      "Randomize your player team as well"]
    )
    options << EnumOption.new(_INTL("Randomize Share"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.sb_randomizeshare },
                      proc { |value| $PokemonSystem.sb_randomizeshare = value },
                      ["Doesn't allow randomize to make you share the same Pokemons",
                      "Randomize might give you and the enemy the same Pokemons"]
    )
    options << EnumOption.new(_INTL("Players Folder"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.sb_playerfolder },
                      proc { |value| $PokemonSystem.sb_playerfolder = value },
                      ["Does not use the Players folder to randomize the player's team.",
                      "Uses the Players Folder to randomize the player's team."]
    )
    options << EnumOption.new(_INTL("Team Select"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.sb_select },
                      proc { |value| $PokemonSystem.sb_select = value },
                      ["Doesn't prompt you to select your team",
                      "Let you select your team"]
    )
    options << EnumOption.new(_INTL("Limitless Select"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.sb_maxing },
                      proc { |value| $PokemonSystem.sb_maxing = value },
                      ["You may only use the same party size",
                      "You may perform 6v1, etc (bypass the party size)"]
    )
    # options << EnumOption.new(_INTL("Soul-Linked"), [_INTL("Off"), _INTL("On")],
    #                   proc { $PokemonSystem.sb_soullinked },
    #                   proc { |value| $PokemonSystem.sb_soullinked = value },
    #                   ["Pokemons are all individual/indepedent copies",
    #                   "The same Pokemons between your team are linked"]
    # )
    options << EnumOption.new(_INTL("Stat Tracker"), [_INTL("Off"), _INTL("On")],
    proc { $PokemonSystem.sb_stat_tracker },
    proc { |value| $PokemonSystem.sb_stat_tracker = value },
    ["Does not display the stat tracker during AutoBattle + Battle Loop",
    "Shows stats such as Win/Loss tracker for Self-battle/Auto-battle"]
    )
    options << EnumOption.new(_INTL("Import Level"), [_INTL("Default"), _INTL("1"), _INTL("5"), _INTL("50"), _INTL("100")],
                      proc { $PokemonSystem.importlvl },
                      proc { |value| $PokemonSystem.importlvl = value },
                      ["Imported Pokemons keep their original level.",
                      "Imported Pokemons are set to level 1.",
                      "Imported Pokemons are set to level 5.",
                      "Imported Pokemons are set to level 50.",
                      "Imported Pokemons are set to level 100."]
    )
    options << EnumOption.new(_INTL("Import De-Evolve"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.importdevolve },
                      proc { |value| $PokemonSystem.importdevolve = value },
                      ["Imported Pokemons remain intact.",
                      "Imported Pokemons are de-evolved into babies."]
    )
    options << EnumOption.new(_INTL("Import as Egg"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.importegg },
                      proc { |value| $PokemonSystem.importegg = value },
                      ["Imported Pokemons remain intact.",
                      "Imported Pokemons are turned into eggs."]
    )
    options << EnumOption.new(_INTL("Import Without Deletion"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.importnodelete },
                      proc { |value| $PokemonSystem.importnodelete = value },
                      ["Imported Pokemons will have their .json deleted.",
                      "Imported Pokemons will remain as .json in Import folder."]
    )
    options << EnumOption.new(_INTL("Delete on Export"), [_INTL("Off"), _INTL("On")],
                      proc { $PokemonSystem.exportdelete },
                      proc { |value| $PokemonSystem.exportdelete = value },
                      ["Exported Pokemons will not be deleted.",
                      "Exported Pokemons will be deleted."]
    )
    options << EnumOption.new(_INTL("Export Sprite on Export"), [_INTL("On"), _INTL("Off"), _INTL("Shiny")],
                      proc { $PokemonSystem.nopngexport },
                      proc { |value| $PokemonSystem.nopngexport = value },
                      ["The .png of the Pokemon will also be exported.",
                      "The .png (appearence) of the Pokemon will not be exported.",
                      ".png exported as shiny, shiny appearence but pokemon un-shinified."]
    )
    options << EnumOption.new(_INTL("Import Sprite on Import"), [_INTL("On"), _INTL("Read-Only"), _INTL("Off")],
                      proc { $PokemonSystem.nopngimport },
                      proc { |value| $PokemonSystem.nopngimport = value },
                      ["The .png of the Pokemon will also be imported.",
                      "The .png of the Pokemon will be read from the folder but not imported.",
                      "The .png (appearence) of the Pokemon will not be imported."]
    )
    # options << EnumOption.new(_INTL("Use 'Saves' folder"), [_INTL("Off"), _INTL("On")],
    #                   proc { $PokemonSystem.savefolder },
    #                   proc { |value| $PokemonSystem.savefolder = value },
    #                   ["Battlers/Players/Import use their respective folders.",
    #                   "Battlers/Players/Import etc all use the 'Saves' folder."]
    # )
    return options
  end
end