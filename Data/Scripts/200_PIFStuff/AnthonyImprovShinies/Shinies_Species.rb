module GameData
  class Species
    def self.calculateCustomShinyHueOffset(dex_number, bodyShiny, headShiny)
      result = []
      valid_format_rgb = /^\d+ \d+ \d+.\d+ \d+ \d+$/ # Format RGB classique
      valid_format_hex = /^#([0-9a-fA-F]{6}).#([0-9a-fA-F]{6})$/ # Format hexadécimal

      ids = []
      if dex_number <= NB_POKEMON
        ids << dex_number
      else
        ids << getBodyID(dex_number) if bodyShiny
        ids << getHeadID(dex_number, ids[0]) if headShiny
      end
      color_to_stay = []
      ids.each do |id|
        offsets = SHINY_COLOR_OFFSETS[id]
        next unless offsets
        offsets.each_value do |value|
          if value.is_a?(String)
            if value.match?(valid_format_rgb)
              from_rgb, to_rgb = value.split(".").map { |rgb| rgb.split.map(&:to_i) }
              if from_rgb == to_rgb && bodyShiny && headShiny
                color_to_stay << value
                next
              end
              result << value
            elsif value.match?(valid_format_hex)
              from_hex, to_hex = value.split(".")
              from_rgb = hex_to_rgb(from_hex)
              to_rgb = hex_to_rgb(to_hex)
              if from_rgb == to_rgb && bodyShiny && headShiny
                color_to_stay << "#{from_rgb.join(" ")}.#{to_rgb.join(" ")}"
                next
              end
              result << "#{from_rgb.join(" ")}.#{to_rgb.join(" ")}"
            end
          end
        end
      end
      if result.empty?
        "nil"
      elsif bodyShiny && headShiny
        [result.join("|"), color_to_stay.join("|")].reject(&:empty?).join("&")
      else
        result.join("|")
      end
    end



  end
end
