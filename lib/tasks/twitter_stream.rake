require 'tweetstream'
require 'mongo'
require 'mongoid'
require 'twitter'
require 'eventmachine'
require 'fiber'

namespace :twitter_stream do
  desc "populate mongodb with tweets"
  task populate_mongo: :environment do
    client = TweetStream.configure do |config|
      config.consumer_key       = "0ypuFcNrfgzTktIAlJPTubLZB"
      config.consumer_secret    = "E3ngwwA5r1k9pVOHnvMxJg52mF0Atn9JEQfhhnmC7W0nLlsMKQ"
      config.oauth_token        = "3255966516-FKtJVfhDoRfTVlTQ7cyZw7aRQTmjmSljdBdyEp8"
      config.oauth_token_secret = "jUEznpURsajMOz1sMzMHTd4s0sleo2zLi5eiZHheHNSpL"
      config.auth_method        = :oauth
    end  

    client = TweetStream::Client.new   

    EM.run do
      puts "running"

      def save_status(status)
        puts "in save"
        fibers = []    
        root = Fiber.current
        fibers << Fiber.new do  

          EM.defer do
            if status.respond_to?(:coordinates)
              coordinates = { type: "Point", coordinates: status.coordinates}
            else
	      coordinates = {type: "Point", coordinates: status.place.bounding_box.coordinates.first.first}
            end

            hashtags = []
	    if status.respond_to?(:hashtags)
              status.hashtags.each do |h|
	        hashtags << h.text
              end
            end
 	 
	    datetime = DateTime.parse("#{status.created_at}")	 
            puts "saving tweet"
	    twt = TweetObj.new(
	      id: status.id,
	      screen_name: status.user.screen_name,
	      text: status.text,
	      coordinates: coordinates,
	      hashtags: hashtags,
	      created_time: datetime
	    )
        
	    twt.save!
        
            if fibers.length > 1
              Fiber.yield 
            end
          end 
        end
        return if fibers.length > 10   
        fibers.last.resume       
      end

      client.filter(:locations => [-180,-90,180,90]) do |status|  
        save_status(status)
      end
    end
  end
end
        
