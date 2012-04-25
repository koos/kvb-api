class Station < ActiveRecord::Base

  include FlagShihTzu
  acts_as_nested_set

  has_and_belongs_to_many :lines
  has_many :destinations

  has_many :stops

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

  # needed by the API
  def amenities_list
    self.class.flag_mapping["features"].keys.map do |flag|
      self.send(flag) ? flag : nil
    end.compact
  end

end

