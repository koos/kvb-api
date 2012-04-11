class DestinationStation < ActiveRecord::Base

  belongs_to :destination
  belongs_to :station

  validates_presence_of :destination_id, :station_id

end
