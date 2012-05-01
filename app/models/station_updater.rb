class StationUpdater
  def self.run
    #stations = Line.bahn_stations
    stations = Line.cached_routes['1'].collect { |key, value| value[:station] }
    while(true)

      # Update data for all stations
      stations.each do |station|
        begin
          StationUpdater.update_station(station) do |vehicle|
            Rails.logger.info { "--- PUSHED NEW DATASET" }
            Pusher['default'].trigger!('vehicle_update', vehicle.to_hash)
          end
        rescue Interrupt => i
          exit
        rescue Exception => e
          Rails.logger.error { e.to_s }
          Rails.logger.debug { e.backtrace }
        end
      end

      Rails.logger.info { "--- Tracking vehicles on #{Vehicle.vehicles.size} routes" }
      Vehicle.vehicles.each do |key, value|
        Rails.logger.info { "#{key} => #{value.size}" }
      end

    end
  end

  def self.update_station(station)
    vehicles = Vehicle.at_station(station)

    vehicles = vehicles.delete_if do |vehicle|
      regular_travel_time = Line.cached_routes[vehicle.line.number][station.kvb_id][:"travel_time_#{vehicle.direction}"]
      if regular_travel_time
        vehicle.travel_time_to_station > (regular_travel_time + 1)
      else
        false
      end
    end

    vehicles.compact.each do |vehicle|
      Vehicle.vehicles[vehicle.grouping_id] ||= {}
      data = Vehicle.vehicles[vehicle.grouping_id]
      
      match = data.find do |arrival_time, value|
        (arrival_time - vehicle.arrival_time_at_destination).abs < 4.minutes
      end

      # Remove outdated vehicle, but keep its id
      if match
        vehicle.id = match.last.id
        Vehicle.vehicles[vehicle.grouping_id].delete(match.first)
      end

      Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle

      if block_given?
        yield vehicle
      end
    end
  end
end
