class PokemonBox
  attr_accessor   :pokemon
  attr_accessor :name
  attr_accessor :background

  BOX_WIDTH  = 6
  BOX_HEIGHT = 5
  BOX_SIZE   = BOX_WIDTH * BOX_HEIGHT

  def initialize(name, maxPokemon = BOX_SIZE)
    @pokemon = []
    @name = name
    @background = 0
    for i in 0...maxPokemon
      @pokemon[i] = nil
    end
  end

  def length
    return @pokemon.length
  end

  def nitems
    ret = 0
    @pokemon.each { |pkmn| ret += 1 if !pkmn.nil? }
    return ret
  end

  def full?
    return nitems == self.length
  end

  def empty?
    return nitems == 0
  end

  def [](i)
    return @pokemon[i]
  end

  def []=(i,value)
    @pokemon[i] = value
  end

  def each
    @pokemon.each { |item| yield item }
  end

  def clear
    @pokemon.clear
  end

  #Sylvi Items
  def clone
    ret = super
    ret.pokemon = @pokemon.clone
    return ret
  end

  #Sylvi Items
  def make_vanilla
    @pokemon.map! { |pkmn| !pkmn.nil? ? pkmn.clone.make_vanilla : pkmn }
    return self
  end
end



class PokemonStorage
  attr_reader   :boxes
  attr_accessor :currentBox
  attr_writer   :unlockedWallpapers
  BASICWALLPAPERQTY = 16

  def initialize(maxBoxes = Settings::NUM_STORAGE_BOXES, maxPokemon = PokemonBox::BOX_SIZE)
    @boxes = []
    for i in 0...maxBoxes
      @boxes[i] = PokemonBox.new(_INTL("Box {1}",i+1),maxPokemon)
      @boxes[i].background = i % BASICWALLPAPERQTY
    end
    @currentBox = 0
    @boxmode = -1
    @unlockedWallpapers = []
    for i in 0...allWallpapers.length
      @unlockedWallpapers[i] = false
    end

    @fusionMode=false
    @fusionItem=nil
  end

  #Kuray Allow to clean boxes
  # def undefineboxes
  #   numberboxes = @boxes.length+1
  #   @boxes = []
  #   for i in 0...numberboxes
  #     @boxes[i] = PokemonBox.new(_INTL("Box {1}",i+1),PokemonBox::BOX_SIZE)
  #     @boxes[i].background = i % BASICWALLPAPERQTY
  #   end
  # end

  #Kuray Delete boxes
  # def deleteboxes
  #   while @boxes.length > 30
  #     @boxes.pop()
  #   end
  # end

  def allWallpapers
    return [
       # Basic wallpapers
       _INTL("Forest"),_INTL("City"),_INTL("Desert"),_INTL("Savanna"),
       _INTL("Crag"),_INTL("Volcano"),_INTL("Snow"),_INTL("Cave"),
       _INTL("Beach"),_INTL("Seafloor"),_INTL("River"),_INTL("Sky"),
       _INTL("Poké Center"),_INTL("Machine"),_INTL("Checks"),_INTL("Simple"),
       # Special wallpapers
       _INTL("Space"),_INTL("Backyard"),_INTL("Nostalgic 1"),_INTL("Torchic"),
       _INTL("Trio 1"),_INTL("PikaPika 1"),_INTL("Legend 1"),_INTL("Team Galactic 1"),
       _INTL("Distortion"),_INTL("Contest"),_INTL("Nostalgic 2"),_INTL("Croagunk"),
       _INTL("Trio 2"),_INTL("PikaPika 2"),_INTL("Legend 2"),_INTL("Team Galactic 2"),
       _INTL("Heart"),_INTL("Soul"),_INTL("Big Brother"),_INTL("Pokéathlon"),
       _INTL("Trio 3"),_INTL("Spiky Pika"),_INTL("Kimono Girl"),_INTL("Revival"),
       #KurayX
       _INTL("Fire Light"),_INTL("Fire Dark"),_INTL("Water Light"),_INTL("Water Dark"),_INTL("Grass Light"),_INTL("Grass Dark"),
       _INTL("Electric Light"),_INTL("Electric Dark"),_INTL("Ground Light"),_INTL("Ground Dark"),_INTL("Flying Light"),_INTL("Flying Dark"),
       _INTL("Psychic Light"),_INTL("Psychic Dark"),_INTL("Dark Light"),_INTL("Dark Dark"),_INTL("Fighting Light"),_INTL("Fighting Dark"),
       _INTL("Rock Light"),_INTL("Rock Dark"),_INTL("Steel Light"),_INTL("Steel Dark"),_INTL("Ghost Light"),_INTL("Ghost Dark"),_INTL("Bug Light"),
       _INTL("Bug Dark"),_INTL("Dragon Light"),_INTL("Dragon Dark"),_INTL("Fairy Light"),_INTL("Fairy Dark"),_INTL("Ice Light"),_INTL("Ice Dark"),
       _INTL("Poison Light"),_INTL("Poison Dark"),_INTL("Normal Light"),_INTL("Normal Dark"),_INTL("PMD Sand"),_INTL("PMD Snow"),_INTL("PMD Altar"),
       _INTL("PMD Trees"),_INTL("PMD Sharpedo Bluff"),_INTL("PMD Altar 2"),_INTL("PMD Time Stop"),_INTL("PMD Waterfall"),_INTL("PMD Time Tower"),
       _INTL("PMD Time Tower 2"),_INTL("PMD Guild"),_INTL("PMD Time Stop 2"),_INTL("PMD Sky"),_INTL("PMD Friends Space"),_INTL("PMD Friends Space 2"),
       _INTL("PMD Primal"),_INTL("PMD Tower"),_INTL("PMD Evolution"),_INTL("PMD Fire"),_INTL("PMD Mystery"),_INTL("PMD Night"),_INTL("PMD Cliff"),
       _INTL("PMD Worldview"),_INTL("Snowy"),_INTL("Poison"),_INTL("Dark Rural"),_INTL("Marathon"),_INTL("Gothic"),_INTL("Black Gradient"),_INTL("Yveltal"),
       _INTL("Plain Light"),_INTL("Plain Dark"),_INTL("Beach Sand"),_INTL("Blue Gradient"),_INTL("Night"),_INTL("Trade"),_INTL("Arid"),_INTL("City Path"),
       _INTL("Book"),_INTL("Cobwebs"),_INTL("Mt. Coronet"),_INTL("Altar"),_INTL("Slowpoke Well"),_INTL("Tin Tower"),_INTL("Search Light"),_INTL("Search Dark"),
       _INTL("Mewtwo Lab"),_INTL("Team Rocket 1"),_INTL("Team Rocket 2"),_INTL("Team Flare"),_INTL("Coral"),_INTL("Training"),_INTL("Dream Space"),_INTL("School"),
       _INTL("Underwater"),_INTL("Underwater 2"),_INTL("Chess"),_INTL("Rainbow Plain"),_INTL("Mushrooms"),_INTL("Plain Pathway"),_INTL("Mountain"),_INTL("Shiny Blue"),
       _INTL("Shiny Red"),_INTL("Shiny Green"),_INTL("Shiny Purple"),_INTL("Minecraft Rails"),_INTL("Minecraft Rails 2"),_INTL("Infernal"),_INTL("Insectoid"),
       _INTL("Halloween"),_INTL("Neon"),_INTL("Obscuros"),_INTL("Japan"),_INTL("Norse"),_INTL("Oblivion"),_INTL("Rainbow"),_INTL("River"),_INTL("Sunset"),_INTL("Shadow"),
       _INTL("Soulfire"),_INTL("Temple"),_INTL("Sweet Shop"),_INTL("Anubis"),_INTL("Dark"),_INTL("Demonic"),_INTL("Ethereal"),_INTL("Forest"),_INTL("Gembound"),
       _INTL("Snow Game"),_INTL("Mega Evolution"),_INTL("Golden Night"),_INTL("Milotic Style"),_INTL("X & Y"),_INTL("Steampunk"),_INTL("Synthwave Neon"),
       _INTL("Xerneas"),_INTL("Charged Steel"),_INTL("Reshiram & Zekrom"),_INTL("Kyurems"),_INTL("Beautiful Underwater"),
       #KurayX2
       _INTL("Synthwave Sunset"),_INTL("Team Magma"),_INTL("Team Aqua"),_INTL("Victini"),_INTL("Weezing/Kyogre"),_INTL("Star Snow"),_INTL("Dark Graphs"),
       _INTL("Purple Geometry"),_INTL("RGBY Squares"),_INTL("RIP"),_INTL("RIP 2"),_INTL("Pizza"),_INTL("Fusing Chart"),_INTL("Roaring Reshigon"),
       _INTL("Arcade Academy"),_INTL("Windows XP"),_INTL("Doggy XP"),_INTL("Mewtwo Strikes"),_INTL("Pikachu Sad"),_INTL("Ash Ded"),_INTL("Shadow Lugia"),
       _INTL("Primal Dialga"),_INTL("Bluescreen"),_INTL("Bluescreen 2")
    ]
  end

  def unlockedWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return @unlockedWallpapers
  end

  def isAvailableWallpaper?(i)
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return true if i<BASICWALLPAPERQTY
    return true if i>39
    return true if @unlockedWallpapers[i]
    return false
  end

  def availableWallpapers
    ret = [[],[]]   # Names, IDs
    papers = allWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    for i in 0...papers.length
      next if !isAvailableWallpaper?(i)
      ret[0].push(papers[i]); ret[1].push(i)
    end
    return ret
  end

  def party
    $Trainer.party
  end

  def party=(_value)
    raise ArgumentError.new("Not supported")
  end

  def party_full?
    return $Trainer.party_full?
  end

  def maxBoxes
    return @boxes.length
  end

  def maxPokemon(box)
    return 0 if box >= self.maxBoxes
    return (box < 0) ? Settings::MAX_PARTY_SIZE : self[box].length
  end

  def full?
    for i in 0...self.maxBoxes
      return false if !@boxes[i].full?
    end
    return true
  end

  def pbFirstFreePos(box)
    if box==-1
      ret = self.party.length
      return (ret >= Settings::MAX_PARTY_SIZE) ? -1 : ret
    end
    for i in 0...maxPokemon(box)
      return i if !self[box,i]
    end
    return -1
  end

  def [](x,y=nil)
    if y==nil
      return (x==-1) ? self.party : @boxes[x]
    else
      for i in @boxes
        raise "Box is a Pokémon, not a box" if i.is_a?(Pokemon)
      end
      return (x==-1) ? self.party[y] : @boxes[x][y]
    end
  end

  def []=(x,y,value)
    if x==-1
      self.party[y] = value
    else
      @boxes[x][y] = value
    end
  end

  #Kuray
  def pbImportKuray(boxDst,indexDst,importpoke)
    if indexDst<0 && boxDst<self.maxBoxes
      found = false
      for i in 0...maxPokemon(boxDst)
        next if self[boxDst,i]
        found = true
        indexDst = i
        break
      end
      return false if !found
    end
    importpoke.calc_stats
    if boxDst==-1   # Copying into party
      return false if party_full?
      self.party[self.party.length] = importpoke.clone
      # self.party[self.party.length] = importpoke
      self.party.compact!
    else   # Copying into box
      pkmn = importpoke.clone
      # pkmn = importpoke
      raise "Trying to copy nil to storage" if !pkmn
      pkmn.time_form_set = nil
      pkmn.form          = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
      self[boxDst,indexDst] = pkmn
    end
    return true
  end

  def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    if indexDst<0 && boxDst<self.maxBoxes
      found = false
      for i in 0...maxPokemon(boxDst)
        next if self[boxDst,i]
        found = true
        indexDst = i
        break
      end
      return false if !found
    end
    if boxDst==-1   # Copying into party
      return false if party_full?
      self.party[self.party.length] = self[boxSrc,indexSrc]
      self.party.compact!
    else   # Copying into box
      pkmn = self[boxSrc,indexSrc]
      raise "Trying to copy nil to storage" if !pkmn
      pkmn.time_form_set = nil
      pkmn.form          = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
      self[boxDst,indexDst] = pkmn
    end
    return true
  end

  def pbMove(boxDst,indexDst,boxSrc,indexSrc)
    return false if !pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    pbDelete(boxSrc,indexSrc)
    return true
  end

  def pbMoveCaughtToParty(pkmn)
    return false if party_full?
    self.party[self.party.length] = pkmn
  end

  def pbMoveCaughtToBox(pkmn,box)
    for i in 0...maxPokemon(box)
      if self[box,i]==nil
        if box>=0
          pkmn.time_form_set = nil if pkmn.time_form_set
          pkmn.form          = 0 if pkmn.isSpecies?(:SHAYMIN)
          pkmn.heal
        end
        self[box,i] = pkmn
        return true
      end
    end
    return false
  end

  def pbStoreCaught(pkmn)
    if @currentBox>=0
      pkmn.time_form_set = nil
      # pkmn.form          = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
    end
    for i in 0...maxPokemon(@currentBox)
      if self[@currentBox,i]==nil
        self[@currentBox,i] = pkmn
        return @currentBox
      end
    end
    for j in 0...self.maxBoxes
      for i in 0...maxPokemon(j)
        if self[j,i]==nil
          self[j,i] = pkmn
          @currentBox = j
          return @currentBox
        end
      end
    end
    return -1
  end

  def pbDelete(box,index)
    if self[box,index]
      self[box,index] = nil
      self.party.compact! if box==-1
    end
  end

  #By Sylvi (multi)
  def pbDeleteMulti(box,indexes)
    for index in indexes
      self[box,index] = nil
    end
    self.party.compact! if box==-1
  end

  def clear
    for i in 0...self.maxBoxes
      @boxes[i].clear
    end
  end

  #Sylvi Items
  def cloneBoxes(boxes)
    @boxes = []
    for i in 0...boxes.length
      @boxes[i] = boxes[i].clone
    end
  end

  #Sylvi Items
  def clone
    ret = super
    ret.cloneBoxes(@boxes)
    return ret
  end

  #Sylvi Items
  def make_vanilla
    for i in 0...self.maxBoxes
      @boxes[i].make_vanilla
    end
    return self
  end
