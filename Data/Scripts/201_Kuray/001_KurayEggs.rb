# ============================
# Kuray's Eggs System
# ============================

$KURAYEGGS_EXPORTPOKEMONDATA = false
$KURAYEGGS_WRITEDATA = false
$KURAYEGGS_SPARKLING = false
$KURAYEGGS_FORCEDFUSION = 0
$KURAYEGGS_DEBUG = false
$KURAYEGGS_VALIDATE = false
$KURAYEGGS_BASEPRICE = []
$KURAYEGGS_MINBST = [0, 280, 300, 380, 430, 450, 470, 480, 490, 500]
$KURAYEGGS_MAXBST = [288, 319, 400, 470, 480, 490, 505, 530, 555, 1000000]
$KURAYEGGS_MINBSTSHOW = [180, 280, 300, 380, 430, 450, 470, 480, 490, 500]
$KURAYEGGS_MAXBSTSHOW = [288, 319, 400, 470, 480, 490, 505, 530, 555, 754]

$KURAYEGGS_LISTS = {}

$KURAY_VANILLA_PIF_TRIPLES = [:ZAPMOLTICUNO, :BIRDBOSS, :ENRAICUNE, :KYODONQUAZA, :PALDIATINA, :ZEKYUSHIRAM, :CELEMEWCHI,
    :VENUSTOIZARD, :MEGALIGASION, :SWAMPTILIKEN, :TORTERNEON, :DEOSECTWO,
    :TRIPLE_KANTO1, :TRIPLE_KANTO2, :TRIPLE_JOHTO1, :TRIPLE_JOHTO2, :TRIPLE_HOENN1, :TRIPLE_HOENN2,
    :TRIPLE_SINNOH1, :TRIPLE_SINNOH2, :BIRDBOSS_1, :BIRDBOSS_2, :BIRDBOSS_3, :SILVERBOSS_1, :SILVERBOSS_2, :SILVERBOSS_3,
    :TYRANTRUM_CARDBOARD, :REGITRIO
    ]

# [ Name, Poke1's ID, Poke2's ID, Poke3's ID ]
$KURAY_MODDED_TRIPLES = [["Dimewtwo", 132, 150, 151], ["Ekashrat", 23, 27, 41], ["Ekaowffing", 23, 52, 109],
    ["Cleglybiny", 173, 174, 259], ["Cleglypsey", 35, 39, 113], ["Cleglytissey", 36, 40, 242], ["Rattretoof", 19, 161, 294],
    ["Cateednat", 10, 13, 48], ["Mekunat", 11, 14, 48], ["Buttdrillmoth", 12, 15, 49], ["Cleglyepi", 173, 174, 175],
    ["Ratkashrew", 19, 23, 27], ["Ratirboslash", 20, 24, 28], ["Fearmorrow", 22, 227, 256], ["Ninecanray", 38, 59, 332],
    ["Groffibish", 88, 109, 434], ["Mukeedor", 89, 110, 435], ["Abchotly", 63, 66, 92], ["Alachagar", 65, 68, 94],
    ["Voloffeco", 100, 109, 204], ["Vajofleon", 134, 135, 136], ["Esumsyeon", 196, 197, 339], ["Ombutactyl", 139, 141, 142],
    ["Dranitence", 149, 248, 336], ["Artigondon", 144, 148, 341], ["Gyaikogre", 130, 243, 340],
    ["Psyfetird", 54, 83, 225], ["Golfetird", 55, 83, 225], ["Zuligbat", 41, 207, 440], ["Goscobat", 42, 273, 440], ["Croscovern", 169, 273, 441],
    ["Vilarasoom", 45, 47, 355], ["Viltreerade", 45, 71, 352], ["Hitchanleetop", 106, 107, 237], ["Leriazor", 166, 168, 212], ["Bellitking", 182, 186, 199],
    ["Arcundoark", 59, 229, 338], ["Houbsoloark", 229, 310, 338], ["Magoraibas", 129, 223, 394], ["Gyactillotic", 130, 224, 335],
    ["Scinesrona", 212, 348, 374], ["Skifloreon", 188, 192, 290], ["Dugnetrio", 51, 82, 85], ["Gengmagette", 94, 255, 357], ["Misdelash", 255, 367, 329],
    ["Nomaskett", 325, 411, 416], ["Profagrilurk", 326, 362, 369], ["Gasungar", 92, 93, 94], ["Golriturk", 76, 295, 369], ["Belangross", 291, 292, 293],
    ["Metawigron", 293, 300, 333], ["Shirunura", 307, 425, 461], ["Bastranorus", 308, 426, 462], ["Axeiblon", 414, 297, 395], ["Fraxbitgon", 415, 298, 396],
    ["Haxchomence", 368, 299, 336], ["Hydriaos", 377, 378, 379], ["Genoxyetta", 348, 380, 466]]


