class DestinationLine < ActiveRecord::Base

  belongs_to :destination
  belongs_to :line

  validates_presence_of :destination_id, :line_id

end
