
class PokemonTemp
  attr_accessor :tempEvents
  attr_accessor :silhouetteDirection

  def tempEvents
    @tempEvents = {} if !@tempEvents
    return @tempEvents
  end



  def pbClearTempEvents()
    @tempEvents.keys.each {|map_id|
      map = $MapFactory.getMap(map_id)
      @tempEvents[map_id].each { |event|
        map.events[event.id].erase if map.events[event.id]
      }
    }
    @tempEvents={}
    @silhouetteDirection=nil
  end


  def addTempEvent(map,event)
    @tempEvents = {} if !@tempEvents
    mapEvents = @tempEvents.has_key?(map) ? @tempEvents[map] : []
    mapEvents.push(event)
    @tempEvents[map] = mapEvents
  end


end

