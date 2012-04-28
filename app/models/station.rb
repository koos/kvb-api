class Station < ActiveRecord::Base
  include FlagShihTzu
  acts_as_nested_set

  has_many :station_aliases

  has_many :stops
  has_many :station_connections_a, class_name: "StationConnection", foreign_key: 'station_a_id'
  has_many :station_connections_b, class_name: "StationConnection", foreign_key: 'station_b_id'

  accepts_nested_attributes_for :stops

  has_flags 1 => :kiosk,
            2 => :restroom,
            3 => :accessibility,
            4 => :elovator,
            5 => :escalator,
            6 => :underground,
            7 => :elevated,
            8 => :ground,
            9 => :ticket_machine,
            10 => :park_and_ride,
            11 => :bike_box,
            12 => :backery,
            13 => :food,
            14 => :police,
            15 => :phone,
            :column => 'features'

  AMENITIES = [:kiosk, :restroom, :accessibility, :elovator, :escalator, :underground, :elevated, :ground, :ticket_machine, :park_and_ride, :bike_box, :backery, :food, :police, :phone]

  validates_presence_of :name

  def self.associate_aliases_for(station_name, aliases)
    station = self.find_by_name(station_name)
    if station
      [aliases].flatten.each do |alias_name|
        station = StationAlias.find_by_name(alias_name)
        station.update_attribute :station_id, station.id if station
      end
    end
  end

  def self.with_name_or_alias(name_or_alias)
    self.joins(:station_aliases).where("'stations'.'name' = :b OR 'station_aliases'.'name' = :b", {b: name_or_alias}).first
  end

  # needed by the API
  def amenities_list
    self.class.flag_mapping["features"].keys.map do |flag|
      self.send(flag) ? flag : nil
    end.compact
  end

  def station_connections
    (station_connections_a + station_connections_b).flatten.uniq
  end

  def lines
    @lines ||= station_connections.map(&:lines).flatten.uniq
  end

  def line_connections(line = nil)
    station_connections.map { |sc|
      if line
        sc.line_connections.select { |lc| lc.line_id == line.id }
      else
        sc.line_connections
      end
    }.flatten.uniq
  end

  # gotcha: returns nil if self and station are on same position
  def direction(line, station)
    my_position    = self.line_connections(line).map    { |lc| lc.order }.min
    other_position = station.line_connections(line).map { |lc| lc.order }.min

    return nil if !my_position || !other_position

    if my_position < other_position
      return :up
    elsif my_position > other_position
      return :down
    end
  end
end
