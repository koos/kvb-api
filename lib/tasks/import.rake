# https://raw.github.com/bitboxer/kvb_geo/master/kvb_stops.json
namespace :import do
  desc "Get station data"
  task :stations => [:environment] do
    mappings = {"kvb-id" => "kvb_id", "points" => "stops_attributes", "station" => "name"}

    require 'open-uri'
    stations = JSON.parse(open('https://raw.github.com/bitboxer/kvb_geo/master/kvb_stops.json').read)
    Station.create( stations.map do |station|
      Hash[station.map {|k, v| [(mappings[k] || k), v] }]
    end)

  end
end
