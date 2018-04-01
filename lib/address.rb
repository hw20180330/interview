require_relative 'geocoding'

class Address
  attr_accessor :lat, :lng, :full_address, :miles_to_whitehouse

  def geocoded?
    return false if lat.nil? || lng.nil?
    lat.length > 0 && lng.length > 0
  end

  def reverse_geocoded?
    return false if full_address.nil?
    full_address.length > 0
  end

  def geocode_with_full_address(full_address)
    return unless full_address.length > 0
    res = Geocoder.search(full_address)
    if !res.nil?
      latt  = res[0].data["latt"]
      longt = res[0].data["longt"]
      set_lat_and_lng_values(latt, longt)       
    end
  end

  def reverse_geocode(lat, lng)
    return unless lat.class == Float && lng.class == Float
    res = Geocoder.search("#{lat},#{lng}")
    if !res.nil?
      set_full_usa_address(res[0].data) 
      set_lat_and_lng_values(lat, lng)
    end
  end

  def distance_between(coord1, coord2)
    return unless pair_of_coordinates?(coord1) && pair_of_coordinates?(coord2)
    miles = Geocoder::Calculations.distance_between(coord1, coord2)
    @miles_to_whitehouse = miles
  end

  def miles_to(address_obj)
    return unless pair_of_coordinates?(coordinates) && 
                  pair_of_coordinates?(address_obj.coordinates)
    Geocoder::Calculations.distance_between(coordinates, address_obj.coordinates)
  end

  def set_lat_and_lng_values(latt, longt)
    @lat = latt
    @lng = longt
  end

  def set_full_usa_address(data)
    if !data["usa"].nil?
      us_data        = data["usa"]
      street_address = "#{us_data["usstnumber"]} #{us_data["usstaddress"]}"
      city           = "#{us_data["uscity"]}"
      state          = "#{us_data["state"]}"
      zip            = "#{us_data["zip"]}"
      @full_address  = "#{street_address} #{city}, #{state} #{zip}"
    end
  end

  def coordinates
    [lat,lng]
  end

  def pair_of_coordinates?(coord)
    coord.compact.length == 2
  end
end
