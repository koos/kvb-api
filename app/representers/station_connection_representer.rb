module StationConnectionRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  
  property :id
  property :from, :extend => StationRepresenter
  property :to, :extend => StationRepresenter
  property :travel_time

  alias_attribute :from, :station_a
  alias_attribute :to, :station_b


end