def kuray_global_triples(dexNum)
    base_path = "Graphics/Battlers/special/"
    case dexNum
    when Settings::ZAPMOLCUNO_NB..Settings::ZAPMOLCUNO_NB + 1
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 2
      return sprintf(base_path + "243.244.245")
    when Settings::ZAPMOLCUNO_NB + 3
      return sprintf(base_path +"340.341.342")
    when Settings::ZAPMOLCUNO_NB + 4
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 5
      return sprintf(base_path +"349.350.351")
    when Settings::ZAPMOLCUNO_NB + 6
      return sprintf(base_path +"151.251.381")
    when Settings::ZAPMOLCUNO_NB + 11
      return sprintf(base_path +"150.348.380")
      #starters
    when Settings::ZAPMOLCUNO_NB + 7
      return sprintf(base_path +"3.6.9")
    when Settings::ZAPMOLCUNO_NB + 8
      return sprintf(base_path +"154.157.160")
    when Settings::ZAPMOLCUNO_NB + 9
      return sprintf(base_path +"278.281.284")
    when Settings::ZAPMOLCUNO_NB + 10
      return sprintf(base_path +"318.321.324")
      #starters prevos
    when Settings::ZAPMOLCUNO_NB + 12
      return sprintf(base_path +"1.4.7")
    when Settings::ZAPMOLCUNO_NB + 13
      return sprintf(base_path +"2.5.8")
    when Settings::ZAPMOLCUNO_NB + 14
      return sprintf(base_path +"152.155.158")
    when Settings::ZAPMOLCUNO_NB + 15
      return sprintf(base_path +"153.156.159")
    when Settings::ZAPMOLCUNO_NB + 16
      return sprintf(base_path +"276.279.282")
    when Settings::ZAPMOLCUNO_NB + 17
      return sprintf(base_path +"277.280.283")
    when Settings::ZAPMOLCUNO_NB + 18
      return sprintf(base_path +"316.319.322")
    when Settings::ZAPMOLCUNO_NB + 19
      return sprintf(base_path +"317.320.323")
    when Settings::ZAPMOLCUNO_NB + 20 #birdBoss Left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 21 #birdBoss middle
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 22 #birdBoss right
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 23 #sinnohboss left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 24 #sinnohboss middle
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 25 #sinnohboss right
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 25 #cardboard
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 26 #cardboard
      return sprintf(base_path + "cardboard")
    when Settings::ZAPMOLCUNO_NB + 27 #Triple regi
      return sprintf(base_path + "447.448.449")
    when Settings::ZAPMOLCUNO_NB + 28
      return sprintf(base_path + "479.482.485")
    when Settings::ZAPMOLCUNO_NB + 29
      return sprintf(base_path + "480.483.486")
    when Settings::ZAPMOLCUNO_NB + 30
      return sprintf(base_path + "481.484.487")
    when Settings::KURAY_NEW_TRIPLES + 1 # Ditto / Mewtwo / Mew
        return sprintf(base_path + "132.150.151")
    when Settings::KURAY_NEW_TRIPLES + 2 # Ekans / Sandshrew / Zubat
        return sprintf(base_path + "23.27.41")
    when Settings::KURAY_NEW_TRIPLES + 3 # Ekans / Meowth / Koffing
        return sprintf(base_path + "23.52.109")
    when Settings::KURAY_NEW_TRIPLES + 4 # Cleffa / Igglybuff / Happiny
        return sprintf(base_path + "173.174.259")
    when Settings::KURAY_NEW_TRIPLES + 5 # Clefairy / Jigglypuff / Chansey
        return sprintf(base_path + "35.39.113")
    when Settings::KURAY_NEW_TRIPLES + 6 # Clefable / Wigglytuff / Blissey
        return sprintf(base_path + "36.40.242")
    when Settings::KURAY_NEW_TRIPLES + 7 # Rattata / Sentret / Bidoof
        return sprintf(base_path + "19.161.294")
    when Settings::KURAY_NEW_TRIPLES + 8 # Caterpie / Weedle / Venonat
        return sprintf(base_path + "10.13.48")
    when Settings::KURAY_NEW_TRIPLES + 9 # Metapod / Kakuna / Venonat
        return sprintf(base_path + "11.14.48")
    when Settings::KURAY_NEW_TRIPLES + 10 # Butterfree / Beedrill / Venomoth
        return sprintf(base_path + "12.15.49")
    when Settings::KURAY_NEW_TRIPLES + 11 # Cleffa / Igglybuff / Togepi
        return sprintf(base_path + "173.174.175")
    when Settings::KURAY_NEW_TRIPLES + 12 # Rattata / Ekans / Sandshrew
        return sprintf(base_path + "19.23.27")
    when Settings::KURAY_NEW_TRIPLES + 13 # Raticate / Arbok / Sandslash
        return sprintf(base_path + "20.24.28")
    when Settings::KURAY_NEW_TRIPLES + 14 # Fearow / Skarmory / Honchkrow
        return sprintf(base_path + "22.227.256")
    when Settings::KURAY_NEW_TRIPLES + 15 # Ninetales / Arcanine / Luxray
        return sprintf(base_path + "38.59.332")
    when Settings::KURAY_NEW_TRIPLES + 16 # Grimer / Koffing / Trubbish
        return sprintf(base_path + "88.109.434")
    when Settings::KURAY_NEW_TRIPLES + 17 # Muk / Weezing / Garbodor
        return sprintf(base_path + "89.110.435")
    when Settings::KURAY_NEW_TRIPLES + 18 # Abra / Machop / Gastly
        return sprintf(base_path + "63.66.92")
    when Settings::KURAY_NEW_TRIPLES + 19 # Alakazam / Machamp / Gengar
        return sprintf(base_path + "65.68.94")
    when Settings::KURAY_NEW_TRIPLES + 20 # Voltorb / Koffing / Pineco
        return sprintf(base_path + "100.109.204")
    when Settings::KURAY_NEW_TRIPLES + 21 # Vaporeon / Jolteon / Flareon
        return sprintf(base_path + "134.135.136")
    when Settings::KURAY_NEW_TRIPLES + 22 # Espeon / Umbreon / Sylveon
        return sprintf(base_path + "196.197.339")
    when Settings::KURAY_NEW_TRIPLES + 23 # Omastar / Kabutops / Aerodactyl
        return sprintf(base_path + "139.141.142")
    when Settings::KURAY_NEW_TRIPLES + 24 # Dragonite / Tyranitar / Salamence
        return sprintf(base_path + "149.248.336")
    when Settings::KURAY_NEW_TRIPLES + 25 # Articuno / Dragonair / Groudon
        return sprintf(base_path + "144.148.341")
    when Settings::KURAY_NEW_TRIPLES + 26 # Gyarados / Raikou / Kyogre
        return sprintf(base_path + "130.243.340")
    when Settings::KURAY_NEW_TRIPLES + 27 # Psyduck / Farfetch'd / Delibird
        return sprintf(base_path + "54.83.225")
    when Settings::KURAY_NEW_TRIPLES + 28 # Golduck / Farfetch'd / Delibird
        return sprintf(base_path + "55.83.225")
    when Settings::KURAY_NEW_TRIPLES + 29 # Zubat / Gligar / Noibat
        return sprintf(base_path + "41.207.440")
    when Settings::KURAY_NEW_TRIPLES + 30 # Golbat / Gliscor / Noibat
        return sprintf(base_path + "42.273.440")
    when Settings::KURAY_NEW_TRIPLES + 31 # Crobat / Gliscor / Noivern
        return sprintf(base_path + "169.273.441")
    when Settings::KURAY_NEW_TRIPLES + 32 # Vileplume / Parasect / Breloom
        return sprintf(base_path + "45.47.355")
    when Settings::KURAY_NEW_TRIPLES + 33 # Vileplume / Victreebel / Roserade
        return sprintf(base_path + "45.71.352")
    when Settings::KURAY_NEW_TRIPLES + 34 # Hitmonlee / Hitmonchan / Hitmontop
        return sprintf(base_path + "106.107.237")
    when Settings::KURAY_NEW_TRIPLES + 35 # Ledian / Ariados / Scizor
        return sprintf(base_path + "166.168.212")
    when Settings::KURAY_NEW_TRIPLES + 36 # Bellossom / Politoed / Slowking
        return sprintf(base_path + "182.186.199")
    when Settings::KURAY_NEW_TRIPLES + 37 # Arcanine / Houndoom / Zoroark
        return sprintf(base_path + "59.229.338")
    when Settings::KURAY_NEW_TRIPLES + 38 # Houndoom / Absol / Zoroark
        return sprintf(base_path + "229.310.338")
    when Settings::KURAY_NEW_TRIPLES + 39 # Magicarp / Remoraid / Feebas
        return sprintf(base_path + "129.223.394")
    when Settings::KURAY_NEW_TRIPLES + 40 # Gyarados / Octillery / Milotic
        return sprintf(base_path + "130.224.335")
    when Settings::KURAY_NEW_TRIPLES + 41 # Scizor / Genesect / Volcarona
        return sprintf(base_path + "212.348.374")
    when Settings::KURAY_NEW_TRIPLES + 42 # Skiploom / Sunflora / Kecleon
        return sprintf(base_path + "188.192.290")
    when Settings::KURAY_NEW_TRIPLES + 43 # Dugtrio / Magneton / Dodrio
        return sprintf(base_path + "51.82.85")
    when Settings::KURAY_NEW_TRIPLES + 44 # Gengar / Mismagius / Banette
        return sprintf(base_path + "94.255.357")
    when Settings::KURAY_NEW_TRIPLES + 45 # Mismagius / Chandelure / Aegislash
        return sprintf(base_path + "255.367.329")
    when Settings::KURAY_NEW_TRIPLES + 46 # Nosepass / Yamask / Golett
        return sprintf(base_path + "325.411.416")
    when Settings::KURAY_NEW_TRIPLES + 47 # Probopass / Cofagrigus / Golurk
        return sprintf(base_path + "326.362.369")
    when Settings::KURAY_NEW_TRIPLES + 48 # Gastly / Haunter / Gengar
        return sprintf(base_path + "92.93.94")
    when Settings::KURAY_NEW_TRIPLES + 49 # Golem / Spiritomb / Golurk
        return sprintf(base_path + "76.295.369")
    when Settings::KURAY_NEW_TRIPLES + 50 # Beldum / Metang / Metagross
        return sprintf(base_path + "291.292.293")
    when Settings::KURAY_NEW_TRIPLES + 51 # Metagross / Mawile / Aggron
        return sprintf(base_path + "293.300.333")
    when Settings::KURAY_NEW_TRIPLES + 52 # Shieldon / Tyrunt / Amaura
        return sprintf(base_path + "307.425.461")
    when Settings::KURAY_NEW_TRIPLES + 53 # Bastiodon / Tyrantrum / Aurorus
        return sprintf(base_path + "308.426.462")
    when Settings::KURAY_NEW_TRIPLES + 54 # Axew / Gible / Bagon
        return sprintf(base_path + "414.297.395")
    when Settings::KURAY_NEW_TRIPLES + 55 # Fraxure / Gabite / Shelgon
        return sprintf(base_path + "415.298.396")
    when Settings::KURAY_NEW_TRIPLES + 56 # Haxorus / Garchomp / Salamence
        return sprintf(base_path + "368.299.336")
    when Settings::KURAY_NEW_TRIPLES + 57 # Hydreigon / Latias / Latios
        return sprintf(base_path + "377.378.379")
    when Settings::KURAY_NEW_TRIPLES + 58 # Genesect / Deoxys / Meloetta
        return sprintf(base_path + "348.380.466")
    else
      if dexNum > Settings::KURAY_CUSTOM_POKEMONS
        return sprintf(base_path + "k_%03d", dexNum-Settings::KURAY_CUSTOM_POKEMONS)
      end
      return sprintf(base_path + "000")
    end
  end

