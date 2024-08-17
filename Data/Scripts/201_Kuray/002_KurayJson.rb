$KURAY_OPTIONSNAME_LOADED = false

def kurayjson_load(filePath)
    # We are going to load a .json file, or any kind of file that contains json data
    # We will then proceed to eval the retrieved data and return it a jsonparse
    if File.exists?(filePath)
        data = File.read(filePath)
        return eval(data)
    end
    return nil
end

def kurayjson_convertversion(data)
    # Convert the version inside the json into an integer that can be used in conditional statements
    parsing_version = '0.0'
    if data.key?('json_version')
        parsing_version = data['json_version']
    elsif data.key?('JSON_VERSION')
        parsing_version = data['JSON_VERSION']
    # elsif data.key?('version')
        # parsing_version = data['version']
    end

    # Parsing version is going to be something like 0.1, 0.2, etc
    # We want to normalize this data
    # 0.1 -> 1, 0.2 -> 2, 0.9 -> 9, 0.12 -> 12, 1.0 -> 100, 1.4 -> 104

    # We have to check if a dot exists in the version string, if there is no dot, we return 0 as result_version
    if !parsing_version.to_s.include?('.')
        return 0
    end

    result_version = (parsing_version.to_s.split('.')[0].to_i * 100)
    result_version += parsing_version.to_s.split('.')[1].to_i
    return result_version
end

def kurayjson_save(filePath, data)
    # The data must be an hash
    # We are going to save a .json file, or any kind of file that contains json data
    # We will then proceed to write the data to the file
    File.open(filePath, "w") do |file|
        file.write(data)
    end
end