module GameData
  class TrainerExpert < Trainer
    DATA_FILENAME = "trainers_expert.dat"
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetTrainerData(tr_type, tr_name, tr_version = 0)
  Deprecation.warn_method('pbGetTrainerData', 'v20', 'GameData::Trainer.get(tr_type, tr_name, tr_version)')
  return GameData::Trainer.get(tr_type, tr_name, tr_version)
end
