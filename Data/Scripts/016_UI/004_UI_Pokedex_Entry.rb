#===============================================================================
#
#===============================================================================
class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist, index, region)
    @endscene = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index = index
    @region = region
    @page = 1
    @entry_page = 0
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["infosprite"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["infosprite"].zoom_y = Settings::FRONTSPRITE_SCALE
    @randomEntryText = nil

    # @mapdata = pbLoadTownMapData
    # map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    # mappos = (map_metadata) ? map_metadata.town_map_position : nil
    # if @region < 0                                 # Use player's current region
    #   @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    # end
    # @sprites["areamap"] = IconSprite.new(0,0,@viewport)
    # @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    # @sprites["areamap"].x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
    # @sprites["areamap"].y += (Graphics.height+32-@sprites["areamap"].bitmap.height)/2
    # for hidden in Settings::REGION_MAP_EXTRAS
    #   if hidden[0]==@region && hidden[1]>0 && $game_switches[hidden[1]]
    #     pbDrawImagePositions(@sprites["areamap"].bitmap,[
    #        ["Graphics/Pictures/#{hidden[4]}",
    #           hidden[2]*PokemonRegionMap_Scene::SQUAREWIDTH,
    #           hidden[3]*PokemonRegionMap_Scene::SQUAREHEIGHT]
    #     ])
    #   end
    # end
    # @sprites["areahighlight"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    # @sprites["areaoverlay"] = IconSprite.new(0,0,@viewport)
    # @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::Center)
    @sprites["formfront"].x = 130
    @sprites["formfront"].y = 158
    @sprites["formfront"].zoom_y = Settings::FRONTSPRITE_SCALE
    @sprites["formfront"].zoom_x = Settings::FRONTSPRITE_SCALE

    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::Bottom)
    @sprites["formback"].x = 382 # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::Center)
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
    @sprites["formicon"].visible = false
    initializeSpritesPageGraphics

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)

    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    initializeSpritesPage(@available)
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def initializeSpritesPageGraphics()
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = 20
    @sprites["leftarrow"].y = 250 #268
    @sprites["leftarrow"].play
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = 440
    @sprites["rightarrow"].y = 250
    @sprites["rightarrow"].play
    @sprites["rightarrow"].visible = false

    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 250
    @sprites["uparrow"].y = 50 #268
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 250
    @sprites["downarrow"].y = 350
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
  end

  def pbStartSpritesSelectSceneBrief(species,alts_list)
    @available = alts_list
    @species = species
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @index = 0
    @page = 3
    @brief = true
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)

    @page = 3
    initializeSpritesPageGraphics
    initializeSpritesPage(@available)
    drawPage(@page)

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)
    # For standalone access, shows first page only
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    dexnum = 0
    dexnumshift = false
    if $Trainer.pokedex.unlocked?(-1) # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      dexnum = species_data.id_number if species_data
      dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      dexnum = 0
      for i in 0...$Trainer.pokedex.dexes_count - 1 # Regional Dexes
        next if !$Trainer.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [[species, "", 0, 0, dexnum, dexnumshift]]
    @index = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["infosprite"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["infosprite"].zoom_y = Settings::FRONTSPRITE_SCALE
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)

    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @page = 1
    drawPage(@page)
    sprite_bitmap = @sprites["infosprite"].getBitmap

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSpritesPageBrief(species) end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose if @typebitmap
    @viewport.dispose
  end

  def pbUpdate
    if @page == 2
      intensity = (Graphics.frame_count % 40) * 12
      intensity = 480 - intensity if intensity > 240
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form = $Trainer.pokedex.last_form_seen(@species)

    if @sprites["selectedSprite"]
      @sprites["selectedSprite"].visible = false
    end
    if @sprites["nextSprite"]
      @sprites["nextSprite"].visible = false
    end
    if @sprites["previousSprite"]
      @sprites["previousSprite"].visible = false
    end
    # species_data = pbGetSpeciesData(@species)
    species_data = GameData::Species.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species)#, @gender, @form)

    # if @sprites["formfront"]
    #   @sprites["formfront"].setSpeciesBitmap(@species,@gender,@form)
    # end
    # if @sprites["formback"]
    #   @sprites["formback"].setSpeciesBitmap(@species,@gender,@form,false,false,true)
    #   @sprites["formback"].y = 256
    #   @sprites["formback"].y += species_data.back_sprite_y * 2
    # end
    # if @sprites["formicon"]
    #   @sprites["formicon"].pbSetParams(@species,@gender,@form)
    # end
  end

  # def pbGetAvailableForms
  #   ret = []
  #   return ret
  #   # multiple_forms = false
  #   # # Find all genders/forms of @species that have been seen
  #   # GameData::Species.each do |sp|
  #   #   next if sp.species != @species
  #   #   next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
  #   #   next if sp.pokedex_form != sp.form
  #   #   multiple_forms = true if sp.form > 0
  #   #   case sp.gender_ratio
  #   #   when :AlwaysMale, :AlwaysFemale, :Genderless
  #   #     real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
  #   #     next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
  #   #     real_gender = 2 if sp.gender_ratio == :Genderless
  #   #     ret.push([sp.form_name, real_gender, sp.form])
  #   #   else   # Both male and female
  #   #     for real_gender in 0...2
  #   #       next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
  #   #       ret.push([sp.form_name, real_gender, sp.form])
  #   #       break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
  #   #     end
  #   #   end
  #   # end
  #   # # Sort all entries
  #   # ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
  #   # # Create form names for entries if they don't already exist
  #   # ret.each do |entry|
  #   #   if !entry[0] || entry[0].empty?   # Necessarily applies only to form 0
  #   #     case entry[1]
  #   #     when 0 then entry[0] = _INTL("Male")
  #   #     when 1 then entry[0] = _INTL("Female")
  #   #     else
  #   #       entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
  #   #     end
  #   #   end
  #   #   entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
  #   # end
  #   # return ret
  # end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
    @sprites["infosprite"].visible = (@page == 1)
    @sprites["areamap"].visible = (@page == 2) if @sprites["areamap"]
    @sprites["areahighlight"].visible = (@page == 2) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible = (@page == 2) if @sprites["areaoverlay"]
    # @sprites["formfront"].visible     = (@page==3) if @sprites["formfront"]
    #@sprites["formback"].visible      = (@page==3) if @sprites["formback"]
    #@sprites["formicon"].visible      = (@page==3) if @sprites["formicon"]

    @sprites["previousSprite"].visible = (@page == 3) if @sprites["previousSprite"]
    @sprites["selectedSprite"].visible = (@page == 3) if @sprites["selectedSprite"]
    @sprites["nextSprite"].visible = (@page == 3) if @sprites["nextSprite"]

    hide_all_selected_windows
    # Draw page-specific information
    case page
    when 1 then
      drawPageInfo
    when 2 then
      drawPageArea
    when 3 then
      drawPageForms
    end
  end

  def drawPageInfo
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    imagepos = []
    if @brief
      imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"), 0, 0])
    end
    species_data = GameData::Species.get_species_form(@species, @form)
    # Write various bits of text
    indexText = "???"
    #if @dexlist[@index][4] > 0
    indexNumber = @dexlist[@index][4]
    indexNumber -= 1 if @dexlist[@index][5]
    indexNumber = GameData::Species.get(@species).id_number
    indexText = sprintf("%03d", indexNumber)
    # end
    textpos = [
      [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
       246, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
      [_INTL("Height"), 314, 152, 0, base, shadow],
      [_INTL("Weight"), 314, 184, 0, base, shadow]
    ]
    if $Trainer.owned?(@species)
      # Write the category
      textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 68, 0, base, shadow])
      # Write the Evolutions
      textpos.push([_INTL("Evolve"), 210, 112, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)])
      evolutions = species_data.get_evolutions
      item_evo = evolutions.any? { |evo| evo[1] == :Item }
      other_evo = evolutions.any? { |evo| evo[1] != :Item && evo[1] != :Level }
      evolutions.select! { |evo| evo[1] == :Level }
      y_evo_offset = 140;
      for evo in evolutions
        next if !evo
        textpos.push([_INTL("Lv {1}", evo[2]), 208, y_evo_offset, 0, base, shadow])
        y_evo_offset += 24
      end
      if item_evo
        textpos.push([_INTL("Item"), 208, y_evo_offset, 0, base, shadow])
        y_evo_offset += 24
      end
      if other_evo
        textpos.push([_INTL("Other"), 208, y_evo_offset, 0, base, shadow])
      end
      # Write the height and weight
      height = species_data.height
      weight = species_data.weight
      if System.user_language[3..4] == "US" # If the user is in the United States
        inches = (height / 0.254).round
        pounds = (weight / 0.45359).round
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 460, 152, 1, base, shadow])
        textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 494, 184, 1, base, shadow])
      else
        textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 470, 152, 1, base, shadow])
        textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 482, 184, 1, base, shadow])
      end
      # Draw the Pokédex entry text
      # drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4, # overlay, x, y, width, num lines
      #            species_data.pokedex_entry, base, shadow)
      #
      #
      #$PokemonSystem.use_generated_dex_entries=true if $PokemonSystem.use_generated_dex_entries ==nil
      drawEntryText(overlay, species_data)
      # Draw the footprint
      footprintfile = GameData::Species.footprint_filename(@species, @form)
      if footprintfile
        footprint = RPG::Cache.load_bitmap("", footprintfile)
        overlay.blt(226, 138, footprint, footprint.rect)
        footprint.dispose
      end
      # Show the owned icon
      imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
      # Draw the type icon(s)
      type1 = species_data.type1
      type2 = species_data.type2
      type1_number = GameData::Type.get(type1).id_number
      type2_number = GameData::Type.get(type2).id_number
      type1rect = Rect.new(0, type1_number * 32, 96, 32)
      type2rect = Rect.new(0, type2_number * 32, 96, 32)
      overlay.blt(296, 120, @typebitmap.bitmap, type1rect)
      overlay.blt(396, 120, @typebitmap.bitmap, type2rect) if type1 != type2
    else
      # Write the category
      textpos.push([_INTL("????? Pokémon"), 246, 68, 0, base, shadow])
      # Write the height and weight
      if System.user_language[3..4] == "US" # If the user is in the United States
        textpos.push([_INTL("???'??\""), 460, 152, 1, base, shadow])
        textpos.push([_INTL("????.? lbs."), 494, 184, 1, base, shadow])
      else
        textpos.push([_INTL("????.? m"), 470, 152, 1, base, shadow])
        textpos.push([_INTL("????.? kg"), 482, 184, 1, base, shadow])
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end


  def   drawEntryText(overlay, species_data)
    baseColor = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    shadowCustom = Color.new(160, 200, 150)
    shadowAI = Color.new(168, 184, 220)

    if species_data.is_fusion
      customEntry = getCustomEntryText(species_data)
      if customEntry
        entryText = customEntry
        shadowColor = shadowCustom
      else
        if $PokemonSystem.use_generated_dex_entries && species_data.is_a?(GameData::FusedSpecies)
          @randomEntryText = species_data.get_random_dex_entry if !@randomEntryText
          entryText = @randomEntryText
          shadowColor = shadow
        else
          entryText = "No custom Pokédex entry available for this Pokémon. Please consider submitting an entry for this Pokémon on the game's Discord."
          shadowColor = shadow
        end
      end
    else
      entryText = species_data.pokedex_entry
      shadowColor = shadow
    end

    max_chars_per_page = 150
    pages = splitTextIntoPages(entryText, max_chars_per_page)
    @entry_page = 0 if !@entry_page || pages.length == 1
    displayedText = pages[@entry_page]
    if pages.length > 1
      page_indicator_text = "#{@entry_page + 1}/#{pages.length}"
      drawTextEx(overlay, 425, 340, Graphics.width - (40 * 2), 4, # overlay, x, y, width, num lines
                 page_indicator_text, baseColor, shadow)
    end

    drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4, # overlay, x, y, width, num lines
               displayedText, baseColor, shadowColor)
  end

  def splitTextIntoPages(text, max_chars_per_page)
    words = text.split
    pages = []
    current_page = ""

    words.each do |word|
      if current_page.length + word.length + 1 > max_chars_per_page
        pages << current_page.strip
        current_page = word
      else
        current_page += " " unless current_page.empty?
        current_page += word
      end
    end

    pages << current_page.strip unless current_page.empty?
    pages
  end

  def reloadDexEntry()
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    drawPageInfo
  end

  def changeEntryPage()
    pbSEPlay("GUI sel cursor")
    @entry_page = @entry_page == 1 ? 0 : 1
    reloadDexEntry
  end
  
    def isAutogenSprite(sprite_path)
      return !sprite_path.include?(Settings::CUSTOM_BATTLERS_FOLDER)
    end
  
    def getCustomEntryText(species_data)
      sprite_bitmap= GameData::Species.sprite_bitmap(species_data.species)
      sprite_bitmap.recognizeDims()
      return nil if isAutogenSprite(sprite_bitmap.path)
      spritename = sprite_bitmap.filename
      possibleCustomEntries = getCustomDexEntry(spritename)
      if possibleCustomEntries && possibleCustomEntries.length > 0
        customEntry = possibleCustomEntries.sample
        customEntry = customEntry.gsub(Settings::CUSTOM_ENTRIES_NAME_PLACEHOLDER,species_data.name)
      end
      return customEntry
    end
  
    def getCustomDexEntry(sprite)
      json_data = File.read(Settings::CUSTOM_DEX_ENTRIES_PATH)
      parsed_data = HTTPLite::JSON.parse(json_data)
  
      entries = parsed_data.select { |entry| entry["sprite"] == sprite }
      if entries.any?
        return entries.map { |entry| entry["entry"] }
      else
        echoln "No custom entry found for sprite " + sprite.to_s
        return nil
      end
    end

    def getAIDexEntry(pokemonID, name)
      begin
        head_number = get_head_number_from_symbol(pokemonID).to_s
        body_number = get_body_number_from_symbol(pokemonID).to_s
  
        # Ensure the file exists, if not, create it
        unless File.exist?(Settings::AI_DEX_ENTRIES_PATH)
          File.write(Settings::AI_DEX_ENTRIES_PATH, '{}')
        end
  
        json_data = File.read(Settings::AI_DEX_ENTRIES_PATH)
        data = HTTPLite::JSON.parse(json_data)
  
        # Check if the entry exists
        unless data[head_number] && data[head_number][body_number]
          # If not, fetch it from the API
          url = Settings::AI_ENTRIES_URL + "?head=#{head_number}&body=#{body_number}"
          if !requestRateExceeded?(Settings::AI_ENTRIES_RATE_LOG_FILE, Settings::AI_ENTRIES_RATE_TIME_WINDOW, Settings::AI_ENTRIES_RATE_MAX_NB_REQUESTS)
            fetched_entry = clean_json_string(pbDownloadToString(url))
          else
            echoln "API rate exceeded for AI entries"
          end
          return nil if !fetched_entry || fetched_entry.empty?
          # If the fetched entry is valid, update the JSON and save it
          unless fetched_entry.empty?
            data[head_number] ||= {}
            data[head_number][body_number] = fetched_entry
            serialized_data = serialize_json(data)
            File.write(Settings::AI_DEX_ENTRIES_PATH, serialized_data)
          else
            echoln "No AI entry found for Pokemon " + pokemonID.to_s
            return nil
          end
        end
  
        entry = data[head_number][body_number]
        entry = entry.gsub(Settings::CUSTOM_ENTRIES_NAME_PLACEHOLDER, name)
        entry = entry.gsub("\n", "")
  
        # Unescape any escaped quotes before returning the entry
        entry = entry.gsub('\\"', '"')
        return clean_json_string(entry)
      rescue MKXPError
        return nil
      end
    end

  def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
  end

  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    @sprites["areahighlight"].bitmap.clear
    # Fill the array "points" with all squares of the region map in which the
    # species can be found
    points = []
    mapwidth = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
      next if !pbFindEncounter(enc_data.types, @species)
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      mappos = (map_metadata) ? map_metadata.town_map_position : nil
      next if !mappos || mappos[0] != @region
      showpoint = true
      for loc in @mapdata[@region][2]
        showpoint = false if loc[0] == mappos[1] && loc[1] == mappos[2] &&
          loc[7] && !$game_switches[loc[7]]
      end
      next if !showpoint
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth = mapsize[0]
        sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
        for i in 0...sqwidth
          for j in 0...sqheight
            if mapsize[1][i + j * sqwidth, 1].to_i > 0
              points[mappos[1] + i + (mappos[2] + j) * mapwidth] = true
            end
          end
        end
      else
        points[mappos[1] + mappos[2] * mapwidth] = true
      end
    end
    # Draw coloured squares on each square of the region map with a nest
    pointcolor = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
    sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
    for j in 0...points.length
      if points[j]
        x = (j % mapwidth) * sqwidth
        x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
        y = (j / mapwidth) * sqheight
        y += (Graphics.height + 32 - @sprites["areamap"].bitmap.height) / 2
        @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
        if j - mapwidth < 0 || !points[j - mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
        end
        if j + mapwidth >= points.length || !points[j + mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
        end
        if j % mapwidth == 0 || !points[j - 1]
          @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
        end
        if (j + 1) % mapwidth == 0 || !points[j + 1]
          @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
        end
      end
    end
    # Set the text
    textpos = []
    if points.length == 0
      pbDrawImagePositions(overlay, [
        [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"), 108, 188]
      ])
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, Graphics.height / 2 - 6, 2, base, shadow])
    end
    textpos.push([pbGetMessage(MessageTypes::RegionNames, @region), 414, 38, 2, base, shadow])
    textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                  Graphics.width / 2, 346, 2, base, shadow])
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1] == @gender && i[2] == @form
        formname = i[0]; break
      end
    end
    textpos = [
      [GameData::Species.get(@species).name, Graphics.width / 2, Graphics.height - 94, 2, base, shadow],
      [formname, Graphics.width / 2, Graphics.height - 62, 2, base, shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbGoToPrevious
    @entry_page = 0
    newindex = @index
    while newindex > 0
      newindex -= 1
      if $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbGoToNext
    @entry_page = 0
    newindex = @index
    while newindex < @dexlist.length - 1
      newindex += 1
      if $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbChooseAlt(brief=false)
    index = 0
    for i in 0...@available.length
      if @available[i][1] == @gender && @available[i][2] == @form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex != index
        $Trainer.pokedex.set_last_form_seen(@species, @available[index][1], @available[index][2])
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible = (index > 0)
        @sprites["downarrow"].visible = (index < @available.length - 1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index + @available.length - 1) % @available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index + 1) % @available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible = false
    @sprites["downarrow"].visible = false
  end

  def pbScene
    Pokemon.play_cry(@species, @form)
    until @endscene
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        changeEntryPage()
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page == 1 # entry
          changeEntryPage()
        elsif @page == 3 # Forms
          #if @available.length > 1
          pbPlayDecisionSE
          pbChooseAlt
          dorefresh = true
          # end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index != oldindex
          @selected_index=0
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index != oldindex
          @selected_index=0
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 2
        @page = 1 if @page < 1
        @page = 3 if @page > 3
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 2
        @page = 1 if @page < 1
        @page = 3 if @page > 3
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end

  def pbSceneBrief
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::ACTION)
        changeEntryPage()
        Pokemon.play_cry(@species, @form)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT)
        changeEntryPage()
      end
    end
  end

  def pbSelectSpritesSceneBrief
    pbChooseAlt(true)

    # loop do
    #   Graphics.update
    #   Input.update
    #   pbUpdate
    #   if Input.trigger?(Input::ACTION)
    #     pbPlayDecisionSE
    #   elsif Input.trigger?(Input::BACK)
    #     pbPlayCloseMenuSE
    #     break
    #   end
    # end
  end

