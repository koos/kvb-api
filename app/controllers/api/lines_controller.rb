class Api::LinesController < ApplicationController
  include Roar::Rails::ControllerAdditions

  respond_to :json

  def index
    @lines = Line.all.map { |line| line }
    respond_with(@lines)
  end

  def show
    @line = Line.find_by_number(params[:id])
    respond_with(@line, :with_representer => SingleLineRepresenter)
  end

end