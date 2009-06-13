module GMap
  def find_coordinates_by_address(address)
    if address.include?('乡') || address.include?('镇')
      address.gsub!(/乡(.*?)$/) {''}
      address.gsub!(/镇(.*?)$/) {''}
    elsif address.include?('县')
      address.gsub!(/县(.*?)$/) {''} 
    else
      address.gsub!(/市(.*?)$/) {''}
    end
    
    connect_count = 1

    url  = "http://maps.google.com/maps/geo?q=#{CGI.escape(address)}&output=xml"

    while connect_count < 3
      begin
        data = open(url)
        doc  = Hpricot(data)
        code = doc / 'code'

        if code.inner_text == '200'
          coordinates = doc / 'coordinates'
          return coordinates.inner_text.split(',')
        else
          return ['121.475916', '31.224353']
        end
      rescue
        connect_count += 1
        puts "Timeout, Retrying..."
      end
    end

    ['121.475916', '31.224353']
  end
end