end



#===============================================================================
# Regional Storage scripts
#===============================================================================
class RegionalStorage
  def initialize
    @storages = []
    @lastmap = -1
    @rgnmap = -1
  end

  def getCurrentStorage
    if !$game_map
      raise _INTL("The player is not on a map, so the region could not be determined.")
    end
    if @lastmap!=$game_map.map_id
      @rgnmap = pbGetCurrentRegion   # may access file IO, so caching result
      @lastmap = $game_map.map_id
    end
    if @rgnmap<0
      raise _INTL("The current map has no region set. Please set the MapPosition metadata setting for this map.")
    end
    if !@storages[@rgnmap]
      @storages[@rgnmap] = PokemonStorage.new
    end
    return @storages[@rgnmap]
  end

  def allWallpapers
    return getCurrentStorage.allWallpapers
  end

  def availableWallpapers
    return getCurrentStorage.availableWallpapers
  end

  def unlockWallpaper(index)
    getCurrentStorage.unlockWallpaper(index)
  end

  def boxes
    return getCurrentStorage.boxes
  end

  def party
    return getCurrentStorage.party
  end

  def party_full?
    return getCurrentStorage.party_full?
  end

  def maxBoxes
    return getCurrentStorage.maxBoxes
  end

  def maxPokemon(box)
    return getCurrentStorage.maxPokemon(box)
  end

  def full?
    getCurrentStorage.full?
  end

  def currentBox
    return getCurrentStorage.currentBox
  end

  def currentBox=(value)
    getCurrentStorage.currentBox = value
  end

  def [](x,y=nil)
    getCurrentStorage[x,y]
  end

  def []=(x,y,value)
    getCurrentStorage[x,y] = value
  end

  def pbFirstFreePos(box)
    getCurrentStorage.pbFirstFreePos(box)
  end

  def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
  end

  def pbMove(boxDst,indexDst,boxSrc,indexSrc)
    getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
  end

  def pbMoveCaughtToParty(pkmn)
    getCurrentStorage.pbMoveCaughtToParty(pkmn)
  end

  def pbMoveCaughtToBox(pkmn,box)
    getCurrentStorage.pbMoveCaughtToBox(pkmn,box)
  end

  def pbStoreCaught(pkmn)
    getCurrentStorage.pbStoreCaught(pkmn)
  end

  def pbDelete(box,index)
    getCurrentStorage.pbDelete(pkmn)
  end
end



#===============================================================================
#
#===============================================================================
def pbUnlockWallpaper(index)
  $PokemonStorage.unlockedWallpapers[index] = true
end

def pbLockWallpaper(index)   # Don't know why you'd want to do this
  $PokemonStorage.unlockedWallpapers[index] = false
end

#===============================================================================
# Look through Pokémon in storage
#===============================================================================
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      pkmn = $PokemonStorage[i][j]
      yield(pkmn,i) if pkmn
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon { |pkmn,box| yield(pkmn,box) if !pkmn.egg? }
end