module GameData
    def self.kuray_normalizeId(strCurrentId)
        # We want the string to be 20 of length and to be filled with white spaces.
        # .ljust method allows to fill the string with white spaces.
        return strCurrentId.ljust(20)
    end

    def self.kuray_datafrompokemon(i, strAllPokemons)
        species = GameData::Species.get(i)
        strAllPokemons += "Species.register({\n"
        strId = self.kuray_normalizeId(":id")
        strAllPokemons += "\t#{strId} => :#{species.id},\n"
        strId = self.kuray_normalizeId(":id_number")
        strAllPokemons += "\t#{strId} => #{species.id_number},\n"
        strId = self.kuray_normalizeId(":name")
        strAllPokemons += "\t#{strId} => \"#{species.name}\",\n"
        strId = self.kuray_normalizeId(":form_name")
        if species.form_name == nil
            strAllPokemons += "\t#{strId} => nil,\n"
        else
            strAllPokemons += "\t#{strId} => \"#{species.form_name}\",\n"    
        end
        strId = self.kuray_normalizeId(":category")
        strAllPokemons += "\t#{strId} => \"#{species.category}\",\n"
        strId = self.kuray_normalizeId(":pokedex_entry")
        strAllPokemons += "\t#{strId} => \"#{species.pokedex_entry}\",\n"
        strId = self.kuray_normalizeId(":type1")
        strAllPokemons += "\t#{strId} => :#{species.type1},\n"
        strId = self.kuray_normalizeId(":type2")
        strAllPokemons += "\t#{strId} => :#{species.type2},\n"
        strId = self.kuray_normalizeId(":base_stats")
        strAllPokemons += "\t#{strId} => #{species.base_stats.to_s},\n"
        strId = self.kuray_normalizeId(":evs")
        strAllPokemons += "\t#{strId} => #{species.evs.to_s},\n"
        strId = self.kuray_normalizeId(":base_exp")
        strAllPokemons += "\t#{strId} => #{species.base_exp},\n"
        strId = self.kuray_normalizeId(":growth_rate")
        strAllPokemons += "\t#{strId} => :#{species.growth_rate},\n"
        strId = self.kuray_normalizeId(":gender_ratio")
        strAllPokemons += "\t#{strId} => :#{species.gender_ratio},\n"
        strId = self.kuray_normalizeId(":catch_rate")
        strAllPokemons += "\t#{strId} => #{species.catch_rate},\n"
        strId = self.kuray_normalizeId(":happiness")
        strAllPokemons += "\t#{strId} => #{species.happiness},\n"
        strId = self.kuray_normalizeId(":moves")
        strAllPokemons += "\t#{strId} => #{species.moves.to_s},\n"
        strId = self.kuray_normalizeId(":tutor_moves")
        strAllPokemons += "\t#{strId} => #{species.tutor_moves.to_s},\n"
        strId = self.kuray_normalizeId(":egg_moves")
        strAllPokemons += "\t#{strId} => #{species.egg_moves.to_s},\n"
        strId = self.kuray_normalizeId(":abilities")
        strAllPokemons += "\t#{strId} => #{species.abilities.to_s},\n"
        strId = self.kuray_normalizeId(":hidden_abilities")
        strAllPokemons += "\t#{strId} => #{species.hidden_abilities.to_s},\n"

        strId = self.kuray_normalizeId(":wild_item_common")
        if species.wild_item_common == nil
            strAllPokemons += "\t#{strId} => nil,\n"
        else
            strAllPokemons += "\t#{strId} => :#{species.wild_item_common},\n"
        end
        strId = self.kuray_normalizeId(":wild_item_uncommon")
        if species.wild_item_uncommon == nil
            strAllPokemons += "\t#{strId} => nil,\n"
        else
            strAllPokemons += "\t#{strId} => :#{species.wild_item_uncommon},\n"
        end
        strId = self.kuray_normalizeId(":wild_item_rare")
        if species.wild_item_rare == nil
            strAllPokemons += "\t#{strId} => nil,\n"
        else
            strAllPokemons += "\t#{strId} => :#{species.wild_item_rare},\n"
        end

        strId = self.kuray_normalizeId(":egg_groups")
        strAllPokemons += "\t#{strId} => #{species.egg_groups.to_s},\n"
        strId = self.kuray_normalizeId(":hatch_steps")
        strAllPokemons += "\t#{strId} => #{species.hatch_steps},\n"
        strId = self.kuray_normalizeId(":evolutions")
        strAllPokemons += "\t#{strId} => #{species.evolutions.to_s},\n"
        strId = self.kuray_normalizeId(":height")
        strAllPokemons += "\t#{strId} => #{species.height},\n"
        strId = self.kuray_normalizeId(":weight")
        strAllPokemons += "\t#{strId} => #{species.weight},\n"
        strId = self.kuray_normalizeId(":color")
        strAllPokemons += "\t#{strId} => :#{species.color},\n"
        strId = self.kuray_normalizeId(":shape")
        strAllPokemons += "\t#{strId} => :#{species.shape},\n"
        strId = self.kuray_normalizeId(":habitat")
        strAllPokemons += "\t#{strId} => :#{species.habitat},\n"
        strId = self.kuray_normalizeId(":generation")
        strAllPokemons += "\t#{strId} => #{species.generation},\n"
        strId = self.kuray_normalizeId(":back_sprite_x")
        strAllPokemons += "\t#{strId} => #{species.back_sprite_x},\n"
        strId = self.kuray_normalizeId(":back_sprite_y")
        strAllPokemons += "\t#{strId} => #{species.back_sprite_y},\n"
        strId = self.kuray_normalizeId(":front_sprite_x")
        strAllPokemons += "\t#{strId} => #{species.front_sprite_x},\n"
        strId = self.kuray_normalizeId(":front_sprite_y")
        strAllPokemons += "\t#{strId} => #{species.front_sprite_y},\n"
        strId = self.kuray_normalizeId(":front_sprite_altitude")
        strAllPokemons += "\t#{strId} => #{species.front_sprite_altitude},\n"
        strId = self.kuray_normalizeId(":shadow_x")
        strAllPokemons += "\t#{strId} => #{species.shadow_x},\n"
        strId = self.kuray_normalizeId(":shadow_size")
        strAllPokemons += "\t#{strId} => #{species.shadow_size}\n"
        strAllPokemons += "})\n"
        strAllPokemons += "\n"
        return strAllPokemons
    end

    def self.kuray_extrapolatetriple(id_start, i, strAllPokemons, poke1, poke2, poke3)
        target_sym = self.kuray_name_to_sym("KURAY_" + i)
        strAllPokemons += "Species.register({\n"
        strId = self.kuray_normalizeId(":id")
        id_here = Settings::KURAY_NEW_TRIPLES + id_start
        strAllPokemons += "\t#{strId} => :#{target_sym},\n"
        strId = self.kuray_normalizeId(":id_number")
        strAllPokemons += "\t#{strId} => #{id_here},\n"
        strId = self.kuray_normalizeId(":name")
        strAllPokemons += "\t#{strId} => \"#{i}\",\n"
        strId = self.kuray_normalizeId(":form_name")
        strAllPokemons += "\t#{strId} => nil,\n"
        strId = self.kuray_normalizeId(":category")
        strAllPokemons += "\t#{strId} => \"#{poke1.category} #{poke2.category} #{poke3.category}\",\n"
        strId = self.kuray_normalizeId(":pokedex_entry")
        strAllPokemons += "\t#{strId} => \"#{i} is a three-way fusion between #{poke1.name}, #{poke2.name} and #{poke3.name}.\",\n"
        strId = self.kuray_normalizeId(":type1")
        strAllPokemons += "\t#{strId} => :#{poke1.type1} :#{poke2.type1} :#{poke3.type1},\n"
        strId = self.kuray_normalizeId(":type2")
        strAllPokemons += "\t#{strId} => :#{poke1.type2} :#{poke2.type2} :#{poke3.type2},\n"
        strId = self.kuray_normalizeId(":base_stats")
        # Take the average of the three pokemons' base stats.
        # from poke1.base_stats, poke2.base_stats, poke3.base_stats
        poke_bs_avg = {}
        for i in poke1.base_stats.keys
            # poke_bs_avg[i] = (poke1.base_stats[i] + poke2.base_stats[i] + poke3.base_stats[i]).to_f * 1.1
            poke_bs_avg[i] = (poke1.base_stats[i] + poke2.base_stats[i] + poke3.base_stats[i]).to_f
            poke_bs_avg[i] = (poke_bs_avg[i] / 3.0).round.to_i
        end
        strAllPokemons += "\t#{strId} => #{poke_bs_avg.to_s},\n"
        # Keeps the EV yield of the three Pokémons
        poke_ev_yields = {}
        for i in poke1.evs.keys
            poke_ev_yields[i] = poke1.evs[i] + poke2.evs[i] + poke3.evs[i]
        end
        strId = self.kuray_normalizeId(":evs")
        strAllPokemons += "\t#{strId} => #{poke_ev_yields.to_s},\n"
        # average_base_exp = (poke1.base_exp + poke2.base_exp + poke3.base_exp).to_f * 1.1
        average_base_exp = (poke1.base_exp + poke2.base_exp + poke3.base_exp) / 3
        strId = self.kuray_normalizeId(":base_exp")
        strAllPokemons += "\t#{strId} => #{average_base_exp},\n"
        strId = self.kuray_normalizeId(":growth_rate")
        strAllPokemons += "\t#{strId} => :#{poke1.growth_rate} :#{poke2.growth_rate} :#{poke3.growth_rate},\n"
        strId = self.kuray_normalizeId(":gender_ratio")
        strAllPokemons += "\t#{strId} => :Genderless,\n"
        strId = self.kuray_normalizeId(":catch_rate")
        poke_catch_rate = (((poke1.catch_rate + poke2.catch_rate + poke3.catch_rate).to_f * 0.66) / 3.00).ceil.to_i
        strAllPokemons += "\t#{strId} => #{poke_catch_rate},\n"
        strId = self.kuray_normalizeId(":happiness")
        average_happiness = (poke1.happiness + poke2.happiness + poke3.happiness) / 3
        strAllPokemons += "\t#{strId} => #{average_happiness},\n"
        strId = self.kuray_normalizeId(":moves")
        # Take the moves nested arrays of all pokemons and match them together in a single giant array
        poke_moves = poke1.moves + poke2.moves + poke3.moves
        # Sort the array according to the first value of each nested arrays
        poke_moves = poke_moves.sort_by { |x| x[0] }
        # remove any duplicates entries
        poke_moves = poke_moves.uniq
        strAllPokemons += "\t#{strId} => #{poke_moves.to_s},\n"
        strId = self.kuray_normalizeId(":tutor_moves")
        poke_tutors = poke1.tutor_moves + poke2.tutor_moves + poke3.tutor_moves
        # remove any duplicates entries
        poke_tutors = poke_tutors.uniq
        strAllPokemons += "\t#{strId} => #{poke_tutors.to_s},\n"
        strId = self.kuray_normalizeId(":egg_moves")
        poke_eggsmoves = poke1.egg_moves + poke2.egg_moves + poke3.egg_moves
        # remove any duplicates entries
        poke_eggsmoves = poke_eggsmoves.uniq
        strAllPokemons += "\t#{strId} => #{poke_eggsmoves.to_s},\n"
        strId = self.kuray_normalizeId(":abilities")
        poke_abilities = poke1.abilities + poke2.abilities + poke3.abilities
        # remove any duplicates entries
        poke_abilities = poke_abilities.uniq
        strAllPokemons += "\t#{strId} => #{poke_abilities.to_s},\n"
        strId = self.kuray_normalizeId(":hidden_abilities")
        poke_hiddenabilities = poke1.hidden_abilities + poke2.hidden_abilities + poke3.hidden_abilities
        # remove any duplicates entries
        poke_hiddenabilities = poke_hiddenabilities.uniq
        strAllPokemons += "\t#{strId} => #{poke_hiddenabilities.to_s},\n"

        strId = self.kuray_normalizeId(":wild_item_common")
        strAllPokemons += "\t#{strId} => nil,\n"
        strId = self.kuray_normalizeId(":wild_item_uncommon")
        strAllPokemons += "\t#{strId} => nil,\n"
        strId = self.kuray_normalizeId(":wild_item_rare")
        strAllPokemons += "\t#{strId} => nil,\n"

        strId = self.kuray_normalizeId(":egg_groups")
        strAllPokemons += "\t#{strId} => [:Undiscovered],\n"
        strId = self.kuray_normalizeId(":hatch_steps")
        poke_hatch = (poke1.hatch_steps + poke2.hatch_steps + poke3.hatch_steps) / 3
        strAllPokemons += "\t#{strId} => #{poke_hatch},\n"
        strId = self.kuray_normalizeId(":evolutions")
        strAllPokemons += "\t#{strId} => [],\n"
        strId = self.kuray_normalizeId(":height")
        poke_height = (poke1.height + poke2.height + poke3.height) / 3
        strAllPokemons += "\t#{strId} => #{poke_height},\n"
        strId = self.kuray_normalizeId(":weight")
        poke_weight = (poke1.weight + poke2.weight + poke3.weight) / 3
        strAllPokemons += "\t#{strId} => #{poke_weight},\n"
        strId = self.kuray_normalizeId(":color")
        strAllPokemons += "\t#{strId} => :#{poke1.color},\n"
        strId = self.kuray_normalizeId(":shape")
        strAllPokemons += "\t#{strId} => :#{poke1.shape},\n"
        strId = self.kuray_normalizeId(":habitat")
        strAllPokemons += "\t#{strId} => :#{poke1.habitat},\n"
        strId = self.kuray_normalizeId(":generation")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":back_sprite_x")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":back_sprite_y")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":front_sprite_x")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":front_sprite_y")
        strAllPokemons += "\t#{strId} => 6,\n"
        strId = self.kuray_normalizeId(":front_sprite_altitude")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":shadow_x")
        strAllPokemons += "\t#{strId} => 0,\n"
        strId = self.kuray_normalizeId(":shadow_size")
        strAllPokemons += "\t#{strId} => 5\n"
        strAllPokemons += "})\n"
        strAllPokemons += "\n"
        return strAllPokemons
    end

    def self.kuray_create_triplefusions_data()
        strAllPokemons = ""
        id_start = 0
        # KURAY_NEW_TRIPLES is the ID to which we start the new triples. NOT inclusive.

        # $KURAY_MODDED_TRIPLES's syntax:
        # [ [ Name, Poke1's ID, Poke2's ID, Poke3's ID ], [...] ]
        for i in $KURAY_MODDED_TRIPLES
            # ID starts at 1.
            id_start += 1
            poke1 = GameData::Species.get(i[1])
            poke2 = GameData::Species.get(i[2])
            poke3 = GameData::Species.get(i[3])
            strAllPokemons = self.kuray_extrapolatetriple(id_start, i[0], strAllPokemons, poke1, poke2, poke3)
        end
        kuray_writefile("ModdedTriples.txt", strAllPokemons)
    
    end

    def self.kuray_exportpokemondata(type=0)
        # type = 0 -> All Pokemons (0-NB_POKEMON)
        # type = 1 -> Triple fusions
        strAllPokemons = ""
        pokemontypes = {
            :NORMAL => [],
            :FIGHTING => [],
            :FLYING => [],
            :POISON => [],
            :GROUND => [],
            :ROCK => [],
            :BUG => [],
            :GHOST => [],
            :STEEL => [],
            :FIRE => [],
            :WATER => [],
            :GRASS => [],
            :ELECTRIC => [],
            :PSYCHIC => [],
            :ICE => [],
            :DRAGON => [],
            :DARK => [],
            :FAIRY => []
        }
        if type == 0
            for i in 1..NB_POKEMON
                poke1 = GameData::Species.get(i)
                if poke1.type1 == poke1.type2
                    pokemontypes[poke1.type1] << i
                  else
                    pokemontypes[poke1.type1] << i
                    pokemontypes[poke1.type2] << i
                  end
                strAllPokemons = self.kuray_datafrompokemon(i, strAllPokemons)
            end
            kuray_writefile("AllPokemons.txt", strAllPokemons)
        else
            for i in $KURAY_VANILLA_PIF_TRIPLES
                strAllPokemons = self.kuray_datafrompokemon(i, strAllPokemons)
            end
            kuray_writefile("AllTriples.txt", strAllPokemons)
        end
        for i in pokemontypes
            kuray_writefile("AllType_" + i[0].to_s + ".txt", i[1].to_s)
        end

    end

    def self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description, itemtype=0)
        egg_name_display_plural = egg_name_display + "s"
        Item.register({
            :id               => egg_symbol,
            :id_number        => id_here,
            :name             => egg_name_display,
            :name_plural      => egg_name_display_plural,
            :pocket           => 1,
            :price            => egg_price,
            :description      => egg_description,
            :field_use        => 2,
            :battle_use       => 0,
            :type             => 0,
            :move             => nil
        })
        MessageTypes.set(MessageTypes::Items,            id_here, egg_name_display)
        MessageTypes.set(MessageTypes::ItemPlurals,      id_here, egg_name_display_plural)
        MessageTypes.set(MessageTypes::ItemDescriptions, id_here, egg_description)
        if itemtype == 0
            ItemHandlers::UseInField.add(egg_symbol, proc { |item|
                next kurayeggs_triggereggitem(id_here-Settings::KURAY_EGGS_ID, item)
            })
        else
            ItemHandlers::UseInField.add(egg_symbol, proc { |item|
                next kuraychests_triggerchest(id_here-Settings::KURAY_CHESTS_ID, item)
            })
        end
    end

    def self.kuray_name_to_sym(name)
        name = name.upcase.gsub(" ", "_")
        return name.to_sym
    end

    def self.kurayglobal_processsymb(egg_name, addon="")
        # Replace whitespaces with underscores and make the string uppercase.
        # egg_symbol = self.kuray_name_to_sym(addon + egg_name)
        # egg_symbol = "KURAYEGG_" + egg_name.upcase.gsub(" ", "_")
        # egg_symbol = egg_symbol.to_sym
        # Code will need to be cleaned later.
        return self.kuray_name_to_sym(addon + egg_name)
    end

    def self.kurayeggs_processsymb(egg_name)
        return self.kurayglobal_processsymb(egg_name, "KURAYEGG_")
    end


    def self.kurayeggs_loadsystem()
        id_here = Settings::KURAY_EGGS_ID-1

        eggs_baseprice = 5000
        egg_name_last = "K-Egg"

        id_here += 1
        egg_price = eggs_baseprice*3
        egg_name = "Random"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        id_here += 1
        egg_price = eggs_baseprice*6
        egg_name = "Sparkling"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 40x shiny odds."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        all_types = ["Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark", "Fairy"]
        for type in all_types
            id_here += 1
            egg_price = eggs_baseprice*4
            egg_name = type
            egg_symbol = self.kurayeggs_processsymb(egg_name)
            egg_name_display = egg_name + " " + egg_name_last
            egg_description = "Egg with " + type.upcase + "-type Pokémon. 10x shiny odds."
            $KURAYEGGS_BASEPRICE.push(egg_price)
            self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)
        end

        id_here += 1
        egg_price = eggs_baseprice*4
        egg_name = "Fusion"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds. Fusion guaranteed."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        id_here += 1
        egg_price = eggs_baseprice*2
        egg_name = "Base"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with ANY Pokémon. 10x shiny odds. Non-fused guaranteed."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

        # 0 Badge - $500
        # 1 Badge - $800
        # 2 Badges - $1 200
        # 3 Badges - $2 000
        # 4 Badges - $3 500
        # 5 Badges - $5 000
        # 6 Badges - $7 000
        # 7 Badges - $10 000
        # 8 Badges - $12 000
        # Elite 4 - $15 000
        bst_pricing = [500, 800, 1200, 2000, 3500, 5000, 7000, 10000, 12000, 15000]
        all_bsttypes = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        for bsttype in all_bsttypes
            id_here += 1
            price_maker = bsttype.to_i
            egg_price = bst_pricing[price_maker]
            if price_maker == 9
                egg_name = "Elite 4"
            elsif price_maker == 1
                egg_name = bsttype + " Badge"
            elsif price_maker == 0
                egg_name = "Starter"
            else
                egg_name = bsttype + " Badges"
            end
            egg_symbol = self.kurayeggs_processsymb(egg_name)
            egg_name_display = egg_name + " " + egg_name_last
            egg_description = "Egg with a Pokémon who's BST is between " + $KURAYEGGS_MINBSTSHOW[price_maker].to_s + " and " + $KURAYEGGS_MAXBSTSHOW[price_maker].to_s + ". 10x shiny odds."
            $KURAYEGGS_BASEPRICE.push(egg_price)
            self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)
        end

        id_here += 1
        egg_price = eggs_baseprice*5
        egg_name = "Legendary"
        egg_symbol = self.kurayeggs_processsymb(egg_name)
        egg_name_display = egg_name + " " + egg_name_last
        egg_description = "Egg with a LEGENDARY Pokémon. 10x shiny odds."
        $KURAYEGGS_BASEPRICE.push(egg_price)
        self.kurayeggs_iteminject(egg_symbol, id_here, egg_name_display, egg_price, egg_description)

    end
