class StationsController < ApplicationController

  def show
    @station = Station.find_by_station_identifier(params[:id])
  end

end
