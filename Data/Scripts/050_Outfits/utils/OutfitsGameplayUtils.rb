def obtainNewHat(outfit_id)
  echoln "obtained new hat: " + outfit_id
  outfit = get_hat_by_id(outfit_id)
  $Trainer.unlocked_hats << outfit_id if !$Trainer.unlocked_hats.include?(outfit_id)
  obtainOutfitMessage(outfit)
  if pbConfirmMessage("Would you like to put it on right now?")
    putOnHat(outfit_id)
    return true
  end
  return false
end

def obtainNewClothes(outfit_id)
  echoln "obtained new clothes: " + outfit_id
  outfit = get_clothes_by_id(outfit_id)
  $Trainer.unlocked_clothes << outfit_id if !$Trainer.unlocked_clothes.include?(outfit_id)
  obtainOutfitMessage(outfit)
  if pbConfirmMessage("Would you like to put it on right now?")
    putOnClothes(outfit_id)
    return true
  end
  return false
end

def obtainNewHairstyle(full_outfit_id)
  split_outfit_id =getSplitHairFilenameAndVersionFromID(full_outfit_id)
  hairstyle_id =split_outfit_id[1]
  hairstyle_version= split_outfit_id[0]
  outfit = get_hair_by_id(hairstyle_id)
  $Trainer.unlocked_clothes << hairstyle_id if !$Trainer.unlocked_hairstyles.include?(hairstyle_id)
  musical_effect = "Key item get"
  pbMessage(_INTL("\\me[{1}]Your hairstyle was changed to \\c[1]{2}\\c[0] hairstyle!\\wtnp[30]", musical_effect, outfit.name))
  # pbMessage(_INTL("\\me[{1}]You obtained the \\c[1]{2}\\c[0] hairstyle!\\wtnp[30]", musical_effect, outfit.name))
  # if pbConfirmMessage("Would you like to use this hairstyle right now?")
  #   putOnHair(hairstyle_id,hairstyle_version)
  #   return true
  # end
  return false
end

def putOnClothes(outfit_id)
  outfit = get_clothes_by_id(outfit_id)
  $Trainer.clothes = outfit_id
  putOnOutfitMessage(outfit)
end

def putOnHat(outfit_id)
  outfit = get_hat_by_id(outfit_id)
  $Trainer.hat = outfit_id
  putOnOutfitMessage(outfit)
end

def putOnHairFullId(full_outfit_id)
  outfit_id = getSplitHairFilenameAndVersionFromID(full_outfit_id)[1]
  outfit = get_hair_by_id(outfit_id)
  $Trainer.hair = getFullHairId(full_outfit_id)
  putOnOutfitMessage(outfit)
end

def putOnHair(outfit_id, version)
  #outfit = get_hair_by_id(outfit_id)
  $Trainer.hair = getFullHairId(outfit_id,version)
  #putOnOutfitMessage(outfit)
end


#todo: add a little preview window?
def obtainOutfitMessage(outfit)
  musical_effect = "Key item get"
  pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", musical_effect, outfit.name))
end

def putOnOutfitMessage(outfit)
  playOutfitChangeAnimation()
  pbMessage(_INTL("You put on the \\c[1]{1}\\c[0]!\\wtnp[30]", outfit.name))
end

def refreshPlayerOutfit()
  return if !$scene.spritesetGlobal
  $scene.spritesetGlobal.playersprite.refreshOutfit()
end

def findLastHairVersion(hairId)
  possible_versions = (1..9).to_a
  last_version = 0
  possible_versions.each { |version|
    hair_id = getFullHairId(hairId, version)
    if pbResolveBitmap(getOverworldHairFilename(hair_id))
      last_version = version
    else
      return last_version
    end
  }
  return last_version

end
