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
        arrivals = Arrivals.new(station.kvb_id).import.all
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
    Station.associate_aliases_for "IKEA Am Butzweilerhof", ["ikea am butzweilerhof", "Ikea am Butzweilerhof", "Am Butzweilerhof", "AM BUTZWEILERHOF", "Ikea Am Butzweilerhof", "IKEA am Butzweilerhof"]    
    Station.associate_aliases_for "Bayerwerk S-Bahn", ["Bayerwerk s-bahn", "Bayerwerk", "Bayerwerk S-bahn", "Bayerwerk S-BAHN"]    
    Station.associate_aliases_for "Bensberg", ["bensberg", "BENSBERG"]    
    Station.associate_aliases_for "Bf Deutz/LANXESS arena", ["Bf Deutz/LANXESS Arena", "Bf Deutz/L.Arena", "Bf Deutz/LANXESS Arena", "Bf Deutz/lanxess Arena", "bf deutz/lanxess Arena", "Deutz"]
    Station.associate_aliases_for "Bocklemünd", ["bocklemünd", "BOCKLEMüND"]
    Station.associate_aliases_for "Breslauer Platz/Hbf", ["Breslauer Platz"]    
    Station.associate_aliases_for "Buchheim Frankfurter Str.", ["BUCHHEIM", "Buchheim"]    
    Station.associate_aliases_for "Chorweiler", ["CHORWEILER", "chorweiler"]    
    Station.associate_aliases_for "Köln/Bonn Flughafen", ["Flughafen", "Flugh. Köln/Bonn"]    
    Station.associate_aliases_for "Frechen-Benzelrath", ["FRECHEN", "Frechen"]    
    Station.associate_aliases_for "Godorf Bf", ["GODORF Bf", "GODORF BF", "Godorf"]    
    Station.associate_aliases_for "Holweide S-Bahn", ["Holweide s-bahn", "Holweide", "HOLWEIDE S-BAHN", "HOLWEIDE"]    
    Station.associate_aliases_for "Hürth-Hermülheim", ["hürth-hermülheim", "HüRTH-HERMüLHEIM"]
    Station.associate_aliases_for "Königsforst", ["königsforst", "KöNIGSFORST"]    
    Station.associate_aliases_for "Longerich Friedhof", ["longerich friedhof", "Longerich"]
    Station.associate_aliases_for "Bf Lövenich", ["LöVENICH", "Lövenich"]    
    Station.associate_aliases_for "LVR-Klinik", ["LVR KLINIK", "LVR Klinik", "LVR-KLINIK"]    
    Station.associate_aliases_for "Merkenich", ["MERKENICH", "merkenich"]    
    Station.associate_aliases_for "Meschenich Kirche", ["Meschenich"]    
    Station.associate_aliases_for "Bf Mülheim", ["Mülheim", "bf mülheim", "BF MüLHEIM"]
    Station.associate_aliases_for "Mülheimer Friedhof", ["Neu.Mülh.Friedh."]    
    Station.associate_aliases_for "Neusser Str./Gürtel", ["Neusser Str./G."]    
    Station.associate_aliases_for "Poller Kirchweg", ["Poll"]    
    Station.associate_aliases_for "Rodenkirchen Bf", ["RODENKIRCHEN BF", "Rodenkirchen", "rodenkirchen bf"]
    Station.associate_aliases_for "Rudolfplatz", ["rudolfplatz", "RUDOLFPLATZ"]    
    Station.associate_aliases_for "Schlebusch", ["schlebusch", "SCHLEBUSCH"]    
    Station.associate_aliases_for "Stammheim S-Bahn", ["Stammheim s-bahn", "stammheim s-bahn", "Stammheim"]    
    Station.associate_aliases_for "Sülz Hermeskeiler Platz", ["SüLZ", "Sülz"]    
    Station.associate_aliases_for "Sürth Bf", ["SüRTH BF", "SüRTH", "Sürth"]    
    Station.associate_aliases_for "Thielenbruch", ["thielenbruch", "THIELENBRUCH"]
    Station.associate_aliases_for "Ubierring", ["ubierring", "UBIERRING"]    
    Station.associate_aliases_for "Wahn S-Bahn", ["wahn s-bahn", "Wahn", "WAHN S-BAHN"]    
  end

  desc "Add station gps data based on stops"
  task :station_coordinates => [:environment] do
    missing_coordinates = {49 => [50.939987,6.97752], 43 => [50.739144,7.073382], 161 => [50.683951,7.158751], 371 => [50.680852,7.158408], 585 => [50.969265,7.054853], 628 => [50.757201,7.001767], 655 => [50.964265,7.156434], 663 => [51.020396,7.044468], 665 => [50.963806,7.161369], 666 => [50.962941,7.149138], 667 => [50.963665,7.142963], 668 => [50.951912,7.104807], 669 => [50.954101,7.116351], 670 => [50.957102,7.130041], 671 => [50.960616,7.136478], 672 => [50.753998,7.008226], 673 => [50.761219,6.989322], 674 => [50.764639,6.969194], 675 => [50.768087,6.950998], 676 => [50.779838,6.933489], 677 => [50.79419,6.921086], 678 => [50.770149,7.042665], 679 => [50.781954,7.031293], 680 => [50.790881,7.022924], 681 => [50.743706,7.016959], 683 => [50.721827,7.114677], 684 => [50.725692,7.111555], 685 => [50.729664,7.108455], 686 => [50.733223,7.103133], 687 => [50.735749,7.096739], 688 => [50.736537,7.081332], 689 => [50.740203,7.069445], 690 => [50.705754,7.132144], 691 => [50.710319,7.127638], 692 => [50.716787,7.120299], 693 => [50.743978,7.055883], 694 => [50.751011,7.046614], 695 => [50.757364,7.046528], 696 => [50.738248,7.057085], 697 => [50.737243,7.0467], 698 => [50.701731,7.13635], 699 => [50.706977,7.137508], 700 => [50.691809,7.148023], 701 => [50.687649,7.153859], 702 => [50.940772,6.813927], 708 => [50.904197,6.797147], 709 => [50.910312,6.800923], 710 => [50.911747,6.805429], 711 => [50.910285,6.815429], 712 => [50.913668,6.823153], 730 => [50.894155,6.903448], 731 => [50.864803,6.897612], 732 => [50.888416,6.897483], 733 => [50.880564,6.894436], 734 => [50.891015,6.894608], 735 => [50.831177,6.899028], 736 => [50.822218,6.898878], 737 => [50.813148,6.90053], 738 => [50.846137,6.901174], 739 => [50.800836,6.914005], 740 => [50.812036,6.999278], 741 => [50.822801,6.979322], 742 => [50.831773,6.970911], 743 => [50.803602,7.010307]}

    Station.all.each do |station|
      if stop = station.stops.where("lat IS NOT NULL AND long IS NOT NULL").first
        station.lat = stop.lat
        station.lng = stop.long
        station.save
      else
        if coordinates = missing_coordinates[station.kvb_id]
          station.lat = coordinates[0]
          station.lng = coordinates[1]
          station.save
        elsif Line.bahn_stations.include?(station)
          puts "#{station.kvb_id} #{station.name}"
        end
      end
    end
  end

  task :all => ["import:stations", "import:lines", "import:travel_times", "import:destinations", "import:station_alias_mapping"]
end

