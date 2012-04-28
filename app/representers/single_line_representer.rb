module SingleLineRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :number
  property :kind
  
  link :self do
    api_line_url(self)
  end

  collection :route, :class => StationConnection, :extend => StationConnectionRepresenter

  alias_attribute :route, :station_connections

end