
def playOutfitRemovedAnimation()
  pbSEPlay("shiny", 80, 60)
  $scene.spriteset.addUserAnimation(Settings::OW_SHINE_ANIMATION_ID, $game_player.x, $game_player.y, true)
end

def playOutfitChangeAnimation()
  pbSEPlay("shiny", 80, 100)
  $scene.spriteset.addUserAnimation(Settings::OW_SHINE_ANIMATION_ID, $game_player.x, $game_player.y, true)
end

def selectHairstyle(all_unlocked=false)
  selector = OutfitSelector.new
  display_outfit_preview()
  hat = $Trainer.hat
  commands = ["Next style", "Previous style", "Toggle hat", "Back"]
  previous_input = 0
  # To enable turning the common event that lets you turn around while in the dialog box
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextHairstyle(1,all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextHairstyle(-1,all_unlocked)
      display_outfit_preview()
    when 2 #Toggle hat
      pbSEPlay("GUI storage put down", 80, 100)
      if hat == $Trainer.hat
        $Trainer.hat = nil
      else
        $Trainer.hat = hat
      end
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
  $Trainer.hat = hat
end

def selectHairColor
  display_outfit_preview()
  hat = $Trainer.hat
  commands = ["Shift up", "Shift down", "Toggle hat", "Reset", "Back"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      #playOutfitChangeAnimation()
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftHairColor(10)
      display_outfit_preview()
    when 1 #PREVIOUS
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftHairColor(-10)
      display_outfit_preview()
    when 2 #Toggle hat
      pbSEPlay("GUI storage put down", 80, 100)
      if hat == $Trainer.hat
        $Trainer.hat = nil
      else
        $Trainer.hat = hat
      end
      display_outfit_preview()
    when 3 #Reset
      pbSEPlay("GUI storage put down", 80, 100)
      $Trainer.hair_color = 0
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
  $Trainer.hat = hat
end

def selectHatColor
  display_outfit_preview()
  commands = ["Shift up", "Shift down", "Reset", "Back"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftHatColor(10)
      display_outfit_preview()
    when 1 #PREVIOUS
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftHatColor(-10)
      display_outfit_preview()
    when 2 #Reset
      pbSEPlay("GUI storage put down", 80, 100)
      $Trainer.hat_color = 0
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end

def selectClothesColor
  display_outfit_preview()
  commands = ["Shift up", "Shift down", "Reset", "Back"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftClothesColor(10)
      display_outfit_preview()
    when 1 #PREVIOUS
      pbSEPlay("GUI storage pick up", 80, 100)
      shiftClothesColor(-10)
      display_outfit_preview()
    when 2 #Reset
      pbSEPlay("GUI storage pick up", 80, 100)
      $Trainer.clothes_color = 0
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end

def selectHat(all_unlocked=false)
  selector = OutfitSelector.new
  display_outfit_preview()
  commands = ["Next hat", "Previous hat", "Remove hat", "Back"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextHat(1,all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextHat(-1,all_unlocked)
      display_outfit_preview()
    when 2 #REMOVE HAT
      playOutfitRemovedAnimation()
      $Trainer.hat = nil
      selector.display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end

def spinCharacter
  pbSEPlay("GUI party switch", 80, 100)

end

def selectClothes(all_unlocked=false)
  selector = OutfitSelector.new
  display_outfit_preview()
  commands = ["Next", "Previous"]
  #commands << "Remove clothes (DEBUG)" if $DEBUG
  commands << "Remove" if $DEBUG
  commands << "Back"
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextClothes(1,all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextClothes(-1,all_unlocked)
      display_outfit_preview()
    when 2 #REMOVE CLOTHES
      break if !$DEBUG
      playOutfitRemovedAnimation()
      $Trainer.clothes = nil
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end



def place_hat_on_pokemon(pokemon)
  hatscreen = PokemonHatPresenter.new(nil, pokemon)
  hatscreen.pbStartScreen()
end