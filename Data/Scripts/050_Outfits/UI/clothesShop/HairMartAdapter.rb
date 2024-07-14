class HairMartAdapter < OutfitsMartAdapter
  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A hairstyle for trainers."

  POSSIBLE_VERSIONS = (1..9).to_a

  def initialize(stock = nil, isShop = nil)
    super
    @version = getCurrentHairVersion().to_i
    @worn_hat = $Trainer.hat
    @hat_visible=false
    @removable = true
  end

  def switchVersion(item, delta=1)
    pbSEPlay("GUI party switch", 80, 100)
    newVersion = @version+ delta
    lastVersion = findLastHairVersion(item.id)
    newVersion = lastVersion if newVersion <= 0
    newVersion = 1 if newVersion > lastVersion
    @version = newVersion
  end

  def toggleEvent(item)
    pbSEPlay("GUI storage put down", 80, 100)
    toggleHatVisibility()
  end

  def toggleText()
    text = ""
    text << "Color: L / R\n"
    text << "Hat: D\n"

  end

  def toggleHatVisibility()
    @hat_visible = !@hat_visible
  end

  def getPrice(item, selling = nil)
    return 0 if !@isShop
    trainerStyleID = getSplitHairFilenameAndVersionFromID($Trainer.hair)[0]
    return 0 if item == trainerStyleID
    return nil if itemOwned(item)
    return item.price.to_i
  end

  def getDisplayPrice(item, selling = nil)
    trainerStyleID = getSplitHairFilenameAndVersionFromID($Trainer.hair)[0]
    return "-" if item == trainerStyleID
    super
  end

  def getCurrentHairVersion()
    begin
      return getSplitHairFilenameAndVersionFromID($Trainer.hair)[0]
    rescue
      return 1
    end
  end

  def getCurrentHairId(itemId)
    return getFullHairId(itemId, @version)
  end

  def getName(item)
    return item.id
  end

  def getDisplayName(item)
    return getName(item) if !item.name
    return item.name
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    itemId = getCurrentHairId(item.id)
    return getOverworldHatFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    return if !item
    displayed_hat = @hat_visible ? @worn_hat : nil
    previewWindow.hat=displayed_hat
    $Trainer.hat = displayed_hat
    itemId = getCurrentHairId(item.id)
    echoln itemId
    previewWindow.hair = itemId
    $Trainer.hair = itemId
    pbRefreshSceneMap
    previewWindow.updatePreview()
  end

  def addItem(item)
    itemId = getCurrentHairId(item.id)

    changed_clothes = obtainNewHairstyle(itemId)
    if changed_clothes
      @worn_clothes = itemId
    end
  end

  def get_current_clothes()
    return $Trainer.hair
  end

  def putOnOutfit(item)
    itemFullId = getCurrentHairId(item.id)
    putOnHair(item.id, @version)
    @worn_clothes = itemFullId
  end

  def reset_player_clothes()
    $Trainer.hair = @worn_clothes
    $Trainer.hat = @worn_hat
  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_hairstyles
  end
end
