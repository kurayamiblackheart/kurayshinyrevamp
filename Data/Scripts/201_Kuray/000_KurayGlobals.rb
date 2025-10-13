# Kuray Global

# Just a new .rb files for global functions, to start organizing shit around


# Used for PIF shinies to convert HEX values to RGB
def hex_to_rgb(hex)
  hex = hex.delete("#")
  r = hex[0..1].to_i(16)
  g = hex[2..3].to_i(16)
  b = hex[4..5].to_i(16)
  [r, g, b]
end

def rollimproveshiny()
  return rand(0..3)
end

def access_deprecated_kurayshiny()
  return 0
  # $PokemonSystem.kuraynormalshiny is deprecated, as the new PIF system has been implemented. do not replace this 0 by anything else.
  # this is a non-destructive (preservation) way of disabling the old deprecated code.
end