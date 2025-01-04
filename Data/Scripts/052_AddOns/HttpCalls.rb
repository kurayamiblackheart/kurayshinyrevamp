# module Settings

#   def performKurayJsonSettingsOverrides()
#     # Read the .json file and override the settings
#     if File.exists?(GAME_REMOTE_SETTINGS_FILE_PATH)
#       data = File.read(GAME_REMOTE_SETTINGS_FILE_PATH)
#       settings_load_json(eval(data))
#     end
#   end

#   def settings_load_json(jsonparse)
#     json_ver = jsonparse["JSON_VERSION"]
#     CREDITS_FILE_URL = jsonparse["CREDITS_FILE_URL"]
#     SPRITES_FILE_URL = jsonparse["SPRITES_FILE_URL"]
#     VERSION_FILE_URL = jsonparse["VERSION_FILE_URL"]
#     CUSTOM_DEX_FILE_URL = jsonparse["CUSTOM_DEX_FILE_URL"]
#     AUTOGEN_SPRITES_REPO_URL = jsonparse["AUTOGEN_SPRITES_REPO_URL"]
#     CUSTOM_SPRITES_REPO_URL = jsonparse["CUSTOM_SPRITES_REPO_URL"]
#     BASE_POKEMON_SPRITES_REPO_URL = jsonparse["BASE_POKEMON_SPRITES_REPO_URL"]
#     BASE_POKEMON_ALT_SPRITES_REPO_URL = jsonparse["BASE_POKEMON_ALT_SPRITES_REPO_URL"]
#     DISCORD_URL = jsonparse["DISCORD_URL"]
#     PIF_DISCORD_URL = jsonparse["PIF_DISCORD_URL"]
#     WIKI_URL = jsonparse["WIKI_URL"]
#   end

# end

def test_http_get
  url = "http://localhost:8080"
  response = HTTPLite.get(url)
  if response[:status] == 200
    p response[:body]
  end
end

def updateHttpSettingsFile
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::HTTP_CONFIGS_FILE_URL, Settings::HTTP_CONFIGS_FILE_PATH,)
end

def updateKurayJsonSettings
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::GAME_REMOTE_SETTINGS_URL, Settings::GAME_REMOTE_SETTINGS_FILE_PATH,)
end

def updateCreditsFile
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::CREDITS_FILE_URL, Settings::CREDITS_FILE_PATH,)
end

def updateCustomDexFile
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::CUSTOM_DEX_FILE_URL, Settings::CUSTOM_DEX_ENTRIES_PATH,)
end

def createCustomSpriteFolders()
  if !Dir.exist?(Settings::CUSTOM_BATTLERS_FOLDER)
    Dir.mkdir(Settings::CUSTOM_BATTLERS_FOLDER)
  end
  if !Dir.exist?(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED)
    Dir.mkdir(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED)
  end
end

def download_file(url, saveLocation)
  begin
    response = HTTPLite.get(url)
    if response[:status] == 200
      File.open(saveLocation, "wb") do |file|
        file.write(response[:body])
      end
      echoln _INTL("\nDownloaded file {1} to {2}", url, saveLocation)
      return saveLocation
    else
      # echoln _INTL("Tried to download file {1} . Got response  {2}",url,response[:body])
      echoln _INTL("Tried to download file {1}.",url)
    end
    return nil
  rescue MKXPError, Errno::ENOENT => error
    echo error
    return nil
  end
end

def download_pokemon_sprite_if_missing(body, head)
  return if $PokemonSystem.download_sprites != 0
  get_fusion_sprite_path(head, body)
end


def download_sprite(base_path, head_id, body_id, saveLocation = "Graphics/temp", alt_letter = "", spriteformBody_suffix = "", spriteformHead_suffix = "")
  begin
    head_id = (head_id.to_s) + spriteformHead_suffix
    body_id = (body_id.to_s) + spriteformBody_suffix

    downloaded_file_name = _INTL("{1}/{2}.{3}{4}.png", saveLocation, head_id, body_id, alt_letter)
    if !body_id || body_id == ""
      downloaded_file_name = _INTL("{1}{2}{3}.png", saveLocation, head_id, alt_letter)
    end

    return downloaded_file_name if pbResolveBitmap(downloaded_file_name)

    url = _INTL(base_path, head_id, body_id)

    if !body_id
      url = _INTL(base_path, head_id)
    end

    response = HTTPLite.get(url)
    if response[:status] == 200
      File.open(downloaded_file_name, "wb") do |file|
        file.write(response[:body])
      end
      echoln _INTL("\nDownloaded file from {1} to {2}", base_path, saveLocation)
      return downloaded_file_name
    end
    # echoln "tried to download " + url
    # echoln _INTL("Tried to download file {1} . Got response  {2}",url,response[:body])
    echoln "tried to download " + url
    return nil
  rescue MKXPError, Errno::ENOENT
    return nil
  end
