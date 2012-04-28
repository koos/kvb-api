class StationsController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  def index
    @stations = Station.all
    respond_with(@stations)
  end

  def show
    @station = Station.find(params[:id])
    respond_with(@station, :with_representer => SingleStationRepresenter)
  end

end
