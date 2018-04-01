RSpec.describe Address do
  let(:full_address) { '1600 Pennsylvania Avenue NW Washington, D.C. 20500 U.S.' }
  let(:lat) { 40.181306 }
  let(:lng) { -80.265949 }
  let(:empty_address) { '' }
  let(:bad_coord) { 'abc' }

  subject(:address) { described_class.new }

  describe 'geocoding' do
    let(:payload) {{  'longt' => lng, 'latt' => lat }}
    let(:result) { [ double(data: payload) ] }

    it 'geocodes with Geocoder API' do
      expect(Geocoder).to receive(:search).with(full_address).and_return result
      address.geocode_with_full_address(full_address)
    end
    
    it 'is geocoded' do
      address.geocode_with_full_address(full_address)
      expect(address).to be_geocoded
    end
  end

  describe 'reverse geocoding' do
    let :payload do
      {   
        'usa'=> {
          'uscity' => 'WASHINGTON',
          'usstnumber' => '1',
          'state' => 'PA',
          'zip' => '20500',
          'usstaddress' => 'Pennsylvania AVE'
        }
      }
    end
    
    let(:result) { [ double(data: payload) ] }

    it 'reverse geocodes with Geocoder API' do
      expect(Geocoder).to receive(:search).with("#{lat},#{lng}").and_return result
      address.reverse_geocode(lat, lng)
    end
    
    it 'is reverse geocoded' do
      address.reverse_geocode(lat, lng)
      expect(address).to be_reverse_geocoded
    end

    describe 'set_full_usa_address' do 
      it 'sets full_address on address obj' do
        address.set_full_usa_address(payload)
        expect(address.full_address).to eq('1 Pennsylvania AVE WASHINGTON, PA 20500')
      end
    end    
  end

  describe 'Geocoder::Calculations' do
    let(:detroit) { FactoryGirl.build :address, :as_detroit }
    let(:kansas_city) { FactoryGirl.build :address, :as_kansas_city }

    describe 'distance finding' do
      it 'calculates distance with the Geocoder API' do
        expect(Geocoder::Calculations).to receive(:distance_between).with detroit.coordinates, kansas_city.coordinates
        address.distance_between(detroit.coordinates, kansas_city.coordinates)
      end

      it 'returns the distance between two addresses' do
        expect(detroit.miles_to(kansas_city)).to be > 0
      end
    end

    describe 'distance_between' do
      it 'does not call Geocoder API without coordinates' do
        expect(Geocoder::Calculations).not_to receive(:distance_between)
        address.distance_between([],[])
      end
  
      it 'calls Geocoder when given coordinates' do
        expect(Geocoder::Calculations).to receive(:distance_between)
        address.distance_between(detroit.coordinates, kansas_city.coordinates)      
      end
    end
    
    describe 'miles_to' do
      it 'does not call Geocoder API without coordinates present' do
        expect(Geocoder::Calculations).not_to receive(:distance_between)
        address.miles_to(Address.new)
      end
      
      it 'calls Geocoder API when given all coordinates' do
        expect(Geocoder::Calculations).not_to receive(:distance_between)
        address.miles_to(kansas_city)
      end
    end    
  end

  describe 'geocoded?' do
    it 'is false when there is no lat or lng' do
      address.geocode_with_full_address(empty_address)
      expect(address.geocoded?).to be false
    end
    
    it 'is true when there is both lat and lng' do
      address.geocode_with_full_address(full_address)
      expect(address.geocoded?).to be true
    end
  end

  describe 'reverse_geocoded?' do
    it 'is false when there is no full address' do
      address.reverse_geocode(bad_coord, bad_coord)
      expect(address.reverse_geocoded?).to be false      
    end

    it 'is true when there is a full address' do
      address.reverse_geocode(lat, lng)
      expect(address.reverse_geocoded?).to be true    
    end
  end
  
  describe 'geocode_with_full_address' do
    it 'does not call set_lat_and_lng_values if there are no Geocoder results' do
      expect(address).not_to receive(:set_lat_and_lng_values)
      address.geocode_with_full_address(empty_address)
    end
    
    it 'calls set_lat_and_lng_values if there are Geocoder results' do
      expect(address).to receive(:set_lat_and_lng_values)
      address.geocode_with_full_address(full_address)
    end

    it 'does not call Geocoder API with empty address' do
      expect(Geocoder).not_to receive(:search)
      address.geocode_with_full_address(empty_address)
    end

    it 'calls Geocoder API with an address present' do
      expect(Geocoder).to receive(:search)
      address.geocode_with_full_address(full_address)
    end
  end

  describe 'reverse_geocode' do
    it 'does not call Geocoder API with bad coordinates' do
      expect(Geocoder).not_to receive(:search)
      address.reverse_geocode(bad_coord, bad_coord)
    end

    it 'calls Geocoder API when given good coordinates' do
      expect(Geocoder).to receive(:search)
      address.reverse_geocode(lat, lng)      
    end
  end

  describe 'set_lat_and_lng_values' do
    it 'sets lat and lng values on address obj' do
      address.set_lat_and_lng_values(lat, lng)
      expect(address.lat).to eq(lat)
      expect(address.lng).to eq(lng)
    end
  end

  describe 'coordinates' do
    it 'returns the array of address lat and lng' do
      address2 = Address.new
      address2.lat = lat
      address2.lng = lng
      expect(address2.coordinates).to eq([lat, lng])
    end
  end
end
