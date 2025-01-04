def fill_flags_room()

  #read info from json,
  #
  # line ID
  # frameType
  # image


end

#x_pos, y_pos will be taken from an predefined map
def build_flag_event(flag_id,frame_type,x_pos,y_pos)
  rpgEvent = RPG::Event.new(x_pos,y_pos)
  gameEvent = Game_Event.new($game_map.map_id, rpgEvent, $game_map)


end