end

def kurayeggs_typelookup(type, list_name)
    # This function creates the list_name key for the dictionnary KURAYEGGS_LISTS. It iterates through all the base Pokemons.
    # It adds to the list any base Pokemon that has the typing as type1 or type2, the first value is the symbol of the Pokemon, the second value is the catch rate.
    # Example: [:CHARIZARD, 20]
    
    $KURAYEGGS_LISTS[list_name] = []
    for i in 1..NB_POKEMON
        species = GameData::Species.get(i)
        if species.type1 == type || species.type2 == type
            $KURAYEGGS_LISTS[list_name].push([species.id, species.catch_rate])
        end
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

def kurayeggs_legendarylookup()
    $KURAYEGGS_LISTS["Legendary"] = []
    for i in 1..NB_POKEMON
      species = GameData::Species.get(i)
      # Check if the species.id is inside the LEGENDARIES_LIST array
        if LEGENDARIES_LIST.include?(species.id)
            $KURAYEGGS_LISTS["Legendary"].push([species.id, species.catch_rate])
        end
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

def kurayeggs_randomlookup()
    $KURAYEGGS_LISTS["Random"] = []
    for i in 1..NB_POKEMON
      species = GameData::Species.get(i)
      $KURAYEGGS_LISTS["Random"].push([species.id, species.catch_rate])
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

