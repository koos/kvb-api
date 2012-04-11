class Destination < ActiveRecord::Base

  has_and_belongs_to_many :lines
  belongs_to :station

  validates_presence_of :name, :station_id

end
