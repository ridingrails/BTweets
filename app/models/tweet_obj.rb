class TweetObj
  include Mongoid::Document
  store_in collection: "tweets", database: "test"

  field :tweet_id, type: Integer
  field :screen_name, type: String
  field :text, type: String
  field :coordinates, type: Hash
  field :hashtags, type: Array
  field :created_time, type: DateTime

  index({ coordinates: '2dsphere'})
end
