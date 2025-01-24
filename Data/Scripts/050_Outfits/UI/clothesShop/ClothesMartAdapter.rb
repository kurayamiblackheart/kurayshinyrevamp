class ClothesMartAdapter < OutfitsMartAdapter
  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A piece of clothing that trainers can wear."

  def initialize(stock = nil, isShop = nil)
    super
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
    return getOverworldOutfitFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    return if !item
    previewWindow.clothes = item.id
    $Trainer.clothes = item.id
    pbRefreshSceneMap
    previewWindow.updatePreview()
  end


  def addItem(item)
    changed_clothes = obtainClothes(item.id)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $Trainer.clothes
  end

  def putOnOutfit(item)
    putOnClothes(item.id)
    @worn_clothes = item.id
  end

  def reset_player_clothes()
    $Trainer.clothes = @worn_clothes
  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_clothes
  end

  def isWornItem?(item)
    super
  end
end
