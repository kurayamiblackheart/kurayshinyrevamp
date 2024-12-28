
class ByteWriter
  def initialize(filename)
    @file = File.new(filename, "wb")
  end

  def <<(*data)
    write(*data)
  end

  def write(*data)
    data.each do |e|
      if e.is_a?(Array) || e.is_a?(Enumerator)
        e.each { |item| write(item) }
      elsif e.is_a?(Numeric)
        @file.putc e
      else
        raise "Invalid data for writing.\nData type: #{e.class}\nData: #{e.inspect[0..100]}"
      end
    end
  end

  def write_int(int)
    self << ByteWriter.to_bytes(int)
  end

  def close
    @file.close
    @file = nil
  end

  def self.to_bytes(int)
    return [
      (int >> 24) & 0xFF,
      (int >> 16) & 0xFF,
      (int >> 8) & 0xFF,
      int & 0xFF
    ]
  end
end

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
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 13
  #     colordoing = greenShiny.clone
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 14
  #     colordoing = blueShiny.clone
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 15
  #     colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 16
  #     colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 17
  #     colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 18
  #     colordoing = self.gradientMapping(greenShiny.clone, redShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 19
  #     colordoing = self.gradientMapping(greenShiny.clone, blueShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 20
  #     colordoing = self.gradientMapping(redShiny.clone, greenShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 21
  #     colordoing = self.gradientMapping(redShiny.clone, blueShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 22
  #     colordoing = self.gradientMapping(blueShiny.clone, redShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
  #   elsif shiny == 23
  #     colordoing = self.gradientMapping(blueShiny.clone, greenShiny.clone)
  #     return colordoing.map { |r| 255.0 - r }
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


  # def export_bitmap_to_png(file_path)
  #   require 'zlib'
  #   # Ensure @bitmap is not nil
  #   return unless @bitmap

  #   # Open a file for writing in binary mode
  #   File.open(file_path, 'wb') do |file|
  #     # Write PNG signature
  #     file.write("\x89PNG\r\n\x1a\n".force_encoding('ASCII-8BIT'))

  #     # Write IHDR chunk (image header)
  #     ihdr_data = [
  #       @bitmap.bitmap.width.to_i, # Width
  #       @bitmap.bitmap.height.to_i, # Height
  #       8, # Bit depth (8 bits per channel)
  #       6, # Color type (RGBA)
  #       0, # Compression method (deflate)
  #       0, # Filter method (adaptive)
  #       0  # Interlace method (no interlace)
  #     ].pack('N2C5')
  #     file.write([ihdr_data.length].pack('N'))
  #     file.write('IHDR')
  #     file.write(ihdr_data)
  #     file.write([Zlib.crc32('IHDR' + ihdr_data)].pack('N'))

  #     # Write IDAT chunk (image data)
  #     pixels = @bitmap.bitmap.export_pixels_to_str(0, 0, @bitmap.bitmap.width, @bitmap.bitmap.height, 'RGBA')
  #     zlib_data = Zlib.deflate(pixels)
  #     file.write([zlib_data.length].pack('N'))
  #     file.write('IDAT')
  #     file.write(zlib_data)
  #     file.write([Zlib.crc32('IDAT' + zlib_data)].pack('N'))

  #     # Write IEND chunk (image end)
  #     file.write([0].pack('N'))
  #     file.write('IEND')
  #     file.write([Zlib.crc32('IEND')].pack('N'))
  #   end
  # end

  def bitmap_to_png(filename)
    return unless @bitmap
    require 'zlib'
    f = ByteWriter.new(filename)

    #============================= Writing header ===============================#
    # PNG signature
    f << [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    # Header length
    f << [0x00, 0x00, 0x00, 0x0D]
    # IHDR
    headertype = [0x49, 0x48, 0x44, 0x52]
    f << headertype

    # Width, height, compression, filter, interlacing
    headerdata = ByteWriter.to_bytes(@bitmap.width).
      concat(ByteWriter.to_bytes(@bitmap.height)).
      concat([0x08, 0x06, 0x00, 0x00, 0x00])
    f << headerdata

    # CRC32 checksum
    sum = headertype.concat(headerdata)
    f.write_int Zlib::crc32(sum.pack("C*"))

    #============================== Writing data ================================#
    data = []
    for y in 0...@bitmap.height
      # Start scanline
      data << 0x00 # Filter: None
      for x in 0...@bitmap.width
        px = @bitmap.bitmap.get_pixel(x, y)
        # Write raw RGBA pixels
        data << px.red
        data << px.green
        data << px.blue
        data << px.alpha
      end
    end
    # Zlib deflation
    smoldata = Zlib::Deflate.deflate(data.pack("C*")).bytes
    # data chunk length
    f.write_int smoldata.size
    # IDAT
    f << [0x49, 0x44, 0x41, 0x54]
    f << smoldata
    # CRC32 checksum
    f.write_int Zlib::crc32([0x49, 0x44, 0x41, 0x54].concat(smoldata).pack("C*"))

    #============================== End Of File =================================#
    # Empty chunk
    f << [0x00, 0x00, 0x00, 0x00]
    # IEND
    f << [0x49, 0x45, 0x4E, 0x44]
    # CRC32 checksum
    f.write_int Zlib::crc32([0x49, 0x45, 0x4E, 0x44].pack("C*"))
    f.close
    return nil
  end

  # Not working?
  def export_bitmap_to_png(file_path)
    # Ensure @bitmap is not nil
    return unless @bitmap
    require 'zlib'

    width = @bitmap.bitmap.width
    height = @bitmap.bitmap.height

    # Open a file for writing in binary mode
    File.open(file_path, 'wb') do |file|
      # Write PNG signature
      file.write("\x89PNG\r\n\x1a\n".force_encoding('ASCII-8BIT'))

      # Write IHDR chunk (image header)
      ihdr_data = [
        width,          # Width
        height,         # Height
        8,              # Bit depth (8 bits per channel)
        6,              # Color type (RGBA)
        0,              # Compression method (deflate)
        0,              # Filter method (adaptive)
        0               # Interlace method (no interlace)
      ].pack('N2C5')
      write_chunk(file, 'IHDR', ihdr_data)

      # Write IDAT chunk (image data)
      pixels = generate_pixel_data(width, height)
      zlib_data = Zlib.deflate(pixels)
      write_chunk(file, 'IDAT', zlib_data)

      # Write IEND chunk (image end)
      write_chunk(file, 'IEND', '')
    end
  end

  # Not working?
  def generate_pixel_data(width, height)
    pixel_data = ''.force_encoding('ASCII-8BIT')
    for i in 0...width
      for j in 0...height
        alpha = @bitmap.bitmap.get_pixel(i, j).alpha
        red = @bitmap.bitmap.get_pixel(i, j).red
        green = @bitmap.bitmap.get_pixel(i, j).green
        blue = @bitmap.bitmap.get_pixel(i, j).blue
        # red = canalRed[i * (@bitmap.bitmap.height + 1) + j]
        # green = canalGreen[i * (@bitmap.bitmap.height + 1) + j]
        # blue = canalBlue[i * (@bitmap.bitmap.height + 1) + j]
        pixel_data << [red, green, blue, alpha].pack('C4')
      end
    end
    pixel_data
  end

  # Not working?
  def write_chunk(file, type, data)
    file.write([data.length].pack('N'))
    file.write(type)
    file.write(data)
    file.write([Zlib.crc32(type + data)].pack('N'))
  end

  #KurayX - KURAYX_ABOUT_SHINIES Modified by ChatGPT
  def pbGiveFinaleColor(shinyR, shinyG, shinyB, offset, shinyKRS)
    # dontmodify = 0
    # if shinyR == 0 && shinyG == 1 && shinyB == 2
    #   dontmodify = 1
    # end
    @bitmap = nil
    usedoffset = offset
    # call load function for shiny if said shiny exists in cache
    # return afterwards if it does (load the file)
    loadedfromcache = false
    # puts "Path: #{@path}"
    # puts "Filename: #{@filename}"
    if $PokemonSystem && $PokemonSystem.shiny_cache != 2
      # File.exists?(usinglocation + "Disabled")
      originfolder = getPathForShinyCache(@path)
      checkDirectory("Cache")
      checkDirectory("Cache/Shiny")
      shinyname = "_#{offset+180}_#{shinyR}_#{shinyG}_#{shinyB}"
      for i in 0..shinyKRS.size-1
        shinyname += "_#{shinyKRS[i]}"
      end
      pathimport = "Cache/Shiny/"
      cleanname = @filename[0...-4]
      pathfilename = originfolder + cleanname + shinyname + ".png"
      if File.exists?(pathimport + pathfilename)
        @filename = pathfilename
        @path = pathimport
        usedoffset = 0
        loadedfromcache = true
      end
    end

    # puts "After Path: #{@path}"
    # puts "After Filename: #{@filename}"
    # puts "Loaded from cache: #{loadedfromcache}"
    newbitmap = GifBitmap.new(@path, @filename, usedoffset, shinyR, shinyG, shinyB)
    @bitmap = newbitmap.copy
    if ($PokemonSystem.shinyadvanced != nil && $PokemonSystem.shinyadvanced == 0) || loadedfromcache
      return
    end

    greenShiny = []
    redShiny = []
    blueShiny = []
  
    # greeninclude = [1, 3, 5, 6, 7, 8, 11, 13, 15, 17, 18, 19, 20, 23]
    # redinclude = [0, 3, 4, 6, 8, 9, 10, 12, 15, 16, 18, 20, 21, 22]
    # blueinclude = [2, 4, 5, 7, 9, 10, 11, 14, 16, 17, 19, 21, 22, 23]
    greeninclude = [1, 3, 5, 7, 9, 11, 12, 13, 14, 16, 17, 19, 20, 22, 23, 25]
    redinclude = [0, 3, 4, 6, 9, 10, 12, 13, 14, 15, 17, 18, 20, 21, 23, 24]
    blueinclude = [2, 4, 5, 8, 10, 11, 12, 13, 15, 16, 18, 19, 21, 22, 24, 25]
    greenShiny = self.pbGetGreenChannel if greeninclude.include?(shinyR) || greeninclude.include?(shinyB) || greeninclude.include?(shinyG) || shinyKRS[4] > 0
    redShiny = self.pbGetRedChannel if redinclude.include?(shinyR) || redinclude.include?(shinyB) || redinclude.include?(shinyG) || shinyKRS[3] > 0
    blueShiny = self.pbGetBlueChannel if blueinclude.include?(shinyR) || blueinclude.include?(shinyB) || blueinclude.include?(shinyG) || shinyKRS[5] > 0

    if $PokemonSystem.shinyadvanced != nil && $PokemonSystem.shinyadvanced == 2
      if shinyKRS[3] > 0
        redShiny = self.krsapply(redShiny, shinyKRS[3], 0, shinyKRS)
      end
      if shinyKRS[4] > 0
        greenShiny = self.krsapply(greenShiny, shinyKRS[4], 1, shinyKRS)
      end
      if shinyKRS[5] > 0
        blueShiny = self.krsapply(blueShiny, shinyKRS[5], 2, shinyKRS)
      end
    end

    # greenShiny = self.pbGetGreenChannel
    # redShiny = self.pbGetRedChannel
    # blueShiny = self.pbGetBlueChannel
  
    # if dontmodify == 0 || ($PokemonSystem.shinyadvanced != nil && $PokemonSystem.shinyadvanced != 0)
    canalRed = self.getChannelGradient(shinyR, redShiny, greenShiny, blueShiny, shinyKRS, 0)
    canalGreen = self.getChannelGradient(shinyG, redShiny, greenShiny, blueShiny, shinyKRS, 1)
    canalBlue = self.getChannelGradient(shinyB, redShiny, greenShiny, blueShiny, shinyKRS, 2)

    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        # begin
        if @bitmap.bitmap.get_pixel(i, j).alpha != 0
          depth = i * (@bitmap.bitmap.height + 1) + j
          @bitmap.bitmap.set_pixel(i, j, Color.new(canalRed[depth], canalGreen[depth], canalBlue[depth], @bitmap.bitmap.get_pixel(i, j).alpha))
        end
        # rescue TypeError => e
        #   puts "Caught TypeError: #{e.message}"
        #   puts "i: #{i}, j: #{j}"
        #   puts "Canal Red: #{canalRed[depth]}"
        #   puts "Canal Green: #{canalGreen[depth]}"
        #   puts "Canal Blue: #{canalBlue[depth]}"
        #   puts "Depth: #{depth}"
        # end
      end
    end
    # end
    if $PokemonSystem && $PokemonSystem.shiny_cache != 2
      # Save the generated shiny sprite in the Cache folder
      # puts "Filename: #{@filename}"
      # puts "Path: #{@path}"
      originfolder = getPathForShinyCache(@path)
      checkDirectory("Cache")
      checkDirectory("Cache/Shiny")
      shinyname = "_#{offset+180}_#{shinyR}_#{shinyG}_#{shinyB}"
      for i in 0..shinyKRS.size-1
        shinyname += "_#{shinyKRS[i]}"
      end
      cleanname = @filename[0...-4]
      pathexport = "Cache/Shiny/" + originfolder + cleanname + shinyname + ".png"
      if !File.exists?(pathexport)
        self.bitmap_to_png(pathexport)
      end
      # puts "Origin Folder: #{originfolder}"
    end
  end

  def krsapply(channel, condif, idcol, shinyKRS)
    timidblack = shinyKRS[idcol + 6]
    if condif == 1
      channel = channel.map{|v| v >= 127 ? v-127.0: v}#127 -> 0 / 255 -> 127
    elsif condif == 2
      channel = channel.map do |v|#0 -> 127 / 127 -> 255
        # v>16&&v <= 127 ? v+127.0 : v
        if ((timidblack == 1 && v > 16) || (timidblack == 2 && v > 42) || (timidblack == 0)) && v <= 127
          v+127.0
        else
          v
        end
      end
    elsif condif == 3
      channel = channel.map{|v| v >= 127 ? 255.0 - (v - 127.0) : v}#127 -> 255 / 255 -> 127
    elsif condif == 4
      channel = channel.map do |v|#0 -> 127 / 127 -> 0
        # v>16&&v <= 127 ? 127.0 - v : v
        if ((timidblack == 1 && v > 16) || (timidblack == 2 && v > 42) || (timidblack == 0)) && v <= 127
          127.0-v
        else
          v
        end
      end
    end
    return channel
  end


# timidblack = shinyKRS[idcol + 6]
# redincr = shinyKRS[0].to_f
# greenincr = shinyKRS[1].to_f
# blueincr = shinyKRS[2].to_f
# # Advanced (advanced shinies)
# if shiny == 1
#   return greenShiny.clone.map{|value| value+greenincr}
# elsif shiny == 2
#   return blueShiny.clone.map{|value| value+blueincr}
# elsif shiny == 0
#   return redShiny.clone.map{|value| value+redincr}
# elsif shiny == 3
#   return redShiny.clone.zip(greenShiny.clone).map { |r, g| (r+redincr + g+greenincr) / 2 }
# elsif shiny == 4
#   return redShiny.clone.zip(blueShiny.clone).map { |r, b| (r+redincr + b+blueincr) / 2 }
# elsif shiny == 5
#   return greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g+greenincr + b+blueincr) / 2 }
# elsif shiny == 6
#   colordoing = redShiny.clone
#   return colordoing.map do |r|
#     if (timidblack == 1 && r + redincr > 16) || (timidblack == 2 && r + redincr > 42) || (timidblack == 0)
#       255.0 - (r + redincr)
#     else
#       r + redincr
#     end
#   end
# elsif shiny == 7
#   colordoing = greenShiny.clone
#   return colordoing.map do |r|
#     if (timidblack == 1 && r + greenincr > 16) || (timidblack == 2 && r + greenincr > 42) || (timidblack == 0)
#       255.0 - (r + greenincr)
#     else
#       r + greenincr
#     end
#   end
# elsif shiny == 8
#   colordoing = blueShiny.clone
#   return colordoing.map do |r|
#     if (timidblack == 1 && r + blueincr > 16) || (timidblack == 2 && r + blueincr > 42) || (timidblack == 0)
#       255.0 - (r + blueincr)
#     else
#       r + blueincr
#     end
#   end
# elsif shiny == 9
#   colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r+redincr + g+greenincr) / 2 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 10
#   colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r+redincr + b+blueincr) / 2 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 11
#   colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g+greenincr + b+blueincr) / 2 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 12
#   return greenShiny.clone.zip(blueShiny.clone, redShiny.clone).map { |g, b, r| (g+greenincr + b+blueincr + r+redincr) / 3 }
# elsif shiny == 13
#   colordoing = greenShiny.clone.zip(blueShiny.clone, redShiny.clone).map { |g, b, r| (g+greenincr + b+blueincr + r+redincr) / 3 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 14#Citrine
#   return redShiny.clone.zip(greenShiny.clone).map { |r, g| (r+redincr + (g+greenincr)*3) / 4 }
# elsif shiny == 15#Violet
#   return redShiny.clone.zip(blueShiny.clone).map { |r, b| (r+redincr + (b+blueincr)*3) / 4 }
# elsif shiny == 16#Marine
#   return greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g+greenincr + (b+blueincr)*3) / 4 }
# elsif shiny == 17#Orange
#   return greenShiny.clone.zip(redShiny.clone).map { |g, r| (g+greenincr + (r+redincr)*3) / 4 }
# elsif shiny == 18#Pink
#   return blueShiny.clone.zip(redShiny.clone).map { |b, r| (b+blueincr + (r+redincr)*3) / 4 }
# elsif shiny == 19#Jade
#   return blueShiny.clone.zip(greenShiny.clone).map { |b, g| (b+blueincr + (g+greenincr)*3) / 4 }
# elsif shiny == 20#Inverted Citrine
#   colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r+redincr + (g+greenincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 21#Inverted Violet
#   colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r+redincr + (b+blueincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 22#Inverted Marine
#   colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g+greenincr + (b+blueincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 23#Inverted Orange
#   colordoing = greenShiny.clone.zip(redShiny.clone).map { |g, r| (g+greenincr + (r+redincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 24#Inverted Pink
#   colordoing = blueShiny.clone.zip(redShiny.clone).map { |b, r| (b+blueincr + (r+redincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# elsif shiny == 25#Inverted Jade
#   colordoing = blueShiny.clone.zip(greenShiny.clone).map { |b, g| (b+blueincr + (g+greenincr)*3) / 4 }
#   return colordoing.map do |r|
#     if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
#       255.0 - r
#     else
#       r
#     end
#   end
# else
#   return redShiny.clone
# end

  #ChatGPT
  def getChannelGradient(shiny, redShiny, greenShiny, blueShiny, shinyKRS, idcol)
    if $PokemonSystem.shinyadvanced != nil && $PokemonSystem.shinyadvanced == 1
      # Normal (Non-advanced shinies)
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
        return colordoing.map { |r| 255.0 - r }
      elsif shiny == 7
        colordoing = greenShiny.clone
        return colordoing.map { |r| 255.0 - r }
      elsif shiny == 8
        colordoing = blueShiny.clone
        return colordoing.map { |r| 255.0 - r }
      elsif shiny == 9
        colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (r + g) / 2 }
        return colordoing.map { |r| 255.0 - r }
      elsif shiny == 10
        colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (r + b) / 2 }
        return colordoing.map { |r| 255.0 - r }
      elsif shiny == 11
        colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (g + b) / 2 }
        return colordoing.map { |r| 255.0 - r }
      else
        return redShiny.clone
      end
    else
      timidblack = shinyKRS[idcol + 6]
      redincr = shinyKRS[0].to_f
      greenincr = shinyKRS[1].to_f
      blueincr = shinyKRS[2].to_f
      # Advanced (advanced shinies)
      if shiny == 1
        return greenShiny.clone.map { |value| (value + greenincr).clamp(0, 255) }
      elsif shiny == 2
        return blueShiny.clone.map { |value| (value + blueincr).clamp(0, 255) }
      elsif shiny == 0
        return redShiny.clone.map { |value| (value + redincr).clamp(0, 255) }
      elsif shiny == 3
        return redShiny.clone.zip(greenShiny.clone).map { |r, g| (((r + redincr)).clamp(0, 255) + ((g + greenincr)).clamp(0, 255)) / 2 }
      elsif shiny == 4
        return redShiny.clone.zip(blueShiny.clone).map { |r, b| (((r + redincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255)) / 2 }
      elsif shiny == 5
        return greenShiny.clone.zip(blueShiny.clone).map { |g, b| (((g + greenincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255)) / 2 }
      elsif shiny == 6
        colordoing = redShiny.clone.map { |value| (value + redincr).clamp(0, 255) }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 7
        colordoing = greenShiny.clone.map { |value| (value + greenincr).clamp(0, 255) }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 8
        colordoing = blueShiny.clone.map { |value| (value + blueincr).clamp(0, 255) }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 9
        colordoing = redShiny.clone.zip(greenShiny.clone).map { |r, g| (((r + redincr)).clamp(0, 255) + ((g + greenincr)).clamp(0, 255)) / 2 }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 10
        colordoing = redShiny.clone.zip(blueShiny.clone).map { |r, b| (((r + redincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255)) / 2 }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 11
        colordoing = greenShiny.clone.zip(blueShiny.clone).map { |g, b| (((g + greenincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255)) / 2 }
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 12
        return greenShiny.clone.zip(blueShiny.clone, redShiny.clone).map do |g, b, r|
          (((g + greenincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) + ((r + redincr)).clamp(0, 255)) / 3
        end
      elsif shiny == 13
        colordoing = greenShiny.clone.zip(blueShiny.clone, redShiny.clone).map do |g, b, r|
          (((g + greenincr)).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) + ((r + redincr)).clamp(0, 255)) / 3
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 14 # Citrine
        return redShiny.clone.zip(greenShiny.clone).map do |r, g|
          (((r + redincr).clamp(0, 255) + ((g + greenincr)).clamp(0, 255) * 3)) / 4
        end
      elsif shiny == 15 # Violet
        return redShiny.clone.zip(blueShiny.clone).map do |r, b|
          (((r + redincr).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) * 3)) / 4
        end
      elsif shiny == 16 # Marine
        return greenShiny.clone.zip(blueShiny.clone).map do |g, b|
          (((g + greenincr).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) * 3)) / 4
        end
      elsif shiny == 17 # Orange
        return greenShiny.clone.zip(redShiny.clone).map do |g, r|
          (((g + greenincr).clamp(0, 255) + ((r + redincr)).clamp(0, 255) * 3)) / 4
        end
      elsif shiny == 18 # Pink
        return blueShiny.clone.zip(redShiny.clone).map do |b, r|
          (((b + blueincr).clamp(0, 255) + ((r + redincr)).clamp(0, 255) * 3)) / 4
        end
      elsif shiny == 19#Jade
        return blueShiny.clone.zip(greenShiny.clone).map do |b, g|
          (((b+blueincr).clamp(0,255) + ((g+greenincr)).clamp(0,255)*3)) / 4
        end
      elsif shiny == 20#Inverted Citrine
        colordoing = redShiny.clone.zip(greenShiny.clone).map do |r, g|
          (((r + redincr).clamp(0, 255) + ((g + greenincr)).clamp(0, 255) * 3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 21#Inverted Violet
        colordoing = redShiny.clone.zip(blueShiny.clone).map do |r, b|
          (((r + redincr).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) * 3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 22#Inverted Marine
        colordoing = greenShiny.clone.zip(blueShiny.clone).map do |g, b|
          (((g + greenincr).clamp(0, 255) + ((b + blueincr)).clamp(0, 255) * 3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 23#Inverted Orange
        colordoing = greenShiny.clone.zip(redShiny.clone).map do |g, r|
          (((g + greenincr).clamp(0, 255) + ((r + redincr)).clamp(0, 255) * 3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 24#Inverted Pink
        colordoing = blueShiny.clone.zip(redShiny.clone).map do |b, r|
          (((b + blueincr).clamp(0, 255) + ((r + redincr)).clamp(0, 255) * 3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      elsif shiny == 25#Inverted Jade
        colordoing = blueShiny.clone.zip(greenShiny.clone).map do |b, g|
          (((b+blueincr).clamp(0,255) + ((g+greenincr)).clamp(0,255)*3)) / 4
        end
        return colordoing.map do |r|
          if (timidblack == 1 && r > 16) || (timidblack == 2 && r > 42) || (timidblack == 0)
            255.0 - r
          else
            r
          end
        end
      else
        return redShiny.clone
      end
    end

    # Brainstorm
    # ShinyKRS []
    # 0 - Red increment
    # 1 - Green increment
    # 2 - Blue increment
    # 3 - R's Semi-Inverted
    # 4 - G's ~
    # 5 - B's ~
    # 6 - R's TimidBlack
    # 7 - G's ~
    # 8 - B's ~

    # - TimidBlack -
    # In this case, RGB is the output directly, it does not affect the shifting
    # 0 (none, weight of 32)
    # 1 (when inverted, black remains the same, weight of 16)
    # 2 (when inverted, 0...10 remains the same, weight of 4)

    # - Increment -
    # 0 (none, weight of 512)
    # -50 - 50 (normal mutation - weight of 64)
    # -100 - 100 (advanced mutation - weight of 16)
    # -200 - 200 (severe mutation - weight of 4)

    # - Semi-Inverted -
    # 0 (none, weight of 512)
    # 127+ > 0-127 (light darkened, weight of 64)
    # 127- > 127-255 (dark lightened [black ignored!], weight of 64)
    # 127+ > 127-255 (light inverted, weight of 8)
    # 127- > 0-127 (dark inverted [black ignored!], weight of 8)

    # Grey

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
    
    # 12 = Grey
    # 13 = Inverse Grey
    
    # 14 = Citrine (0.5 R | 1.5 G)
    # 15 = Violet (0.5 R | 1.5 B)
    # 16 = Marine (0.5 G | 1.5 B)
    # 17 = Orange (0.5 G | 1.5 R)
    # 18 = Pink (0.5  B| 1.5 R)
    # 19 = Jade (0.5  B| 1.5 G)

    # 20 = Inverted Citrine
    # 21 = Inverted Violet
    # 22 = Inverted Marine
    # 23 = Inverted Orange
    # 24 = Inverted Pink
    # 25 = Inverted Jade
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
    if dontmodify == 0
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

  def bitmap=(bitmap)
    @bitmap.bitmap = bitmap;
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
