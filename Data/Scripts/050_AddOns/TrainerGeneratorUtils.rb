
def pick_trainer_sprite(spriter_name)
  possible_types = "abcd"
  trainer_type_index = select_number_from_seed(spriter_name,0,3)
  path = _INTL("Graphics/Trainers/trainer116{1}",possible_types[trainer_type_index].to_s)
  return path
end

def select_number_from_seed(seed, min_value, max_value)
  hash = 137
  seed.each_byte do |byte|
    hash = ((hash << 5) + hash) + byte
  end
  srand(hash)
  selected_number = rand(min_value..max_value)
  selected_number
end

def pick_spriter_losing_dialog(spriter_name)
  possible_dialogs = [
    "Oh... I lost...",
    "I did my best!",
    "You're too strong!",
    "You win!",
    "What a fight!",
    "That was fun!",
    "Ohh, that's too bad",
    "I should've sprited some stronger Pokémon!",
    "So much for that!",
    "Should've seen that coming!",
    "I can't believe it!",
    "What a surprise!"
  ]
  index = select_number_from_seed(spriter_name,0,possible_dialogs.size-1)
  return possible_dialogs[index]
end
