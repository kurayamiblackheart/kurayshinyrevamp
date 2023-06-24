#===============================================================================
#
#===============================================================================
class AnimatedBitmap
  attr_reader :path
  attr_reader :filename

  def initialize(file, hue = 0)
    raise "Filename is nil (missing graphic)." if file.nil?
    path = file
    filename = ""
    if file.last != '/' # Isn't just a directory
      split_file = file.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join('/') + '/'
    end
    @filename = filename
    @path = path
    if filename[/^\[\d+(?:,\d+)?\]/] # Starts with 1 or 2 numbers in square brackets
      @bitmap = PngAnimatedBitmap.new(path, filename, hue)
    else
      @bitmap = GifBitmap.new(path, filename, hue)
    end
  end

  def pbSetColor(r = 0, g = 0, b = 0, a = 255)
    color = Color.new(r, g, b, a)
    pbSetColorValue(color)
  end

  def pbSetColorValue(color)
    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        if @bitmap.bitmap.get_pixel(i, j).alpha != 0
          @bitmap.bitmap.set_pixel(i, j, color)
        end
      end
    end
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbGetRedChannel
    redChannel = []
    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        redChannel.push(@bitmap.bitmap.get_pixel(i, j).red)
      end
    end
    return redChannel
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbGetBlueChannel
    blueChannel = []
    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        blueChannel.push(@bitmap.bitmap.get_pixel(i, j).blue)
      end
    end
    return blueChannel
  end

  #KurayX - KURAYX_ABOUT_SHINIES
  def pbGetGreenChannel
    greenChannel = []
    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        greenChannel.push(@bitmap.bitmap.get_pixel(i, j).green)
      end
    end
    return greenChannel
  end

  #ChatGPT
  # def getChannelGradient(shiny, redShiny, greenShiny, blueShiny)
  #   if shiny == 1
  #     return greenShiny.clone
  #   elsif shiny == 2
  #     return blueShiny.clone
  #   elsif shiny == 0
  #     return redShiny.clone
  #   elsif shiny == 3
  #     return redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
  #   elsif shiny == 4
  #     return redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
  #   elsif shiny == 5
  #     return greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
  #   elsif shiny == 6
  #     return self.gradientMapping(greenShiny.clone, redShiny.clone)
  #   elsif shiny == 7
  #     return self.gradientMapping(greenShiny.clone, blueShiny.clone)
  #   elsif shiny == 8
  #     return self.gradientMapping(redShiny.clone, greenShiny.clone)
  #   elsif shiny == 9
  #     return self.gradientMapping(redShiny.clone, blueShiny.clone)
  #   elsif shiny == 10
  #     return self.gradientMapping(blueShiny.clone, redShiny.clone)
  #   elsif shiny == 11
  #     return self.gradientMapping(blueShiny.clone, greenShiny.clone)
  #   elsif shiny == 12
  #     colordoing = redShiny.clone
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 13
  #     colordoing = greenShiny.clone
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 14
  #     colordoing = blueShiny.clone
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 15
  #     colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 16
  #     colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 17
  #     colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 18
  #     colordoing = self.gradientMapping(greenShiny.clone, redShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 19
  #     colordoing = self.gradientMapping(greenShiny.clone, blueShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 20
  #     colordoing = self.gradientMapping(redShiny.clone, greenShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 21
  #     colordoing = self.gradientMapping(redShiny.clone, blueShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 22
  #     colordoing = self.gradientMapping(blueShiny.clone, redShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   elsif shiny == 23
  #     colordoing = self.gradientMapping(blueShiny.clone, greenShiny.clone)
  #     return colordoing.map { |r| 255 - r }
  #   end
  # end

  #ChatGPT
  # def gradientMappingOld(sourceChannel, targetChannel)
  #   gradientFactor = 1.0 / (targetChannel.size - 1)
  #   targetChannel.each_index do |i|
  #     startValue = sourceChannel[i]
  #     endValue = sourceChannel[i + 1] || startValue
  #     value = (startValue * (1 - i * gradientFactor) + endValue * (i * gradientFactor)).to_i
  #     targetChannel[i] = value
  #   end
  #   targetChannel
  # end

  # def gradientMapping(sourceChannel, targetChannel, steps = 10)
  #   gradientFactor = 1.0 / (@bitmap.bitmap.width - 1)
  #   rowLength = @bitmap.bitmap.height + 1
  
  #   for i in 0..(@bitmap.bitmap.width - 1)
  #     startIdx = i * rowLength
  #     endIdx = (i + 1) * rowLength - 1
  #     rowValues = sourceChannel[startIdx..endIdx]
  #     minVal = rowValues.compact.min
  #     maxVal = rowValues.compact.max
  #     range = maxVal - minVal
  
  #     if range.zero?
  #       # Assign the values directly if there is no range
  #       rowValues.each_with_index do |value, j|
  #         targetIdx = startIdx + j
  #         targetChannel[targetIdx] = value
  #       end
  #     else
  #       # Interpolate between neighboring colors
  #       stepSize = 1.0 / (steps + 1)
  #       stepWeights = (0..steps).map { |step| step * stepSize }
  
  #       rowValues.each_cons(2).with_index do |(startValue, endValue), j|
  #         targetStartIdx = startIdx + j * (steps + 1)
  #         targetEndIdx = targetStartIdx + steps
  
  #         stepWeights.each_with_index do |weight, k|
  #           value = startValue * (1 - weight) + endValue * weight
  #           interpolatedValue = (value - minVal) / range * 255
  #           targetIdx = targetStartIdx + k
  #           targetChannel[targetIdx] = interpolatedValue
  #         end
  #       end
  #     end
  #   end
  #   targetChannel
  # end

  # def gradientMapping(sourceChannel, targetChannel)
  #   gradientFactor = 1.0 / (@bitmap.bitmap.width - 1)
  #   rowLength = @bitmap.bitmap.height + 1
  #   for i in 0..(@bitmap.bitmap.width - 1)
  #     startIdx = i * rowLength
  #     endIdx = (i + 1) * rowLength - 1
  #     rowValues = sourceChannel[startIdx..endIdx]
  #     minVal = rowValues.compact.min # Find the minimum non-nil value
  #     maxVal = rowValues.compact.max # Find the maximum non-nil value
  #     range = maxVal - minVal
  #     rowValues.each_with_index do |value, j|
  #       targetIdx = startIdx + j
  #       if value.nil?
  #         targetChannel[targetIdx] = nil
  #       elsif range.zero?
  #         targetChannel[targetIdx] = value
  #       else
  #         normalizedValue = (value - minVal).to_f / range
  #         interpolatedValue = (normalizedValue * 255).to_i
  #         targetChannel[targetIdx] = interpolatedValue
  #       end
  #     end
  #   end
  #   targetChannel
  # end

  #KurayX - KURAYX_ABOUT_SHINIES Modified by ChatGPT
  def pbGiveFinaleColor(shinyR, shinyG, shinyB, offset)
    dontmodify = 0
    if shinyR == 0 && shinyG == 1 && shinyB == 2
      dontmodify = 1
    end
    @bitmap = nil
    newbitmap = GifBitmap.new(@path, @filename, offset, shinyR, shinyG, shinyB)
    @bitmap = newbitmap.copy

    greenShiny = []
    redShiny = []
    blueShiny = []
  
    # greeninclude = [1, 3, 5, 6, 7, 8, 11, 13, 15, 17, 18, 19, 20, 23]
    # redinclude = [0, 3, 4, 6, 8, 9, 10, 12, 15, 16, 18, 20, 21, 22]
    # blueinclude = [2, 4, 5, 7, 9, 10, 11, 14, 16, 17, 19, 21, 22, 23]
    greeninclude = [1, 3, 5, 7, 9, 11]
    redinclude = [0, 3, 4, 6, 9, 10]
    blueinclude = [2, 4, 5, 8, 10, 11]
    greenShiny = self.pbGetGreenChannel if greeninclude.include?(shinyR) || greeninclude.include?(shinyB) || greeninclude.include?(shinyG)
    redShiny = self.pbGetRedChannel if redinclude.include?(shinyR) || redinclude.include?(shinyB) || redinclude.include?(shinyG)
    blueShiny = self.pbGetBlueChannel if blueinclude.include?(shinyR) || blueinclude.include?(shinyB) || blueinclude.include?(shinyG)

    # greenShiny = self.pbGetGreenChannel
    # redShiny = self.pbGetRedChannel
    # blueShiny = self.pbGetBlueChannel
  
    canalRed = self.getChannelGradient(shinyR, redShiny, greenShiny, blueShiny)
    canalGreen = self.getChannelGradient(shinyG, redShiny, greenShiny, blueShiny)
    canalBlue = self.getChannelGradient(shinyB, redShiny, greenShiny, blueShiny)
    if dontmodify == 0
      for i in 0..@bitmap.bitmap.width
        for j in 0..@bitmap.bitmap.height
          if @bitmap.bitmap.get_pixel(i, j).alpha != 0
            depth = i * (@bitmap.bitmap.height + 1) + j
            @bitmap.bitmap.set_pixel(i, j, Color.new(canalRed[depth], canalGreen[depth], canalBlue[depth], @bitmap.bitmap.get_pixel(i, j).alpha))
          end
        end
      end
    end
  end

  #ChatGPT
  def getChannelGradient(shiny, redShiny, greenShiny, blueShiny)
    if shiny == 1
      return greenShiny.clone
    elsif shiny == 2
      return blueShiny.clone
    elsif shiny == 0
      return redShiny.clone
    elsif shiny == 3
      return redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
    elsif shiny == 4
      return redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
    elsif shiny == 5
      return greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
    elsif shiny == 6
      colordoing = redShiny.clone
      return colordoing.map { |r| 255 - r }
    elsif shiny == 7
      colordoing = greenShiny.clone
      return colordoing.map { |r| 255 - r }
    elsif shiny == 8
      colordoing = blueShiny.clone
      return colordoing.map { |r| 255 - r }
    elsif shiny == 9
      colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
      return colordoing.map { |r| 255 - r }
    elsif shiny == 10
      colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
      return colordoing.map { |r| 255 - r }
    elsif shiny == 11
      colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
      return colordoing.map { |r| 255 - r }
    end
    # 0 = Red
    # 1 = Green
    # 2 = Blue
    # 3 = Yellow
    # 4 = Magenta
    # 5 = Cyan
    # 6 = Inverse Red
    # 7 = Inverse Green
    # 8 = Inverse Blue
    # 9 = Inverse Yellow
    # 10 = Inverse Magenta
    # 11 = Inverse Cyan
  end

  #KurayX - KURAYX_ABOUT_SHINIES (Default)
  def pbGiveFinaleColorDefault(shinyR, shinyG, shinyB, offset)
    dontmodify = 0
    if shinyR == 0 && shinyG == 1 && shinyB == 2
      dontmodify = 1
    end
    @bitmap = nil
    newbitmap = GifBitmap.new(@path, @filename, offset, shinyR, shinyG, shinyB)
    @bitmap = newbitmap.copy
    greenShiny = []
    redShiny = []
    blueShiny = []
    if shinyR == 1 || shinyB == 1 || shinyG == 1
      # Need Green
      greenShiny = self.pbGetGreenChannel
    end
    if shinyG == 0 || shinyB == 0 || shinyR == 0
      # Need Red
      redShiny = self.pbGetRedChannel
    end
    if shinyG == 2 || shinyR == 2 || shinyB == 2
      # Need Blue
      blueShiny = self.pbGetBlueChannel
    end
    if shinyR == 1
      canalRed = greenShiny.clone
    elsif shinyR == 2
      canalRed = blueShiny.clone
    else
      canalRed = redShiny.clone
    end
    if shinyG == 1
      canalGreen = greenShiny.clone
    elsif shinyG == 2
      canalGreen = blueShiny.clone
    else
      canalGreen = redShiny.clone
    end
    if shinyB == 1
      canalBlue = greenShiny.clone
    elsif shinyB == 2
      canalBlue = blueShiny.clone
    else
      canalBlue = redShiny.clone
    end
    # File.open('LogColors.txt' + ".txt", 'a') { |f| f.write("Inside !\r") }
    if dontmodify == 0
      # File.open('LogColors.txt' + ".txt", 'a') { |f| f.write("Modifying !\r") }
      for i in 0..@bitmap.bitmap.width
        for j in 0..@bitmap.bitmap.height
          if @bitmap.bitmap.get_pixel(i, j).alpha != 0
            depth = i*(@bitmap.bitmap.height+1)+j
            @bitmap.bitmap.set_pixel(i, j, Color.new(canalRed[depth], canalGreen[depth], canalBlue[depth], @bitmap.bitmap.get_pixel(i, j).alpha))
          end
        end
      end
    end
    # @bitmap = GifBitmap.new(@path, @filename, offset)
  end
  
  def shiftColors(offset = 0)
    @bitmap = GifBitmap.new(@path, @filename, offset)
    # @bitmap = nil
    # newbitmap = GifBitmap.new(@path, @filename, offset)
    # @bitmap = newbitmap.clone
  end

  def [](index)
    ; @bitmap[index];
  end

  def width
    @bitmap.bitmap.width;
  end

  def height
    @bitmap.bitmap.height;
  end

  def length
    @bitmap.length;
  end

  def each
    @bitmap.each { |item| yield item };
  end

  def bitmap
    @bitmap.bitmap;
  end

  def currentIndex
    @bitmap.currentIndex;
  end

  def totalFrames
    @bitmap.totalFrames;
  end

  def disposed?
    @bitmap.disposed?;
  end

  def update
    @bitmap.update;
  end

  def dispose
    @bitmap.dispose;
  end

  def deanimate
    @bitmap.deanimate;
  end

  def copy
    @bitmap.copy;
  end

  def scale_bitmap(scale)
    return if scale == 1
    new_width = (@bitmap.bitmap.width * scale).floor #Sylvi Big Icons
    new_height = (@bitmap.bitmap.height * scale).floor #Sylvi Big Icons

    return if new_width <= 0 || new_height <= 0 #Sylvi Big Icons

    destination_rect = Rect.new(0, 0, new_width, new_height)
    source_rect = Rect.new(0, 0, @bitmap.bitmap.width, @bitmap.bitmap.height)
    new_bitmap = Bitmap.new(new_width, new_height)
    new_bitmap.stretch_blt(
      destination_rect,
      @bitmap.bitmap,
      source_rect
    )
    @bitmap.bitmap = new_bitmap
  end

  # def mirror
  #   for x in 0..@bitmap.bitmap.width / 2
  #     for y in 0..@bitmap.bitmap.height - 2
  #       temp = @bitmap.bitmap.get_pixel(x, y)
  #       newPix = @bitmap.bitmap.get_pixel((@bitmap.bitmap.width - x), y)
  #
  #       @bitmap.bitmap.set_pixel(x, y, newPix)
  #       @bitmap.bitmap.set_pixel((@bitmap.bitmap.width - x), y, temp)
  #     end
  #   end
  # end

  def mirror
    @bitmap.bitmap
  end

