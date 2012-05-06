# This class is intended for continuously scraping the kvb website. It fetches 
# the most recent arrival data for stations in the kvb network and stores them 
# in memory.
#
# Due to the amount of stations, it might be interesting to run multiple workers 
# each handling a different set of stations. Right now, there are only two 
# options:
# 
# * Fetch all stations with StationUpdate.new.run
# * Fetch stations for specific lines with StationUpdate.new(:lines => YOUR_LINES).run
#
# Feel free to add more options ;)
#
class StationUpdater

  FUZZYNESS = 4.minutes

  def initialize(opts)
    if lines = opts.delete(:lines)
      self.stations = self.stations_for_line(lines)
    end
  end

  def stations_for_line(lines)
    # Fetch stations for lines
    data = lines.collect do |line|
      if line_stations = Line.cached_routes[line.to_s]
        line_stations.map { |k,v| v[:station] }
      end
    end

    # Create a flat array with unique and non-nil stations
    data.flatten.uniq.compact
  end

  def stations=(data)
    @stations = data
  end

  def stations
    # By default, we fetch data for all tram stations
    @stations ||= Line.bahn_stations
  end

  # Start run time loop which continuously updates station data
  def run
    while(true)
      self.stations.each do |station|
        begin
          StationUpdater.update_station(station) do |vehicle|
            Rails.logger.debug { "--- PUSHED NEW DATASET" }
            Pusher['default'].trigger!('vehicle_update', vehicle.to_hash)
          end
        rescue Interrupt => i
          exit
        rescue Exception => e
          Rails.logger.error { e.to_s }
          Rails.logger.debug { e.backtrace }
        end
      end

      if Rails.logger.debug?
       Rails.logger.debug { "--- Tracking vehicles on #{Vehicle.vehicles.size} routes" }
        Vehicle.vehicles.each do |key, value|
          Rails.logger.debug { "#{key} => #{value.size}" }
        end
      end

    end
  end

  def self.update_station(station)
    vehicles = Vehicle.at_station(station)

    # Only process those vehicles which already left last station and are on 
    # route to current station
    vehicles = vehicles.delete_if do |vehicle|
      regular_travel_time = Line.cached_routes[vehicle.line.number][station.kvb_id][:"travel_time_#{vehicle.direction}"]
      regular_travel_time && (vehicle.travel_time_to_station > (regular_travel_time))
    end

    vehicles.compact.each do |vehicle|
      Vehicle.vehicles[vehicle.grouping_id] ||= {}
      data = Vehicle.vehicles[vehicle.grouping_id]
      
      match = data.find do |arrival_time, value|
        (arrival_time - vehicle.arrival_time_at_destination).abs < FUZZYNESS
      end

      if match # Remove outdated vehicle, but keep its id
        vehicle.id = match.last.id
        Vehicle.vehicles[vehicle.grouping_id].delete(match.first)
      end

      Vehicle.vehicles[vehicle.grouping_id][vehicle.arrival_time_at_destination] = vehicle
      
      yield vehicle if block_given?
    end
  end
end
