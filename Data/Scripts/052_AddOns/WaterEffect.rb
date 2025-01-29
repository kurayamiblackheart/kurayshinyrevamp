PUDDLE_ANIMATION_ID = 22
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0] # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      mapTerrainTag = $MapFactory.getTerrainTag(event.map.map_id, x, y, false)
      if $PokemonGlobal.surfing
        if isWaterTerrain?(mapTerrainTag) #&& $PokemonGlobal.stepcount % 2 ==0
          $scene.spriteset.addUserAnimation(PUDDLE_ANIMATION_ID, event.x, event.y, true, 0)
        end
      else
        if mapTerrainTag == 16 #puddle
          pbSEPlay("puddle", 100) if event == $game_player && !$PokemonGlobal.surfing #only play sound effect in puddle
          $scene.spriteset.addUserAnimation(PUDDLE_ANIMATION_ID, event.x, event.y, true, 0)
        end
      end
    end
  end
}

def isWaterTerrain?(tag)
  return [5, 6, 17, 7, 9, 16].include?(tag)
end
