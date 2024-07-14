#CLOTHES

def search_clothes(matching_tags = [], only_unlocked = false)
  update_global_outfit_lists()
  selector = OutfitSelector.new

  full_data_list = $PokemonGlobal.clothes_data
  existing_files_list = selector.parse_clothes_folder()
  unlocked_list = $Trainer.unlocked_clothes
  return search_outfits_by_tag(full_data_list, matching_tags, existing_files_list, unlocked_list, only_unlocked)
end

def filter_clothes(filter_tags = [], only_unlocked = false)
  update_global_outfit_lists()
  selector = OutfitSelector.new

  full_data_list = $PokemonGlobal.hats_data
  existing_files_list = selector.parse_hats_folder()
  unlocked_list = $Trainer.unlocked_hats
  return filter_outfits_by_tag(full_data_list, filter_tags, existing_files_list, unlocked_list, only_unlocked)
end

#HATS

def search_hats(matching_tags = [], only_unlocked = false)
  update_global_outfit_lists()
  selector = OutfitSelector.new

  full_data_list = $PokemonGlobal.hats_data
  existing_files_list = selector.parse_hats_folder()
  unlocked_list = $Trainer.unlocked_hats
  return search_outfits_by_tag(full_data_list, matching_tags, existing_files_list, unlocked_list, only_unlocked)
end

def filter_hats(filter_tags = [], only_unlocked = false)
  update_global_outfit_lists()
  selector = OutfitSelector.new

  full_data_list = $PokemonGlobal.hats_data
  existing_files_list = selector.parse_hats_folder()
  echoln existing_files_list
  unlocked_list = $Trainer.unlocked_hats
  return filter_outfits_by_tag(full_data_list, filter_tags, existing_files_list, unlocked_list, only_unlocked)
end


# Generic searching methods

#Get outfits that have ANY of the tags
def search_outfits_by_tag(outfits_map, matching_tags = [], physical_files_list = [], unlocked_list = [], require_unlocked = false)
  filtered_list = []
  outfits_map.each do |outfit_id, outfit|
    if outfit.tags.any? { |tag| matching_tags.include?(tag) }
      filtered_list << outfit_id if outfit_is_valid?(outfit_id, physical_files_list, unlocked_list, require_unlocked)
    end
  end
  return filtered_list
end

#Get outfits that have ALL of the tags
def filter_outfits_by_tag(outfits_map, filter_tags = [], physical_files_list = [], unlocked_list = [], require_unlocked = false)
  update_global_outfit_lists()

  filtered_list = []
  outfits_map.each do |outfit_id, outfit|
    if filter_tags.all? { |tag| outfit.tags.include?(tag) }
      filtered_list << outfit_id if outfit_is_valid?(outfit_id, physical_files_list, unlocked_list, require_unlocked)
    end
  end
  return filtered_list
end


def outfit_is_valid?(outfit_id, physical_files_list, unlocked_list, require_unlocked)
  return false if require_unlocked && !unlocked_list.include?(outfit_id)
  return physical_files_list.include?(outfit_id)
end

def add_tags(tags_list=[])
  newTag=pbEnterText("add tag",0,10)
  return tags_list if newTag.length == 0
  tags_list << newTag
  return tags_list
end

def get_clothes_by_id(id)
  update_global_outfit_lists()
  return $PokemonGlobal.clothes_data.has_key?(id) ? $PokemonGlobal.clothes_data[id] : nil
end

def get_hat_by_id(id)
  update_global_outfit_lists()
  return $PokemonGlobal.hats_data.has_key?(id) ? $PokemonGlobal.hats_data[id] : nil
end

def get_hair_by_id(id)
  update_global_outfit_lists()
  return $PokemonGlobal.hairstyles_data.has_key?(id) ? $PokemonGlobal.hairstyles_data[id] : nil
end