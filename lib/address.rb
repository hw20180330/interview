require_relative 'geocoding'

class Address
  attr_accessor :lat, :lng, :full_address

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
    set_lat_and_lng_values(res[0].data) if !res.nil?
  end

  def reverse_geocode(lat, lng)
    return unless lat.class == Float && lng.class == Float
    res = Geocoder.search("#{lat},#{lng}")
    set_full_usa_address(res[0].data) if !res.nil?
  end

  def distance_between(coord1, coord2)
    return unless pair_of_coordinates?(coord1) && pair_of_coordinates?(coord2)
    Geocoder::Calculations.distance_between(coord1, coord2)
  end

  def miles_to(address_obj)
    return unless pair_of_coordinates?(coordinates) && 
                  pair_of_coordinates?(address_obj.coordinates)
    Geocoder::Calculations.distance_between(coordinates, address_obj.coordinates)
  end

  def set_lat_and_lng_values(data)
    @lat = data["latt"]
    @lng = data["longt"]
  end

  def set_full_usa_address(data)
    if !data["usa"].nil?
      us_data        = data["usa"]
      street_address = "#{us_data["usstnumber"]} #{us_data["usstaddress"]}"
      city           = "#{us_data["uscity"]}"
      state          = "#{us_data["state"]}"
      zip            = "#{us_data["zip"]}"
      @full_address = "#{street_address} #{city}, #{state} #{zip}"
    end
  end

  def coordinates
    [lat,lng]
  end

  def pair_of_coordinates?(coord)
    coord.compact.length == 2
  end
end
