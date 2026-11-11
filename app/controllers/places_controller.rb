class PlacesController < ApplicationController
  def index
    @places = Place.all
    render({ :template => "places/index" })
  end

  def show
    @place = Place.find_by({ "id" => params["id"] })
    @entries = Entry.where({ "place_id" => @place["id"] })
    render({ :template => "places/show" })
  end

  def new
    render({ :template => "places/new" })
  end

  def create
    place = Place.new
    place["name"] = params["name"]
    place.save
    redirect_to("/places")
  end
end
