class HatsMartAdapter < OutfitsMartAdapter
  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A headgear that trainers can wear."

  def initialize(stock = nil, isShop = nil)
    super
  end

  def toggleEvent(item)
    if !@isShop
      if pbConfirmMessage(_INTL("Do you want to take off your hat?"))
        $Trainer.hat = nil
        @worn_clothes = nil

      end
    end
  end

  def toggleText()
    return if @isShop
    toggleKey = "D"#getMappedKeyFor(Input::SPECIAL)
    return "Remove hat: #{toggleKey}"
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
    return getOverworldHatFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    return if !item
    previewWindow.hat = item.id
    $Trainer.hat = item.id unless $Trainer.hat==nil
    pbRefreshSceneMap
    previewWindow.updatePreview()
  end

  def addItem(item)
    changed_clothes = obtainNewHat(item.id)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $Trainer.hat
  end

  def putOnOutfit(item)
    putOnHat(item.id)
    @worn_clothes = item.id
  end

  def reset_player_clothes()
    $Trainer.hat = @worn_clothes
  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_hats
  end
end
