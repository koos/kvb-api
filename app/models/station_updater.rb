class StationUpdater
  
  def self.update_station(station)
    vehicles = Vehicle.at_station(station)

    vehicles = vehicles.delete_if do |vehicle|
      #binding.pry
      regular_travel_time = Line.cached_routes[vehicle.line.number][station.kvb_id][:"travel_time_#{vehicle.direction}"]
      vehicle.travel_time_to_station > (regular_travel_time + 1)
    end

    vehicles.compact.each do |vehicle|
      Vehicle.vehicles[vehicle.grouping_id] ||= {}
      data = Vehicle.vehicles[vehicle.grouping_id]

      match = data.find do |arrival_time, value|
        (arrival_time - vehicle.arrival_time_at_destination).abs < 3.minutes
      end

      if match
        Vehicle.vehicles[vehicle.grouping_id][match.first] = nil
        vehicle.id = match.last.id
        Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle
      else
        Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle
      end
    end
  end

end