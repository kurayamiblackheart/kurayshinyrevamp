def genericOutfitsShopMenu(stock = [], itemType = nil, versions = false)
  commands = []
  commands[cmdBuy = commands.length] = _INTL("Buy")
  commands[cmdQuit = commands.length] = _INTL("Quit")
  cmd = pbMessage(_INTL("Welcome! How may I serve you?"), commands, cmdQuit + 1)
  loop do
    if cmdBuy >= 0 && cmd == cmdBuy
      adapter = getAdapter(itemType, stock, true)
      view = ClothesShopView.new()
      presenter = getPresenter(itemType, view, stock, adapter, versions)
      presenter.pbBuyScreen
      break
    else
      pbMessage(_INTL("Please come again!"))
      break
    end
    cmd = pbMessage(_INTL("Is there anything else I can help you with?"),
                    commands, cmdQuit + 1)
  end
end

def getPresenter(itemType, view, stock, adapter, versions)
  case itemType
  when :HAIR
    return HairShopPresenter.new(view, stock, adapter, versions)
  else
    return ClothesShopPresenter.new(view, stock, adapter, versions)
  end
end

def getAdapter(itemType, stock, isShop)
  case itemType
  when :CLOTHES
    return ClothesMartAdapter.new(stock, isShop)
  when :HAT
    return HatsMartAdapter.new(stock, isShop)
  when :HAIR
    return HairMartAdapter.new(stock, isShop)
  end
end

def list_all_possible_outfits() end

def clothesShop(outfits_list = [])
  stock = []
  outfits_list.each { |outfit_id|
    outfit = get_clothes_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :CLOTHES)
end

def hatShop(outfits_list = [])
  stock = []
  outfits_list.each { |outfit_id|
    outfit = get_hat_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :HAT)
end

def hairShop(outfits_list = [])
  stock = []
  outfits_list.each { |outfit_id|
    echoln outfit_id
    outfit = get_hair_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :HAIR, true)
end

def openSelectOutfitMenu(stock = [], itemType)
  adapter = getAdapter(itemType, stock, false)
  view = ClothesShopView.new()
  presenter = ClothesShopPresenter.new(view, stock, adapter)
  presenter.pbBuyScreen
end

def changeClothesMenu()
  stock = []
  $Trainer.unlocked_clothes.each { |outfit_id|
    outfit = get_clothes_by_id(outfit_id)
    stock << outfit if outfit
  }
  openSelectOutfitMenu(stock, :CLOTHES)
end

def changeHatMenu()
  stock = []
  $Trainer.unlocked_hats.each { |outfit_id|
    outfit = get_hat_by_id(outfit_id)
    stock << outfit if outfit
  }
  openSelectOutfitMenu(stock, :HAT)
end

def changeOutfit()
  commands = []
  commands[cmdClothes = commands.length] = _INTL("Change clothes")
  commands[cmdHat = commands.length] = _INTL("Change hat")
  commands[cmdQuit = commands.length] = _INTL("Quit")

  cmd = pbMessage(_INTL("What would you like to do?"), commands, cmdQuit + 1)
  loop do
    if cmd == cmdClothes
      changeClothesMenu()
      break
    elsif cmd == cmdHat
      changeHatMenu()
      break
    else
      break
    end
  end
end