end

#===============================================================================
#
#===============================================================================
class PngAnimatedBitmap
  attr_accessor :frames

  # Creates an animated bitmap from a PNG file.
  def initialize(dir, filename, hue = 0)
    @frames = []
    @currentFrame = 0
    @framecount = 0
    panorama = RPG::Cache.load_bitmap(dir, filename, hue)
    if filename[/^\[(\d+)(?:,(\d+))?\]/] # Starts with 1 or 2 numbers in brackets
      # File has a frame count
      numFrames = $1.to_i
      delay = $2.to_i
      delay = 10 if delay == 0
      raise "Invalid frame count in #{filename}" if numFrames <= 0
      raise "Invalid frame delay in #{filename}" if delay <= 0
      if panorama.width % numFrames != 0
        raise "Bitmap's width (#{panorama.width}) is not divisible by frame count: #{filename}"
      end
      @frameDelay = delay
      subWidth = panorama.width / numFrames
      for i in 0...numFrames
        subBitmap = BitmapWrapper.new(subWidth, panorama.height)
        subBitmap.blt(0, 0, panorama, Rect.new(subWidth * i, 0, subWidth, panorama.height))
        @frames.push(subBitmap)
      end
      panorama.dispose
    else
      @frames = [panorama]
    end
  end

  def [](index)
    return @frames[index]
  end

  def width
    self.bitmap.width;
  end

  def height
    self.bitmap.height;
  end

  def deanimate
    for i in 1...@frames.length
      @frames[i].dispose
    end
    @frames = [@frames[0]]
    @currentFrame = 0
    return @frames[0]
  end

  def bitmap
    return @frames[@currentFrame]
  end

  def currentIndex
    return @currentFrame
  end

  def frameDelay(_index)
    return @frameDelay
  end

  def length
    return @frames.length
  end

  def each
    @frames.each { |item| yield item }
  end

  def totalFrames
    return @frameDelay * @frames.length
  end

  def disposed?
    return @disposed
  end

  def update
    return if disposed?
    if @frames.length > 1
      @framecount += 1
      if @framecount >= @frameDelay
        @framecount = 0
        @currentFrame += 1
        @currentFrame %= @frames.length
      end
    end
  end

  def dispose
    if !@disposed
      @frames.each { |f| f.dispose }
    end
    @disposed = true
  end

  def copy
    x = self.clone
    x.frames = x.frames.clone
    for i in 0...x.frames.length
      x.frames[i] = x.frames[i].copy
    end
    return x
  end
