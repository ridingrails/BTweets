class TweetObjsController < ApplicationController
  KM = 1000 
  def show_tweets
    @tweet_objs = TweetObj.all.to_a.sort! { |a,b| b.created_time <=> a.created_time }
    @tweet_objs = Kaminari.paginate_array(@tweet_objs).page(params[:page]).per(10)

    if request.post?
      long = params[:coordlong].to_f
      lat = params[:coordlat].to_f
      radius = params[:radius].to_f * KM
      coord = {type: "Point", coordinates: [long, lat]}
      @tweet_objs = TweetObj.geo_near(coord).spherical.max_distance(radius).to_a 
      @tweet_objs = Kaminari.paginate_array(@tweet_objs).page(params[:page]).per(10) 

      @hash = Gmaps4rails.build_markers(@tweet_objs) do |tweet_obj, marker|
        marker.lat  tweet_obj.coordinates["coordinates"][1]
        marker.lng  tweet_obj.coordinates["coordinates"][0]
      end

      respond_to do |format|
        format.html 
   	format.js
      end 
    else 
      respond_to do |format|
        format.html  
   	format.js 
      end 
    end 
  end

  def create
    TweetObj.create(tweet_obj_params)
  end

  private

  def tweet_obj_params
    params.require(:tweet_obj).permit(:tweet_id, :screen_name, :text, :coordinates, :geo_coord, :hashtags, :created_time)
  end

end
