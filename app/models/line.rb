class Line < ActiveRecord::Base

  has_many :line_connections, :order => '"line_connections"."order" ASC'
  has_many :station_connections, :through => :line_connections, :order => '"line_connections"."order" ASC'

  validates_presence_of :number, :kind

  before_validation :save_kind

  # FIXME move to station
  def self.bahn_stations
    where(kind: 'bahn').inject([]) { |memo, line| memo << line.stations }.flatten.uniq
  end

  def save_kind
    self.kind = (number.to_i > 100) ? 'bus' : 'bahn'
  end

  def stations
    @station_ids ||= self.station_connections.map(&:station_a) << self.station_connections.last.station_b
  end


  def self.cached_routes
    @cached_routes ||= begin
      data = Line.all.map do |line|
        route = {}
        
        line.station_connections.each do |station_connection|
          station = station_connection.station_b

          if prev_station = route[station_connection.station_a.kvb_id]
            prev_station[:travel_time_up] = station_connection.travel_time
          else
            # Special case for first station on route
            route[station_connection.station_a.kvb_id] = {
              station: station_connection.station_a,
              travel_time_up: station_connection.travel_time,
              travel_time_down: 0
            }
          end
          
          route[station.kvb_id] = { station: station, travel_time_up: 0, travel_time_down: station_connection.travel_time }
        end

        [line.number, route]
      end

      Hash[data]
    end
  end

end