end

def download_autogen_sprite(head_id, body_id,spriteformBody_suffix=nil,spriteformHead_suffix=nil)
  return nil if $PokemonSystem.download_sprites != 0
  # url = Settings::AUTOGEN_SPRITES_REPO_URL + "{1}/{1}.{2}.png"
  template_url = Settings::AUTOGEN_SPRITES_REPO_URL + "{1}/{1}.{2}.png"
  head_id = (head_id.to_s) + "_" + spriteformHead_suffix.to_s if spriteformHead_suffix
  body_id = (body_id.to_s) + "_" + spriteformBody_suffix.to_s if spriteformBody_suffix
  destPath = _INTL("{1}{2}", Settings::BATTLERS_FOLDER, head_id)
  # sprite = download_sprite(_INTL(url, head_id, body_id), head_id, body_id, destPath)
  url = _INTL(template_url, head_id, body_id)
  sprite = download_sprite(url, head_id, body_id, destPath)
  return sprite if sprite
  return nil
end

def download_custom_sprite(head_id, body_id, spriteformBody_suffix = "", spriteformHead_suffix = "", alt_letter="")
  return nil if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE,Settings::CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW,Settings::CUSTOMSPRITES_RATE_MAX_NB_REQUESTS)
  head_id = (head_id.to_s) + spriteformHead_suffix.to_s
  body_id = (body_id.to_s) + spriteformBody_suffix.to_s
  return nil if $PokemonSystem.download_sprites != 0
  #base_path = "https://raw.githubusercontent.com/Aegide/custom-fusion-sprites/main/CustomBattlers/{1}.{2}.png"
  # url = "https://raw.githubusercontent.com/infinitefusion/sprites/main/CustomBattlers/{1}.{2}.png"
  url = Settings::CUSTOM_SPRITES_REPO_URL + "{1}.{2}{3}.png"
  destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
  if !Dir.exist?(destPath)
    Dir.mkdir(destPath)
  end
  sprite = download_sprite(_INTL(url, head_id, body_id,alt_letter), head_id, body_id, destPath, alt_letter)
  return sprite if sprite
  return nil
end

def download_custom_sprite_filename(filename)
  return nil if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE,Settings::CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW,Settings::CUSTOMSPRITES_RATE_MAX_NB_REQUESTS)
  head_id = (head_id.to_s) + spriteformHead_suffix.to_s
  body_id = (body_id.to_s) + spriteformBody_suffix.to_s
  return nil if $PokemonSystem.download_sprites != 0
  url = Settings::CUSTOM_SPRITES_REPO_URL + "{1}.{2}{3}.png"
  destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
  if !Dir.exist?(destPath)
    Dir.mkdir(destPath)
  end
  sprite = download_sprite(_INTL(url, head_id, body_id,alt_letter), head_id, body_id, destPath, alt_letter)
  return sprite if sprite
  return nil
end

#todo refactor & put custom base sprites in same folder as fusion sprites
def download_unfused_main_sprite(dex_num, alt_letter="")
  base_url = alt_letter == "" ? Settings::BASE_POKEMON_SPRITES_REPO_URL : Settings::BASE_POKEMON_ALT_SPRITES_REPO_URL
  filename = _INTL("{1}{2}.png",dex_num,alt_letter)
  url = base_url + filename
  destPath = alt_letter == "" ? _INTL("{1}{2}", Settings::BATTLERS_FOLDER, dex_num) : Settings::CUSTOM_BASE_SPRITES_FOLDER
  sprite = download_sprite(url, dex_num, nil, destPath,alt_letter)

  return sprite if sprite
  return nil
end

