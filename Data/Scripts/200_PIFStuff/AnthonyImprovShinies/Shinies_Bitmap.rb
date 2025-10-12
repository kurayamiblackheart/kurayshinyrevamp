class Bitmap

  def hue_customcolor(rules_string)
    return if rules_string.nil? || rules_string == "nil"
    if rules_string.include?("&")
      rules_string.split("&").each do |part|
        part = part.strip
        next if part.empty?
        hue_customcolor(part)
      end
      return
    end
    rules = rules_string.split("|").map do |str|
      parts = str.split(".")
      {
        from: parts[0].split.map(&:to_f),
        to: parts[1].split.map(&:to_f)
      }
    end
    width.times do |x|
      height.times do |y|
        color = get_pixel(x, y)
        next if color.alpha == 0
        r, g, b = color.red.to_f, color.green.to_f, color.blue.to_f
        # Avoid division by zero
        r = 10 if r <= 10
        g = 10 if g <= 10
        b = 10 if b <= 10

        min_distance = Float::INFINITY
        closest_rule = nil

        rules.each do |rule|
          from = rule[:from]
          # Avoid division by zero
          from[0] = 10 if from[0] <= 10
          from[1] = 10 if from[1] <= 10
          from[2] = 10 if from[2] <= 10
          dist = (r - from[0])**2 + (g - from[1])**2 + (b - from[2])**2
          if dist < min_distance
            min_distance = dist
            closest_rule = rule
          end
        end

        next unless closest_rule

        from = closest_rule[:from]
        to = closest_rule[:to]
        # Avoid multiplication by zero
        to[0] = 10 if to[0] <= 10
        to[1] = 10 if to[1] <= 10
        to[2] = 10 if to[2] <= 10
        r_factor = r / from[0]
        g_factor = g / from[1]
        b_factor = b / from[2]

        adjusted_r = (to[0] * r_factor).clamp(0, 255)
        adjusted_g = (to[1] * g_factor).clamp(0, 255)
        adjusted_b = (to[2] * b_factor).clamp(0, 255)
        set_pixel(x, y, Color.new(adjusted_r.to_i, adjusted_g.to_i, adjusted_b.to_i, color.alpha))
      end
    end
  end
  
end