def kuray_writefile(filename, content)
    # Ensure the Output directory exists
    output_dir = "Output"
    Dir.mkdir(output_dir) unless File.exists?(output_dir)

    # Path to the file where the content will be written
    file_path = File.join(output_dir, filename)

    # Open the file and write the content
    File.open(file_path, "w") do |file|
    file.write(content)
    end
end

def kurayeggs_generatejustwildydata()
    # Generate google sheet for Just Wildy
    txtCont = "Dex Number\tSystem Name\tName\tBST\tCatch Rate\tType 1\tType 2\tCleaned System Name\tCleaned Name\n"
    for i in 1..NB_POKEMON
        species = GameData::Species.get(i)
        statssum = calcBaseStatsSum(species.id)
        # convert type1's symbol into a name with the first letter upcased, and the ":" sign from symbol gone, and the rest lowercased
        type1 = species.type1.to_s.capitalize
        # convert type2's symbol into a name with the first letter upcased, and the ":" sign from symbol gone, and the rest lowercased
        type2 = species.type2.to_s.capitalize
        # remove "'", "." and "-" from names
        name2 = species.name.gsub(/['.-]/, "")
        # do the same with species.id
        name3 = species.id.to_s.gsub(/['.-]/, "")
        if type1 == type2
            type2 = ""
        end
        txtCont += i.to_s + "\t" + species.id.to_s + "\t" + species.name + "\t" + statssum.to_s + "\t" + species.catch_rate.to_s + "\t" + type1 + "\t" + type2 + "\t" + name3 + "\t" + name2 + "\n"
    end
    filename = "JustWildy.txt"
    kuray_writefile(filename, txtCont)
    return
end

def kurayeggs_generatebstdatabase()
    txtCont = "Name\tBST\tCatch Rate\n"
    for i in 1..NB_POKEMON
        species = GameData::Species.get(i)
        statssum = calcBaseStatsSum(species.id)
        txtCont += species.id.to_s + "\t" + statssum.to_s + "\t" + species.catch_rate.to_s + "\n"
    end
    filename = "BST.txt"
    kuray_writefile(filename, txtCont)
    return
end

def kurayeggs_main()
    # This works as an alternative way to make hashes in Ruby.
    # hash_test = { "hello": "world"}
    # puts hash_test.inspect
    # puts hash_test[:hello]

    kurayeggs_generatejustwildydata()
    # kurayeggs_generatebstdatabase()
    
    # GameData::kuray_exportpokemondata(1)#1 = triple, 0 = normal mons
    # GameData::kuray_create_triplefusions_data()
    
    return
    # puts "WIP - Kuray's Eggs System"
    # kurayeggs_effectfromid(0)
    # kurayeggs_effectfromid(5)
    # selected_mon = kurayeggs_choose(0, "Fire")
    # kurayeggs_random()
end

def kurayeggs_triggereggitem(id, itemid)
    # This function is used to trigger the egg item effect based on its ID.
    # The effect is determined by the ID of the egg item.
    found_pokemon = false
    item_name = GameData::Item.get(itemid).name
    pbUseItemMessage(itemid)
    # Try 20 times to get a valid Pokemon.
    for i in 1..20
        puts "Attempt #{i}" if $KURAYEGGS_DEBUG
        selected_mon = kurayeggs_effectfromid(id)
        $KURAYEGGS_SPARKLING = false
        $KURAYEGGS_FORCEDFUSION = 0
        # 0 = No forcing
        # 1 = Forced Base (non-fusion)
        # 2 = Forced Fusion
        if id == 1
            $KURAYEGGS_SPARKLING = true
        end
        if id == 20
            $KURAYEGGS_FORCEDFUSION = 2
        elsif id == 21
            $KURAYEGGS_FORCEDFUSION = 1
        end

        if $PokemonSystem.kurayeggs_fusionodds != nil && $KURAYEGGS_FORCEDFUSION != 1 && $PokemonSystem.kurayeggs_fusionodds > 0
            # Use the fusion odds to determine if we get a second pokemon.
            if rand(1..100) <= $PokemonSystem.kurayeggs_fusionodds
                $KURAYEGGS_FORCEDFUSION = 2
            end
        end
        # Do we get a second pokemon? (for fusion)
        if $KURAYEGGS_FORCEDFUSION == 2
            # Do the pokemon have to come from the same egg pool or a random pool?
            if $PokemonSystem.kurayeggs_fusionpool != nil && $PokemonSystem.kurayeggs_fusionpool == 1
                selected_mon2 = kurayeggs_effectfromid(id)
            else
                selected_mon2 = kurayeggs_choose(1, "Random")
            end
        end
        # Give the pokemon to the player

        if $KURAYEGGS_FORCEDFUSION == 2
            # 50% chance that the first pokemon is the body and the second is the head.
            if rand(1..100) <= 50
                head_symb = selected_mon2
                body_symb = selected_mon
            else
                head_symb = selected_mon
                body_symb = selected_mon2
            end
            pokemon_id = getFusedPokemonIdFromSymbols(body_symb, head_symb)
            kurayegg_pokemon = Pokemon.new(pokemon_id,1)
            # kurayegg_specie = GameData::FusedSpecies.new(pokemon_id)
            # newid = (pokemon.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number

            # kurayegg_newspecie = GameData::Species.get(pokemon_id)
            # kurayegg_pokemon = Pokemon.new(body_symb,1)
            # kurayegg_pokemon.species = kurayegg_newspecie
        else
            kurayegg_pokemon = Pokemon.new(selected_mon,1)
        end
        # Check if the pokemon is valid
        require_typing = false
        k_typing = nil
        case id
        when 2
            k_typing = :NORMAL
        when 3
            k_typing = :FIGHTING
        when 4
            k_typing = :FLYING
        when 5
            k_typing = :POISON
        when 6
            k_typing = :GROUND
        when 7
            k_typing = :ROCK
        when 8
            k_typing = :BUG
        when 9
            k_typing = :GHOST
        when 10
            k_typing = :STEEL
        when 11
            k_typing = :FIRE
        when 12
            k_typing = :WATER
        when 13
            k_typing = :GRASS
        when 14
            k_typing = :ELECTRIC
        when 15
            k_typing = :PSYCHIC
        when 16
            k_typing = :ICE
        when 17
            k_typing = :DRAGON
        when 18
            k_typing = :DARK
        when 19
            k_typing = :FAIRY
        end
        if k_typing != nil
            require_typing = true
        end

        $KURAYEGGS_VALIDATE = false
        if require_typing
            if kurayegg_pokemon.type1 != nil
                if kurayegg_pokemon.type1 == k_typing
                    $KURAYEGGS_VALIDATE = true
                end
            end
            if kurayegg_pokemon.type2 != nil
                if kurayegg_pokemon.type2 == k_typing
                    $KURAYEGGS_VALIDATE = true
                end
            end
        else
            $KURAYEGGS_VALIDATE = true
        end
        if $KURAYEGGS_VALIDATE
            found_pokemon = true
            break
        else
            next
        end
    end
    if !found_pokemon
        puts "No valid Pokémon found." if $KURAYEGGS_DEBUG
    end
    if $PokemonSystem.kurayeggs_instanthatch != nil && $PokemonSystem.kurayeggs_instanthatch == 1
        kurayegg_pokemon.name           = _INTL("Egg")
        kurayegg_pokemon.steps_to_hatch = kurayegg_pokemon.species_data.hatch_steps
        kurayegg_pokemon.hatched_map    = 0
        kurayegg_pokemon.obtain_method  = 1
    end
    egg_shiny_odds = $PokemonSystem.shinyodds*10
    if $KURAYEGGS_SPARKLING
        egg_shiny_odds = egg_shiny_odds*4
    end
    if rand(65536) < egg_shiny_odds
        kurayegg_pokemon.shiny = true
    end
    kurayegg_pokemon.time_form_set = nil
    kurayegg_pokemon.form          = 0 if kurayegg_pokemon.isSpecies?(:SHAYMIN)
    kurayegg_pokemon.heal
    kurayegg_pokemon.obtain_text = item_name

    # Check where we can place the pokemon
    pbAddPokemon(kurayegg_pokemon, 1, true, true)

    $Trainer.pokedex.register_unfused_pkmn(kurayegg_pokemon).each do |unfused|
        pbMessage(_INTL("{1}'s data was added to the Pokédex", GameData::Species.get(unfused).name))
    end
    # if $Trainer.party_full?
        # If the player's party is full, the Pokémon is sent to storage.
        # pbStorePokemon(kurayegg_pokemon)
    # else
        # If the player's party isn't full, the Pokémon is added to the party.
        # pbAddToParty(kurayegg_pokemon)
    # end
    # for i in $KURAY_MODDED_TRIPLES
    #     target_sym = self.kuray_name_to_sym("KURAY_" + i[0])
    #     puts "Checking for #{target_sym}" if $KURAYEGGS_DEBUG
    #     kuray_generateandstore(target_sym, 100)
    # end
    return 3
end

def kuray_generateandstore(pokemon, level=1)
    # pokemon_id = getFusedPokemonIdFromSymbols(body_symb, head_symb)
    kurayegg_pokemon = Pokemon.new(pokemon,level)
    kurayegg_pokemon.time_form_set = nil
    kurayegg_pokemon.form          = 0 if kurayegg_pokemon.isSpecies?(:SHAYMIN)
    kurayegg_pokemon.heal
    # Check where we can place the pokemon
    pbAddPokemon(kurayegg_pokemon, 1, true, true)
    # if $Trainer.party_full?
        # If the player's party is full, the Pokémon is sent to storage.
        # pbStorePokemon(kurayegg_pokemon)
    # else
        # If the player's party isn't full, the Pokémon is added to the party.
        # pbAddToParty(kurayegg_pokemon)
    # end
end

def kurayeggs_effectfromid(id)
    # This function is used to determine the effect of the egg based on its ID.
    # Normal Egg have Shiny Odds divided by 10
    case id
    when 0
        # Random Egg
        selected_mon = kurayeggs_choose(1, "Random")
    when 1
        # Sparkling Egg (Shiny Odds divided by 40)
        selected_mon = kurayeggs_choose(1, "Random")
    when 2
        # Normal Egg
        selected_mon = kurayeggs_choose(0, "Normal")
    when 3
        # Fighting Egg
        selected_mon = kurayeggs_choose(0, "Fighting")
    when 4
        # Flying Egg
        selected_mon = kurayeggs_choose(0, "Flying")
    when 5
        # Poison Egg
        selected_mon = kurayeggs_choose(0, "Poison")
    when 6
        # Ground Egg
        selected_mon = kurayeggs_choose(0, "Ground")
    when 7
        # Rock Egg
        selected_mon = kurayeggs_choose(0, "Rock")
    when 8
        # Bug Egg
        selected_mon = kurayeggs_choose(0, "Bug")
    when 9
        # Ghost Egg
        selected_mon = kurayeggs_choose(0, "Ghost")
    when 10
        # Steel Egg
        selected_mon = kurayeggs_choose(0, "Steel")
    when 11
        # Fire Egg
        selected_mon = kurayeggs_choose(0, "Fire")
    when 12
        # Water Egg
        selected_mon = kurayeggs_choose(0, "Water")
    when 13
        # Grass Egg
        selected_mon = kurayeggs_choose(0, "Grass")
    when 14
        # Electric Egg
        selected_mon = kurayeggs_choose(0, "Electric")
    when 15
        # Psychic Egg
        selected_mon = kurayeggs_choose(0, "Psychic")
    when 16
        # Ice Egg
        selected_mon = kurayeggs_choose(0, "Ice")
    when 17
        # Dragon Egg
        selected_mon = kurayeggs_choose(0, "Dragon")
    when 18
        # Dark Egg
        selected_mon = kurayeggs_choose(0, "Dark")
    when 19
        # Fairy Egg
        selected_mon = kurayeggs_choose(0, "Fairy")
    when 20
        # Fusion Egg (forced to be a fusion)
        selected_mon = kurayeggs_choose(1, "Random")
    when 21
        # Base Egg (cannot be a fusion)
        selected_mon = kurayeggs_choose(1, "Random")
    when 22
        # 0 Badge Egg (available before Brock)
        # BST Range: 0-288
        selected_mon = kurayeggs_choose(2, "0")
    when 23
        # 1 Badge Egg (available right after Brock)
        # BST Range: 280-319
        selected_mon = kurayeggs_choose(2, "1")
    when 24
        # 2 Badges Egg (available right after Misty)
        # BST Range: 300-400
        selected_mon = kurayeggs_choose(2, "2")
    when 25
        # 3 Badges Egg (available right after Lt. Surge)
        # BST Range: 380-470
        selected_mon = kurayeggs_choose(2, "3")
    when 26
        # 4 Badges Egg (available right after Erika)
        # BST Range: 430-480
        selected_mon = kurayeggs_choose(2, "4")
    when 27
        # 5 Badges Egg (available right after Koga)
        # BST Range: 450-490
        selected_mon = kurayeggs_choose(2, "5")
    when 28
        # 6 Badges Egg (available right after Sabrina)
        # BST Range: 470-505
        selected_mon = kurayeggs_choose(2, "6")
    when 29
        # 7 Badges Egg (available right after Blaine)
        # BST Range: 480-530
        selected_mon = kurayeggs_choose(2, "7")
    when 30
        # 8 Badges Egg (available right after Giovanni)
        # BST Range: 490-555
        selected_mon = kurayeggs_choose(2, "8")
    when 31
        # Elite Four Egg (available right after the Elite Four)
        # BST Range: 500-INF
        selected_mon = kurayeggs_choose(2, "9")
    when 32
        # Legendary Egg (contains a Legendary Pokemon)
        selected_mon = kurayeggs_choose(3, "Legendary")
    end
    return selected_mon
end

def kurayeggs_bstlookup(type="-1")
    if type == "-1"
        puts "Error - No type given." if $KURAYEGGS_DEBUG
        return
    end
    maxBST = 1000000
    minBST = 0
    mark_type = type.to_i
    if type.to_i >= 0 && type.to_i <= 9
        maxBST = $KURAYEGGS_MAXBST[mark_type]
        minBST = $KURAYEGGS_MINBST[mark_type]
    end
    $KURAYEGGS_LISTS[type] = []
    for i in 1..NB_POKEMON
      species = GameData::Species.get(i)
      statssum = calcBaseStatsSum(species.id)
        if statssum >= minBST && statssum <= maxBST
            $KURAYEGGS_LISTS[type].push([species.id, species.catch_rate])
        end
    end
    # Inspect the created dictionnary to check the values.
    puts $KURAYEGGS_LISTS.inspect if $KURAYEGGS_DEBUG
end

def kurayeggs_createmon(eggsymbol)
    # This function creates the Pokémon based on the symbol given.
    # It creates the Pokémon at level 1 as an egg.
    return
end

def kurayeggs_choose(kmode, type="None")
    # kmode 0 is a typing egg.
    if kmode == 0 || kmode == 1 || kmode == 3
        # We create the possible symbol by using the type name in uppercase and transforming it into a symbol name.
        if !$KURAYEGGS_LISTS.has_key?(type)
            if kmode == 1
                kurayeggs_randomlookup()
            elsif kmode == 3
                kurayeggs_legendarylookup()
            else
                kurayeggs_typelookup(type.upcase.to_sym, type)
            end
        end
    end
    if kmode == 2
        choosen_tier = rand(1..100)
        # 10% chance for the type to be one tier lower
        # 10% chance for the type to be one tier higher
        # 80% chance for the type to be this exact tier
        current_tier = type.to_i
        if choosen_tier <= 10 && current_tier > 0
            current_tier -= 1
            type = current_tier.to_s
        elsif choosen_tier <= 20 && current_tier < 9
            current_tier += 1
            type = current_tier.to_s
        end
        if !$KURAYEGGS_LISTS.has_key?(type)
            kurayeggs_bstlookup(type)
        end
    end
    # We use the array chooser function
    # puts type.inspect if $KURAYEGGS_DEBUG
    # puts $KURAYEGGS_LISTS[type].inspect if $KURAYEGGS_DEBUG
    selected_mon = kurayeggs_arraychooser($KURAYEGGS_LISTS[type])
    puts "Selected Pokémon: #{selected_mon}" if $KURAYEGGS_DEBUG
    return selected_mon
    # kurayeggs_createmon(selected_mon)
end

def kurayeggs_arraychooser(organizedarray)
    if $PokemonSystem.kurayeggs_rarity != nil && $PokemonSystem.kurayeggs_rarity == 1
        # treats all weights as 1
        total_weight = organizedarray.size
        random_weight = rand(total_weight)

        return organizedarray[random_weight][0] # Return a randomly selected symbol
    else
        # Calculate the total weight
        total_weight = organizedarray.inject(0) { |sum, item| sum + item[1] }

        # Generate a random number between 0 and total_weight
        random_weight = rand(total_weight)

        # Iterate over the list to find the selected item
        current_weight = 0
        organizedarray.each do |item|
            current_weight += item[1]
            if random_weight < current_weight
                return item[0]  # Return the symbol (e.g., :CHARIZARD)
            end
        end
    end
end

# def kurayeggs_random()
#     # This choose a random pokemon using their catch_rate as a weight.
#     # The lower the catch rate of the pokemon, the lower the chance of being chosen in the random egg.
#     catch_rates = []
#     for i in 1..NB_POKEMON
#       species = GameData::Species.get(i)
#       catch_rates.push(species.catch_rate)
#     end
    
#     # Debug - Shows the catch_rates array in the console
#     # puts catch_rates.inspect
    
#     # Calculate the total weight
#     total_weight = catch_rates.sum
    
#     # Generate a random number between 0 and total_weight
#     random_weight = rand(0...total_weight)
    
#     # Iterate over the catch_rates to find the chosen index
#     chosen_index = nil
#     current_weight = 0
    
#     catch_rates.each_with_index do |weight, index|
#       current_weight += weight
#       if random_weight < current_weight
#         chosen_index = index + 1  # Since Pokémon indices are 1-based
#         break
#       end
#     end
    
#     # Debug - Shows the chosen_index in the console, with the catch_rate value it had.
#     puts "Chosen index: #{chosen_index} with catch rate: #{catch_rates[chosen_index - 1]}"
# end