def download_all_unfused_alt_sprites(dex_num)
  base_url = Settings::BASE_POKEMON_ALT_SPRITES_REPO_URL + "{1}"
  extension = ".png"
  destPath = _INTL("{1}", Settings::CUSTOM_BASE_SPRITES_FOLDER)
  if !Dir.exist?(destPath)
    Dir.mkdir(destPath)
  end
  alt_url = _INTL(base_url, dex_num) + extension
  download_sprite(alt_url, dex_num, nil, destPath)
  alphabet = ('a'..'z').to_a + ('aa'..'az').to_a
  alphabet.each do |letter|
    alt_url = _INTL(base_url, dex_num) + letter + extension
    sprite = download_sprite(alt_url, dex_num, nil, destPath, letter)
    return if !sprite
  end
end

def download_all_alt_sprites(head_id, body_id)
  base_url = "#{Settings::CUSTOM_SPRITES_REPO_URL}{1}.{2}"
  extension = ".png"
  destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
  if !Dir.exist?(destPath)
    Dir.mkdir(destPath)
  end
  alphabet = ('a'..'z').to_a + ('aa'..'az').to_a
  alphabet.each do |letter|
    alt_url = base_url + letter + extension
    sprite = download_sprite(alt_url, head_id, body_id, destPath, letter)
    return if !sprite
  end
end

#format: [1.1.png, 1.2.png, etc.]
# https://api.github.com/repos/infinitefusion/contents/sprites/CustomBattlers
#   repo = "Aegide/custom-fusion-sprites"
#   folder = "CustomBattlers"
#

# def fetch_online_custom_sprites
#   page_start =1
#   page_end =2
#
#   repo = "infinitefusion/sprites"
#   folder = "CustomBattlers"
#   api_url = "https://api.github.com/repos/#{repo}/contents/#{folder}"
#
#   files = []
#   page = page_start
#
#   File.open(Settings::CUSTOM_SPRITES_FILE_PATH, "wb") do |csv|
#     loop do
#       break if page > page_end
#       response = HTTPLite.get(api_url, {'page' => page.to_s})
#       response_files = HTTPLite::JSON.parse(response[:body])
#       break if response_files.empty?
#       response_files.each do |file|
#         csv << [file['name']].to_s
#         csv << "\n"
#       end
#       page += 1
#     end
#   end
#
#
#   write_custom_sprites_csv(files)
# end

# Too many file to get everything without getting
# rate limited by github, so instead we're getting the
# files list from a  csv file that will be manually updated
# with each new spritepack

def updateOnlineCustomSpritesFile
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::SPRITES_FILE_URL, Settings::CUSTOM_SPRITES_FILE_PATH)
end

def list_online_custom_sprites(updateList = false)
  sprites_list = []
  File.foreach(Settings::CUSTOM_SPRITES_FILE_PATH) do |line|
    sprites_list << line
  end
  return sprites_list
end

GAME_VERSION_FORMAT_REGEX = /\A\d+(\.\d+)*\z/

def fetch_latest_game_version
  begin
    download_file(Settings::VERSION_FILE_URL, Settings::REMOTE_VERSION_FILE_PATH,)
    version_file = File.open(Settings::REMOTE_VERSION_FILE_PATH, "r")
    version = version_file.first
    version_file.close

    version_format_valid = version.match(GAME_VERSION_FORMAT_REGEX)

    return version if version_format_valid
    return nil
  rescue MKXPError, Errno::ENOENT => error
    echo error
    return nil
  end

end

def requestRateExceeded?(logFile,timeWindow, maxRequests)
  # Read or initialize the request log
  if File.exist?(logFile)
    log_data = File.read(logFile).split("\n")
    request_timestamps = log_data.map(&:to_i)
  else
    request_timestamps = []
  end
  current_time = Time.now.to_i
  # Remove old timestamps that are outside the time window
  request_timestamps.reject! { |timestamp| (current_time - timestamp) > timeWindow }
  # Update the log with the current request
  request_timestamps << current_time
  # Write the updated log back to the file
  File.write(logFile, request_timestamps.join("\n"))
  # Check if the number of requests in the time window exceeds the limit
  echoln request_timestamps.size > maxRequests
  echoln request_timestamps
  echoln maxRequests
  return request_timestamps.size > maxRequests
end