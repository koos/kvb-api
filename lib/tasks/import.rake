# encoding: utf-8
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

  desc "Get lines' data"
  task :lines => [:environment] do
    require 'lines'
    [1,3,4,5,7,9,12,13,15,16,18,106,120,121,122,125,126,127,130,131,132,133,135,136,138,139,140,141,142,143,144,145,146,147,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,167,180,181,182,183,185,186,187,188,190].each do |line_number|
      line_stations = Lines.new(line_number).call
      order = 0
      line_connections = []
      line_stations.each_cons(2) do |neigbour_station_hashes|
        neigbour_stations = [
          Station.find_by_kvb_id(neigbour_station_hashes.first[:station_id]),
          Station.find_by_kvb_id(neigbour_station_hashes.second[:station_id])
        ]
        order += 1
        line_connections << LineConnection.create_from_line_order_and_neigbour_stations(line_number, order, neigbour_stations)
      end
      puts "Connections for line #{line_number}:"
      puts line_connections.inspect
      puts "------"
    end
  end

  desc "Get destinations for lines"
  task :destinations => [:environment] do
    require 'arrivals'
    Line.bahn_stations.each do |station|
      begin
        arrivals = Arrivals.new(station.kvb_id).call
        arrivals.each do |arrival|
          unless Station.where(name: arrival[:destination]).any?
            StationAlias.find_or_create_by_name(arrival[:destination])
          end
        end
      rescue Exception => e
        puts "Exception while processing station #{station.kvb_id}: #{e}"
      end
    end
  end

  desc "Create initial mapping between stations and their aliases"
  task :station_alias_mapping => [:environment] do
    Station.associate_aliases_for "Weiden West S-Bahn", ["Weiden West", "WEIDEN WEST"]
    Station.associate_aliases_for "Zollstock Südfriedhof", ["Zollstock", "ZOLLSTOCK"]
    Station.associate_aliases_for "Zündorf", ["ZüNDORF"]
    Station.associate_aliases_for "Reichenspergerplatz", ["REICHENSPERGERPL.", "Reichensp. Pl."]
    Station.associate_aliases_for "Brühl Mitte", ["Brühl", "BRüHL", "Brühl Bonn", "BRüHL BONN"]
    Station.associate_aliases_for "Sülzgürtel", ["SüLZGÜRTEL"]
    Station.associate_aliases_for "Klettenbergpark", ["Klettenberg", "KLETTENBERG"]
    Station.associate_aliases_for "Bonn Bad Godesberg Stadthalle", ["Bad Godesberg", "Bonn Bad Godesberg"]
  end
end
task :all => ["import:stations", "import:lines", "import:destinations"]
