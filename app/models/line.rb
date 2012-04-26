class Line < ActiveRecord::Base

  has_many :line_connections, :order => '"line_connections"."order" ASC'
  has_many :station_connections, :through => :line_connections, :order => '"line_connections"."order" ASC'

  validates_presence_of :number, :kind

  before_validation :save_kind

  def save_kind
    self.kind = (number.to_i > 18) ? 'bus' : 'bahn'
  end

  def stations
    @station_ids ||= self.station_connections.map(&:station_a) << self.station_connections.last.station_b
  end
end
