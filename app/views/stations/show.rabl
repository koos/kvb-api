object @station
attributes :id, :name, :description, :lat, :lng, :station_identifier, :amenities_list
child :children do
  attribute :id, :name, :description, :lat, :lng, :station_identifier, :amenities_list
  # child :comments do
    # please render here my comments
  # end
end