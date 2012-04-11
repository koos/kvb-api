class Line < ActiveRecord::Base

  has_and_belongs_to_many :stations
  has_and_belongs_to_many :destinations

  validates_presence_of :number, :kind
end
