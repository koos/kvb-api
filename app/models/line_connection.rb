class LineConnection < ActiveRecord::Base

  belongs_to :line
  belongs_to :station_connection

  def self.create_from_line_order_and_neigbour_stations(line_number, order, neigbour_stations)
    self.find_by_line_number_and_neighbour_stations(line_number, neigbour_stations) || self.create(
      :station_connection => StationConnection.find_or_create_connection_with_stations(*neigbour_stations),
      :line => Line.find_or_create_by_number(line_number),
      :order => order
    )
  end


  def self.find_by_line_number_and_neighbour_stations(line_number, neigbour_stations)
    self.joins(:station_connection, :line).where(['lines.number = :line_number AND ((station_connections.station_a_id = :station_a_id AND station_connections.station_b_id = :station_b_id) OR (station_connections.station_a_id = :station_b_id AND station_connections.station_b_id = :station_a_id))', :line_number => line_number, :station_a_id => neigbour_stations.first.id, :station_b_id => neigbour_stations.last.id]).first
  end
end
