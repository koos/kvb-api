class Line < ActiveRecord::Base

  has_and_belongs_to_many :stations, :destinations

  validates_presence_of :number, :kind
end
