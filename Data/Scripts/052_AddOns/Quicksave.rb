#==============================================================================#
#                                   Quicksave                                  #
#                         by Marin, updated by CrystalStar                     #
#==============================================================================#

class Scene_Map
	def pbSaveScreen
		ret = false
		@scene.pbStartScreen
		if pbConfirmMessage(_INTL("Would you like to save the game?"))
		  if SaveData.exists? && $game_temp.begun_new_game
			pbMessage(_INTL("WARNING!"))
			pbMessage(_INTL("There is a different game file that is already saved."))
			pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
			if !pbConfirmMessageSerious(_INTL("Are you sure you want to save now and overwrite the other save file?"))
			  pbSEPlay("GUI save choice")
			  @scene.pbEndScreen
			  return false
			end
		  end
		  $game_temp.begun_new_game = false
		  pbSEPlay("GUI save choice")
		  if Game.save
			pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $player.name))
			ret = true
		  else
			pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
			ret = false
		  end
		else
		  pbSEPlay("GUI save choice")
		end
		@scene.pbEndScreen
		return ret
	  end
	alias quicksave_update update unless method_defined?(:quicksave_update)
	  def update
		quicksave_update
		if Input.trigger?(Input::JUMPDOWN) && $PokemonSystem.quicksave == 1
		if Scene_Map.pbSaveScreen
			else
			pbMessage("Save failed.")
			end
		end
	end
end
