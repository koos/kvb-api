require 'arrivals'

class Vehicle

  cattr_accessor :vehicles

  @@vehicles = {}

  attr_accessor :line, :destination, :direction, :position, :speed, :travel_time_to_station

  def self.at_station(station)
    arrivals = Arrivals.new(station.kvb_id).import.trains

    arrivals.map do |arrival|
      if line = Line.find_by_number(arrival[:line])
        if destination = Station.with_name_or_alias(arrival[:destination])
          direction = station.direction(line, destination) # :up, :down, nil
          if direction
            Vehicle.new(line, direction, destination, station, arrival[:arrival])
          else
            Rails.logger.debug { "Couldn't get direction #{station.kvb_id}, #{arrival.inspect}" }
            nil
          end
        end
      else
        Rails.logger.debug { "Could not find #{arrival.inspect}" }
        nil
      end
    end.compact
  end

  def kind
    line.kind
  end

  def initialize(line, direction, destination, station, travel_time_to_station)
    self.line = line
    self.direction = direction
    self.destination = destination

    @station = station
    @travel_time_to_station = travel_time_to_station
  end

  def id
    @id ||= begin
      timestamp = arrival_time_at_destination.to_s(:db).gsub(/:/, '-').gsub(/ /, '-')
      "#{self.line.number}-#{self.direction}-#{self.destination.kvb_id}-#{timestamp}"
    end
  end

  def id=(value)
    @id = value
  end

  def grouping_id
    @id ||= begin
      "#{self.line.number}-#{self.direction}-#{self.destination.kvb_id}"
    end
  end

  def position

    # Get previous position depending on direction
    previous_station = if self.direction == :up
      @station.upper_station(self.line)
    else
      @station.lower_station(self.line)
    end

    distance = RVincenty.distance(@station.coordinates, previous_station.coordinates)
    connection = StationConnection.find_by_stations(@station, previous_station)
    percentage_traveled = (connection.travel_time - travel_time_to_station).to_f / connection.travel_time

    # Calculating new position
    longitude = previous_station.lng * (1 - percentage_traveled) + @station.lng * percentage_traveled
    latitude = previous_station.lat * (1 - percentage_traveled) + @station.lat * percentage_traveled

    [latitude, longitude]
  rescue => ex
    Rails.logger.error { "--- Error while calculating position: #{ex.to_s}" }
    nil
  end

  def arrival_time_at_destination
    @arrival_time_at_destination ||= begin
      route = Line.cached_routes[line.number]

      if self.direction == :up
        state = :delete
        remaining_route = route.delete_if do |station_kvb_id, data|
          if state == :delete and station_kvb_id == @station.kvb_id
            state = :keep
          end

          if state == :keep
            if station_kvb_id == destination.kvb_id
              state == :delete
            end
          end

          state == :delete
        end
      else
        state = :delete
        remaining_route = route.delete_if do |station_kvb_id, data|
          if state == :delete and station_kvb_id == destination.kvb_id
            state = :keep
          end

          if state == :keep
            if station_kvb_id == @station.kvb_id
              state == :delete
            end
          end

          state == :delete
        end
      end

      travel_tile_to_destination = remaining_route.reduce(@travel_time_to_station) { |memo, row| memo += row.last[:travel_time_up] }
      travel_tile_to_destination.minutes.from_now
    end
  end

  def to_hash
    {
      line: self.line.number,
      id: self.id,
      grouping_id: self.grouping_id,
      kind: self.kind,
      position: self.position,
      destination: self.destination,
      direction: self.direction,
      speed: self.speed,
      arrival_time_at_destination: self.arrival_time_at_destination,
      travel_time_to_station: @travel_time_to_station
    }
  end

end
