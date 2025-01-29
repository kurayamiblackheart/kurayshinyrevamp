
def getDirection(x_incr,y_incr)
  return DIRECTION_RIGHT if x_incr>0
  return DIRECTION_LEFT if x_incr<0
  return DIRECTION_DOWN if y_incr>0
  return DIRECTION_UP if y_incr<0
  return 0
end


def get_direction_forward_x(directionId)
  return 1 if directionId == DIRECTION_RIGHT
  return -1 if directionId == DIRECTION_LEFT
  return 0
end


def get_direction_forward_y(directionId)
  return 1 if directionId == DIRECTION_DOWN
  return -1 if directionId == DIRECTION_UP
  return 0
end




#Basic pathfinding to move an event towards a certain general direction while avoiding obstacles
def pathFindingGetDirection(current_x,current_y,goal_direction,pathfindingRange=4)
  goal_direction_is_horizontal = goal_direction == DIRECTION_RIGHT || goal_direction == DIRECTION_LEFT
  direction_forward_x = get_direction_forward_x(goal_direction)
  direction_forward_y = get_direction_forward_y(goal_direction)
  #echoln "Goal direction :#{goal_direction}. ForwardX: #{direction_forward_x}. ForwardY: #{direction_forward_y}"
  if(eventCanPassThrough(current_x+direction_forward_x,current_y+direction_forward_y,goal_direction))
    return goal_direction
  else
    if goal_direction_is_horizontal
      alternate_direction_x=direction_forward_x
      alternate_direction_y=1
    else
      alternate_direction_x=1
      alternate_direction_y=direction_forward_y
    end

    echoln "###########  CURRENT_POSITION: #{current_x},#{current_y}"
    direction_polarities = [1,-1]

    for i in 1..pathfindingRange
      for polarity in direction_polarities
        new_x = goal_direction_is_horizontal ? current_x+ direction_forward_x : current_x+((i*alternate_direction_x)*polarity)
        new_y = !goal_direction_is_horizontal ? current_y + direction_forward_y : current_y+((i*alternate_direction_y)*polarity)
        echoln "Checking for #{new_x}, #{new_y}"
        if eventCanPassThrough(new_x,new_y,goal_direction)
          if goal_direction_is_horizontal
            new_direction = getDirection(0,(i*alternate_direction_y)*polarity)
            echoln "found a gap! new direction x: #{0}, new direction y: #{(i*alternate_direction_y)*polarity}"
            if eventCanPassThrough(current_x,current_y+polarity,goal_direction)
              return new_direction
            else
              echoln "...but cannot go in that direction (#{current_x},#{current_y+new_direction} blocked)"
            end
          else
            new_direction = getDirection((i*alternate_direction_x)*polarity,0)
            if eventCanPassThrough(current_x+polarity,current_y,goal_direction)
              return new_direction
            else
              echoln "...but cannot go in that direction"
            end
          end
        end
      end
    end
  end
  return 0
end

def eventCanPassThrough(x, y, direction)
  if x == $game_player.x && y == $game_player.y
    echoln "cannot pass because of player"
    return false
  end

  $PokemonTemp.dependentEvents.realEvents.each { |dependantEvent|
    if x == dependantEvent.x && y == dependantEvent.y
      echoln "cannot pass because of dependant event #{dependantEvent.name}(#{dependantEvent.x},#{dependantEvent.y})"
      return false
    end
  }
  return $game_player.passable?(x, y, direction)
end