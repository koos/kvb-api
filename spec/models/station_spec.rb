require 'spec_helper'

describe Station do

  context "creation of aliases" do
    let(:station) { Station.find_or_create_by_name("A station") }

    it "should not create an alias if the given alias doesn't exists" do
      lambda {
        Station.associate_aliases_for(station.name, "alias for station")
      }.should_not change(StationAlias, :count)
    end

    it "should associate alias if association doesn't exist" do
      a = StationAlias.find_or_create_by_name("alias for station")
      Station.associate_aliases_for(station.name, "alias for station")
      a.reload
      a.station_id.should eql station.id
    end
  end

end
