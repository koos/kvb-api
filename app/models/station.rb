class Station < ActiveRecord::Base
  include FlagShihTzu
  acts_as_nested_set

  has_many :station_aliases

  has_many :stops
  has_many :station_connections, foreign_key: 'station_a_id'

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

  # needed by the API
  def amenities_list
    self.class.flag_mapping["features"].keys.map do |flag|
      self.send(flag) ? flag : nil
    end.compact
  end

  def station_connections
    @station_connections ||= (StationConnection.find_all_by_station_a_id(self.id) << StationConnection.find_all_by_station_b_id(self.id)).flatten.uniq
  end

  def lines
    @lines ||= station_connections.map(&:lines).flatten.uniq
  end
end
