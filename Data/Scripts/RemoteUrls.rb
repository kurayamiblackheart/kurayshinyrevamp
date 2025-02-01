
module Settings
  # SHINY_POKEMON_CHANCE = 16 #no? what's the point?
  DISCORD_URL = "https://discord.gg/kuray-hub-1121345297352753243"
  PIF_DISCORD_URL = "https://discord.com/invite/infinitefusion"
  WIKI_URL = "https://infinitefusion.fandom.com/"
  STARTUP_MESSAGES = ""

  CREDITS_FILE_URL = "https://infinitefusion.net/Sprite Credits.csv"
  # SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/CUSTOM_SPRITES"
  # VERSION_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/VERSION"
  SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/CUSTOM_SPRITES"
  BASE_SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/BASE_SPRITES"

  VERSION_FILE_URL = "https://raw.githubusercontent.com/kurayamiblackheart/kurayshinyrevamp/release/Data/VERSION"
  CUSTOM_DEX_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/dex.json"

  # CUSTOM SPRITES
  AUTOGEN_SPRITES_REPO_URL = ""
  
  CUSTOM_SPRITES_REPO_URL = "https://bitbucket.org/infinitefusionsprites/customsprites/raw/main/CustomBattlers/"
  CUSTOM_SPRITES_NEW_URL = "https://infinitefusion.net/CustomBattlers/"

  BASE_POKEMON_SPRITES_REPO_URL = ""
  
  BASE_POKEMON_ALT_SPRITES_REPO_URL = "https://bitbucket.org/infinitefusionsprites/customsprites/raw/main/Other/BaseSprites/"
  BASE_POKEMON_ALT_SPRITES_NEW_URL = "https://infinitefusion.net/Other/BaseSprites/"

  # UNUSED IN KIF
  # BASE_POKEMON_SPRITESHEET_URL = "https://infinitefusion.net/spritesheets/spritesheets_base/"
  # CUSTOM_FUSIONS_SPRITESHEET_URL = "https://infinitefusion.net/spritesheets/spritesheets_custom/"
  
  # BASE_POKEMON_SPRITESHEET_RESIZED_URL = "https://infinitefusion.net/spritesheets_resized/spritesheets_base/"
  # CUSTOM_FUSIONS_SPRITESHEET_RESIZED_URL = "https://infinitefusion.net/spritesheets_resized/spritesheets_custom/"

  
  CUSTOMSPRITES_RATE_MAX_NB_REQUESTS = 6  #Nb. requests allowed in each time window
  CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW = 15    # In seconds


  #POKEDEX ENTRIES

  AI_ENTRIES_URL = "https://infinitefusion.net/dex/"
  AI_ENTRIES_RATE_MAX_NB_REQUESTS = 10  #Nb. requests allowed in each time window
  AI_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  AI_ENTRIES_RATE_LOG_FILE = 'Data/pokedex/rate_limit.log'  # Path to the log file

  # AUTOGEN_SPRITES_REPO_URL = "https://gitlab.com/infinitefusion2/autogen-fusion-sprites/-/raw/main/Battlers/"
  # CUSTOM_SPRITES_REPO_URL = "https://gitlab.com/infinitefusion2/customSprites/-/raw/master/CustomBattlers/"
  # BASE_POKEMON_SPRITES_REPO_URL = "https://gitlab.com/infinitefusion2/autogen-fusion-sprites/-/raw/main/Battlers/"
  # BASE_POKEMON_ALT_SPRITES_REPO_URL = "https://gitlab.com/infinitefusion2/customSprites/-/raw/main/Other/BaseSprites/"

  #Spritepack
  NEWEST_SPRITEPACK_MONTH = 12
  NEWEST_SPRITEPACK_YEAR = 2024
  
end
