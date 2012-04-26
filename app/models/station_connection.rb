class StationConnection < ActiveRecord::Base

  has_many :lines, :through => :line_connections, :order => '"lines"."number" ASC'
  has_many :line_connections
  belongs_to :station_a, :class_name => 'Station'
  belongs_to :station_b, :class_name => 'Station'

  before_create :calculate_distance

  def calculate_distance
    lon1 = self.station_a.stops.average(:long).to_f
    lat1 = self.station_a.stops.average(:lat).to_f

    lon2 = self.station_b.stops.average(:long).to_f
    lat2 = self.station_b.stops.average(:lat).to_f
    self.distance = GeoDistance::Haversine.geo_distance(lon1, lat1, lon2, lat2).meters if lon1 && lat1 && lon2 && lat2
  end

  def self.find_or_create_connection_with_stations(station_a, station_b)
    self.find_by_stations(station_a, station_b) || self.create(:station_a => station_a, :station_b => station_b)
  end

  def self.find_by_stations(station_a, station_b)
    self.find_by_station_a_id_and_station_b_id(station_a, station_b) || self.find_by_station_a_id_and_station_b_id(station_b, station_a)
  end
end
