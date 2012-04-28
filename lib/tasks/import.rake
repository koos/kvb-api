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
    [1,3,4,5,7,9,12,13,15,16,18].each do |line_number|
      Line.create(id: line_number, number: line_number, kind: 'bahn')
    end
  end

  desc "Import travel time between stations"
  task :travel_times => [:environment] do
    Line.all.each do |line|
      file_path = Rails.root.join('data', 'lines', "#{line.number}.txt")
      if File.exist?(file_path)
        File.open(file_path) do |file|
          puts "Importing data for line #{line.number}"
          # Get all rows from the file
          station_names = file.read.split("\n")

          # The first line contains the travel times
          raw_times = station_names.shift.gsub(' ', '')
          
          # Split the string into travel times
          travel_times = []
          begin
            raw_times.sub!(/(\d{2})/, '')
            travel_times << $1.to_i
          end while raw_times.length > 0

          # Get station records by 
          stations = station_names.map { |name| Station.find_by_name(name) }.compact

          if stations.size != station_names.size
            not_found = (station_names - stations.collect { |s| s.name })
            raise "Some stations could not be found: #{not_found.join(' ')}"
          end

          traveled = 0
          sort_order = 0
          stations.each_with_index do |station, i|
            if i > 0
              # Calculate travel time from last station
              previous_station = stations[i - 1]
              time_to_next_station = travel_times.shift.to_i - traveled.to_i
              traveled += time_to_next_station

              # Update or create status connection
              conn = StationConnection.find_by_stations(station, previous_station)
              conn ||= StationConnection.new(station_a_id: previous_station.id, station_b_id: station.id)
              conn.travel_time = time_to_next_station
              conn.save

              # Update or add line connection
              line_connection = conn.line_connections.where(line_id: line.id).first
              line_connection ||= conn.line_connections.build(line_id: line.id)
              line_connection.order = sort_order
              line_connection.save
              sort_order += 1
            end
          end
        end
      end
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
end
<<<<<<< HEAD
task :all => ["import:stations", "import:lines", "import:destinations"]
=======
task :all => ["import:stations", "import:lines", "import:travel_times"]
>>>>>>> Add task for importing travel time between stations. It also fixes all station and line connections.
