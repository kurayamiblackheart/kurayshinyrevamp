# Warning - K-Chest are injected from within 001_KurayEggs.rb

$KURAYCHESTS_LIST = []
$KURAYCHESTS_NUMBERCHESTS = 20
$KURAYCHESTS_BASEPRICE = []

# Categories (Resell price) | Min-Max Drops | Infos
# 0 - Species Chest (Re-sell for $200) | 1-3 | Species related, 3% drop rate.
# 1 - K-Rogue Chest (Re-sell for $400) | 2-4 | Location related, 5% drop rate when battle won.
# 2 - Rare K-Rogue Chest (Re-sell for $800) | 2-5 | Location related, 1% drop rate when battle won.
# 3 - Boss Reward K-Chest (Re-sell for $1600) | 3-5 | Location related, guaranteed if won.

module GameData
    def self.kuraychests_makehash(min_drops=1, max_drops=1, category=0, common_items=[], uncommon_items=[], rare_items=[], veryrare_items=[], weight=255)
        return {
            :MIN_DROPS => min_drops,
            :MAX_DROPS => max_drops,
            :CATEGORY => category,
            :COMMON => common_items,
            :UNCOMMON => uncommon_items,
            :RARE => rare_items,
            :VERYRARE => veryrare_items,
            :WEIGHT => weight
        }
    end

    def self.kuraychests_processsymb(egg_name)
        return self.kurayglobal_processsymb(egg_name, "KURAYCHEST_")
    end

    def self.kuraychests_loadchests()
        # chest_common syntax example: [[:ITEM_SYMBOL, MIN, MAX]]
        # min and max are the amount that can be given.
        id_here = Settings::KURAY_CHESTS_ID-1


        chest_name_last = "K-Chest"

        id_here += 1
        chest_price = 100#sell price
        chest_name = "Small"
        chest_symbol = self.kuraychests_processsymb(chest_name)
        chest_name_display = chest_name + " " + chest_name_last
        chest_description = "K-Chest held by Pokémon with a BST between 0 and 300."
        $KURAYCHESTS_BASEPRICE.push(chest_price*2)
        self.kurayeggs_iteminject(chest_symbol, id_here, chest_name_display, chest_price, chest_description, 1)
        chest_common = []#60% drop rate
        chest_uncommon = []#30% drop rate
        chest_rare = []#8% drop rate
        chest_veryrare = []#2% drop rate
        chest_min_drops = 1
        chest_max_drops = 2
        chest_weight = 255
        $KURAYCHESTS_LIST.push(self.kuraychests_makehash(chest_min_drops, chest_max_drops, 0, chest_common, chest_uncommon, chest_rare, chest_veryrare, chest_weight))

    end
end

def kuraychests_triggerchest(id, itemid)
    # This function is called when a K-Chest is used.
    item_name = GameData::Item.get(itemid).name
    pbUseItemMessage(itemid)
    # id is the integer ID of the chest.
    # Retrieve the pool of the chest
end