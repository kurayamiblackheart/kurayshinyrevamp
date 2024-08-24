#This is a small edit made by DemICE for http404error's Auto Multi Save Plugin that adds an infinite save backup functionality
#CAUTION: THIS PLUGIN MUST ALWAYS BE READ AFTER THE BASE AUTO MULTI SAVE PLUGIN

class Player
  attr_accessor :inf_backup_slots

  alias inf_backup_slots_initialize initialize unless method_defined?(:inf_backup_slots_initialize)
  def initialize(name, trainer_type)
    inf_backup_slots_initialize(name, trainer_type)
    @inf_backup_slots= [0,0,0,0,0,0,0,0]
  end

end

class PokemonSaveScreen

  alias backup_doSave doSave unless method_defined?(:backup_doSave)
  def doSave(slot)
    if $Trainer.save_slot
      #We create the backup file's name components
      totalsec = (Graphics.frame_count || 0)  / Graphics.frame_rate
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      mapname = pbGetMapNameFromId($game_map.map_id)
      save_slot=0
      for i in 0..SaveData::MANUAL_SLOTS.length
        if SaveData::MANUAL_SLOTS[i]==$Trainer.save_slot
          save_slot=i
        end
      end

      #Create the backup slots array for not new save files.
      if !$Trainer.inf_backup_slots
        $Trainer.inf_backup_slots=[0,0,0,0,0,0,0,0]
      end

      #We increase the backup count for our current save slot
      $Trainer.inf_backup_slots[save_slot]+=1

      #We piece together the backup file's name
      if $backupName!=""
        backup_slot=$Trainer.save_slot + ' - ' + $backupName
      else
        backup_slot = $Trainer.save_slot + ' ' + $Trainer.inf_backup_slots[save_slot].to_s + ' ' + hour.to_s + 'h' + ' ' + min.to_s + 'm' + ' ' + mapname
      end

    end

    #We run http404error's doSave method and save the game
    if backup_doSave(slot)
      #THEN we create our backup on top of that.
      Game.save(backup_slot,true) if $Trainer.save_slot
      return true
    end
    return false
  end

  # DemICE overrides the method from Auto Multi Save
  # Return true if pause menu should close after this is done (if the game was saved successfully)
  def pbSaveScreen(exiting=false)
    ret = false
    @scene.pbStartScreen
    if !$Trainer.save_slot
      # New Game - must select slot
      ret = slotSelect
    else
      #DemICE initialize backup name
      $backupName=""
      choices = [
        _INTL("Save to #{$Trainer.save_slot}"),
        _INTL("Save to another file"),
        _INTL("Name the next backup"),
        _INTL("Open the save folder"),
        exiting ? _INTL("Quit without saving") : _INTL("Cancel")
      ]
      opt = pbMessage(_INTL('Would you like to save the game?'),choices,5)
      if opt == 0
        pbSEPlay('GUI save choice')
        ret = doSave($Trainer.save_slot)
      elsif opt == 1
        pbPlayDecisionSE
        ret = slotSelect
        #DemICE input backup name
      elsif opt == 2
        pbPlayDecisionSE
        $backupName = Kernel.pbMessageFreeText(_INTL("Backup name:"),"",false,999,500)
        choices = [
          _INTL("Save to #{$Trainer.save_slot}"),
          _INTL("Save to another file"),
          exiting ? _INTL("Quit without saving") : _INTL("Cancel")
        ]
        opt = pbMessage(_INTL('Choose a Save Slot'),choices,3)
        if opt == 0
          pbSEPlay('GUI save choice')
          ret = doSave($Trainer.save_slot)
        elsif opt == 1
          pbPlayDecisionSE
          ret = slotSelect
        else
          pbPlayCancelSE
        end
      elsif opt == 3
        if System.platform[/Windows/]
          folderpath = RTP.getSaveFolder
          folderpath.gsub!('\\','\\\\')
          folderpath.gsub!('/','\\\\')
          system("explorer #{folderpath}")
        elsif System.platform[/Mac/]
          folderpath = RTP.getSaveFolder
          System.open(folderpath)
        elsif System.platform[/Linux/]
          folderpath = RTP.getSaveFolder
        end
      else
        pbPlayCancelSE
      end
    end
    @scene.pbEndScreen
    return ret
  end

end
