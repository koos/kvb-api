class StationUpdater
  def self.run
    #stations = Line.bahn_stations
    stations = Line.cached_routes['1'].collect { |key, value| value[:station] }
    while(true)

      stations.each do |station|
        begin
          StationUpdater.update_station(station) do |vehicle|
            Rails.logger.info { "--- Line: #{vehicle.line.number}" }
            if vehicle.line.number == '1'
              Rails.logger.info { "--- PUSHED NEW DATASET" }
              Pusher['default'].trigger!('vehicle_update', vehicle.to_hash)
            end
          end
        rescue Interrupt => i
          exit
        rescue Exception => e
          Rails.logger.error { e.to_s }
          Rails.logger.debugger { e.backtrace }
        end
      end

      Rails.logger.info { "--- size: #{Vehicle.vehicles.size}" }
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
        (arrival_time - vehicle.arrival_time_at_destination).abs < 5.minutes
      end

      if match
        Vehicle.vehicles[vehicle.grouping_id][match.first] = nil
        vehicle.id = match.last.id
        Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle
      else
        Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle
      end

      if block_given?
        yield vehicle
      end
    end
  end
end