end

#===============================================================================
#
#===============================================================================
class PokemonPokedexInfoScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dexlist, index, region)
    @scene.pbStartScene(dexlist, index, region)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret # Index of last species viewed in dexlist
  end

  def pbStartSceneSingle(species)
    # For use from a Pokémon's summary screen
    region = -1
    if Settings::USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region >= $Trainer.pokedex.dexes_count - 1
    else
      region = $PokemonGlobal.pokedexDex # National Dex -1, regional Dexes 0, 1, etc.
    end
    dexnum = GameData::Species.get(species).id_number #pbGetRegionalNumber(region,species)
    dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
    dexlist = [[species, GameData::Species.get(species).name, 0, 0, dexnum, dexnumshift]]
    @scene.pbStartScene(dexlist, 0, region)
    @scene.pbScene
    @scene.pbEndScene
  end

  def pbDexEntry(species)
    # For use when capturing a new species
    nb_sprites_for_alts_page = isSpeciesFusion(species) ? 2 : 1
    alts_list = @scene.pbGetAvailableForms(species)
    if alts_list.length > nb_sprites_for_alts_page && ($PokemonSystem.dexspriteselect != nil && $PokemonSystem.dexspriteselect == 1)
      @scene.pbStartSpritesSelectSceneBrief(species,alts_list)
      @scene.pbSelectSpritesSceneBrief
      @scene.pbEndScene
    end
    @scene.pbStartSceneBrief(species)
    @scene.pbSceneBrief
    @scene.pbEndScene
  end
end
