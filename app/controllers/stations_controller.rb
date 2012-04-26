class StationsController < ApplicationController

  def index
    respond_to { |format|
      format.json { render :json => Station.all }
    }
  end

  def show
    @station = Station.find_by_station_identifier(params[:id])
  end

end
