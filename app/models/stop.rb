class Stop < ActiveRecord::Base

  self.inheritance_column = nil

  belongs_to :station

  attr_accessible :type, :lat, :long

end
