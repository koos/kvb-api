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

  context "fetching of stations by name or an aliased name" do
    let(:station) { Station.find_or_create_by_name("A station") }
    let(:aliaz) {   StationAlias.create(name: "alias for station", station_id: station.id) }

    before do
      @alias = aliaz
    end

    it "should find a station based on the name" do
      Station.with_name_or_alias("A station").id.should eql station.id
    end

    it "should find a station based on the alias" do
      Station.with_name_or_alias("A station").id.should eql station.id
    end
  end

  context "estimating of a vehicles direction" do
    before do
      @line = FactoryGirl.create(:line)
      @station1 = FactoryGirl.create(:station_with_aliases)
      @station2 = FactoryGirl.create(:station_with_aliases)
      @station3 = FactoryGirl.create(:station_with_aliases)
      @station4 = FactoryGirl.create(:station_with_aliases)

      @unconnected_station = FactoryGirl.create(:station_with_aliases)

      @lc1 = FactoryGirl.create(:line_connection, line: @line, order: 0)
      @sc1 = FactoryGirl.create(:station_connection, station_a: @station1, station_b: @station2)
      @sc1.line_connections << @lc1

      @lc2 = FactoryGirl.create(:line_connection, line: @line, order: 1)
      @sc2 = FactoryGirl.create(:station_connection, station_a: @station2, station_b: @station3)
      @sc2.line_connections << @lc2

      @lc3 = FactoryGirl.create(:line_connection, line: @line, order: 2)
      @sc3 = FactoryGirl.create(:station_connection, station_a: @station3, station_b: @station4)
      @sc3.line_connections << @lc3
    end

    it "should be possible to get all station connections" do
      uc = FactoryGirl.create(:station_connection, station_a: @station1, station_b: @station3)
      station_connections = @station2.station_connections
      station_connections.count.should eql(2)
      station_connections.map {|sc| sc.id}.to_set.should eql([@sc1.id, @sc2.id].to_set)
    end

    it "should be possible to get all line connections for a station and a given line" do
      FactoryGirl.create(:line_connection)
      uc = FactoryGirl.create(:line_connection, line: FactoryGirl.create(:line), order: 1)
      FactoryGirl.create(:station_connection, station_a: @station2, station_b: @station3).line_connections << uc

      line_connections = @station2.line_connections(@line)
      line_connections.count.should eql(2)
      line_connections.map {|lc| lc.id}.to_set.should eql([@lc1.id, @lc2.id].to_set)
    end

    it "should be possible to get all line connections for a station" do
      FactoryGirl.create(:line_connection)
      uc = FactoryGirl.create(:line_connection, line: FactoryGirl.create(:line), order: 1)
      FactoryGirl.create(:station_connection, station_a: @station2, station_b: @station3).line_connections << uc

      line_connections = @station2.line_connections
      line_connections.count.should eql(3)
      line_connections.map {|lc| lc.id}.should be_include(uc.id)
    end

    it "should return the direction :up if the position of the vehicle is smaller than the position of the destination" do
      @station2.direction(@line, @station4).should eql :up
      @station2.direction(@line, @station3).should eql :up
    end

    it "should return the direction :down if the position of the vehicle is greater than the position of the destination" do
      @station3.direction(@line, @station1).should eql :down
      @station3.direction(@line, @station2).should eql :down
    end

    it "should return nil in other cases" do
      @station3.direction(@line, @station3).should be_nil
      @station3.direction(@line, @unconnected_station).should be_nil
      @unconnected_station.direction(@line, @station3).should be_nil
      @station2.direction(FactoryGirl.create(:line), @station3).should be_nil
    end
  end
end
