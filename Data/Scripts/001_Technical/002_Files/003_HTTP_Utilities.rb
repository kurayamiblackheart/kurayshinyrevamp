#############################
#
# HTTP utility functions
#
#############################
#

def pbPostData(url, postdata, filename=nil, depth=0)
  if url[/^http:\/\/([^\/]+)(.*)$/]
    host = $1
    path = $2
    path = "/" if path.length==0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
    body = postdata.map { |key, value|
      keyString   = key.to_s
      valueString = value.to_s
      keyString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      valueString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      next "#{keyString}=#{valueString}"
    }.join('&')
    ret = HTTPLite.post_body(
      url,
      body,
      "application/x-www-form-urlencoded",
      {
        "Host" => host, # might not be necessary
        "Proxy-Connection" => "Close",
        "Content-Length" => body.bytesize.to_s,
        "Pragma" => "no-cache",
        "User-Agent" => userAgent
      }
    ) rescue ""
    return ret if !ret.is_a?(Hash)
    return "" if ret[:status] != 200
    return ret[:body] if !filename
    File.open(filename, "wb"){|f|f.write(ret[:body])}
    return ""
  end
  return ""
end

def pbDownloadData(url, filename = nil, authorization = nil, depth = 0, &block)
  return nil if !downloadAllowed?()
  echoln "downloading data from #{url}"
  headers = {
    "Proxy-Connection" => "Close",
    "Pragma" => "no-cache",
    "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
  }
  headers["authorization"] = authorization if authorization
  ret = HTTPLite.get(url, headers) rescue ""
  return ret if !ret.is_a?(Hash)
  return "" if ret[:status] != 200
  return ret[:body] if !filename
  File.open(filename, "wb") { |f| f.write(ret[:body]) }
  return ""
end

def pbDownloadToString(url)
  begin
    data = pbDownloadData(url)
    return data if data
    return ""
  rescue
    return ""
  end
end

def pbDownloadToFile(url, file)
  begin
    pbDownloadData(url,file)
  rescue
  end
end

def pbPostToString(url, postdata)
  begin
    data = pbPostData(url, postdata)
    return data
  rescue
    return ""
  end
end

def pbPostToFile(url, postdata, file)
  begin
    pbPostData(url, postdata,file)
  rescue
  end
end

def serialize_value(value)
  if value.is_a?(Hash)
    serialize_json(value)
  elsif value.is_a?(String)
    escaped_value = value.gsub(/\\/, '\\\\\\').gsub(/"/, '\\"').gsub(/\n/, '\\n').gsub(/\r/, '\\r')
    "\"#{escaped_value}\""
  else
    value.to_s
  end
end


def serialize_json(data)
  #echoln data
  # Manually serialize the JSON data into a string
  parts = ["{"]
  data.each_with_index do |(key, value), index|
    parts << "\"#{key}\":#{serialize_value(value)}"
    parts << "," unless index == data.size - 1
  end
  parts << "}"
  return parts.join
end


def downloadAllowed?()
  return $PokemonSystem.download_sprites==0
end

def clean_json_string(str)
  #echoln str
  #return str if $PokemonSystem.on_mobile
  # Remove non-UTF-8 characters and unexpected control characters
  #cleaned_str = str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  cleaned_str = str
  # Remove literal \n, \r, \t, etc.
  cleaned_str = cleaned_str.gsub(/\\n|\\r|\\t/, '')

  # Remove actual newlines and carriage returns
  cleaned_str = cleaned_str.gsub(/[\n\r]/, '')

  # Remove leading and trailing quotes
  cleaned_str = cleaned_str.gsub(/\A"|"\Z/, '')

  # Replace Unicode escape sequences with corresponding characters
  cleaned_str = cleaned_str.gsub(/\\u([\da-fA-F]{4})/) { |match|
    [$1.to_i(16)].pack("U")
  }
  return cleaned_str
end