end

#===============================================================================
#
#===============================================================================
class GifBitmap
  attr_accessor :bitmap
  ###KurayX - KURAYX_ABOUT_SHINIES
  attr_accessor :rcode
  attr_accessor :gcode
  attr_accessor :bcode
  ###KurayX - KURAYX_ABOUT_SHINIES
  attr_reader :loaded_from_cache
  # Creates a bitmap from a GIF file. Can also load non-animated bitmaps.
  def initialize(dir, filename, hue = 0, rcode=0, gcode=1, bcode=2)
    @bitmap = nil
    #KurayX - KURAYX_ABOUT_SHINIES
    @rcode = 0
    @gcode = 1
    @bcode = 2
    # @greenorigin = []
    # @redorigin = []
    # @blueorigin = []
    # @greenoriginlocked = 0
    # @blueoriginlocked = 0
    # @redoriginlocked = 0
    #KurayX - KURAYX_ABOUT_SHINIES
    @disposed = false
    @loaded_from_cache = false
    filename = "" if !filename
    begin
      #KurayX - KURAYX_ABOUT_SHINIES
      @bitmap = RPG::Cache.load_bitmap(dir, filename, hue, rcode, gcode, bcode)
      @loaded_from_cache = true
    rescue
      @bitmap = nil
    end
    @bitmap = BitmapWrapper.new(32, 32) if @bitmap.nil?
    @bitmap.play if @bitmap&.animated?
  end

  ##### KURAYX

  # def greenorigin
  #   @greenorigin
  # end

  # def greenoriginlocked
  #   @greenoriginlocked
  # end

  # def greenoriginlocked=(value)
  #   @greenoriginlocked=value
  # end

  # def greenorigin=(value)
  #   @greenorigin=value
  # end

  # def redorigin
  #   @redorigin
  # end

  # def redoriginlocked
  #   @redoriginlocked
  # end

  # def redoriginlocked=(value)
  #   @redoriginlocked=value
  # end

  # def redorigin=(value)
  #   @redorigin=value
  # end

  # def blueorigin
  #   @blueorigin
  # end

  # def blueoriginlocked
  #   @blueoriginlocked
  # end

  # def blueoriginlocked=(value)
  #   @blueoriginlocked=value
  # end

  # def blueorigin=(value)
  #   @blueorigin=value
  # end

  ##### KURAYX

  def [](_index)
    return @bitmap
  end

  def deanimate
    @bitmap&.goto_and_stop(0) if @bitmap&.animated?
    return @bitmap
  end

  def currentIndex
    return @bitmap&.current_frame || 0
  end

  def length
    return @bitmap&.frame_count || 1
  end

  def each
    yield @bitmap
  end

  def totalFrames
    f_rate = @bitmap.frame_rate
    f_rate = 1 if f_rate.nil? || f_rate == 0
    return (@bitmap) ? (@bitmap.frame_count / f_rate).floor : 1
  end

  def disposed?
    return @disposed
  end

  def width
    return @bitmap&.width || 0
  end

  def height
    return @bitmap&.height || 0
  end

  # Gifs are animated automatically by mkxp-z. This function does nothing.
  def update; end

  def dispose
    return if @disposed
    @bitmap.dispose
    @disposed = true
  end

  def copy
    x = self.clone
    x.bitmap = @bitmap.copy if @bitmap
    return x
  end
end

#===============================================================================
#
#===============================================================================
def pbGetTileBitmap(filename, tile_id, hue, width = 1, height = 1)
  return RPG::Cache.tileEx(filename, tile_id, hue, width, height) { |f|
    AnimatedBitmap.new("Graphics/Tilesets/" + filename).deanimate
  }
end

def pbGetTileset(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Tilesets/" + name, hue).deanimate
end

def pbGetAutotile(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Autotiles/" + name, hue).deanimate
end

def pbGetAnimation(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Animations/" + name, hue).deanimate
end
