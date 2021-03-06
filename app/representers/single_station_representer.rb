module SingleStationRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  
  property :id
  property :name
  property :description
  property :latitude
  property :longitude
  property :kvb_id
  property :amenities_list

  alias_attribute :latitude, :lat
  alias_attribute :longitude, :lng

  #AMENITIES

  link :self do
    api_station_url(self)
  end

end
