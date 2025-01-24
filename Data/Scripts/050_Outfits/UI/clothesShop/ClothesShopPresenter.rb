class ClothesShopPresenter < PokemonMartScreen
  def pbChooseBuyItem

  end

  def initialize(scene, stock, adapter = nil, versions=false)
    super(scene,stock,adapter)
    @use_versions = versions
  end


  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item

      if !@adapter.isShop?
        if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
          @adapter.putOnOutfit(item)
          @scene.pbEndBuyScene
          return
        end
        next

      end

      itemname = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)
      if !price.is_a?(Integer)
        pbDisplayPaused(_INTL("You already own this item!"))
        if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
          @adapter.putOnOutfit(item)
        end
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end

      if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
                          itemname, price.to_s_formatted))
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      @adapter.setMoney(@adapter.getMoney - price)
      @stock.compact!
      pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
      @adapter.addItem(item)
      #break
    end
    @scene.pbEndBuyScene
  end

end