require 'rubygems'
require 'bundler/setup'
require 'dalli'
require 'httparty'
require 'geocoder'
require './user_data.rb'
require './user.rb'
require 'logger'

LOGGER = Logger.new(STDERR)
LOGGER.level = Logger::DEBUG
PULL_INTERVAL = 840


###############################

dalli = Dalli::Client.new
@users = []

def make_request(url, options = {})
  begin
    Timeout.timeout 300 do
      HTTParty.get(url, options)
    end
  rescue Timeout::Error
    nil
  end
end

###############################

sleep 30 # Don't get started yet -- web server needs some time to reboot after deployment

USERS.each_with_index do |user_info, i|

  LOGGER.info "Starting user #{i + 1} (#{user_info[:username]})"

  user = User.new(user_info)

  # Foursquare
  unless user.foursquare.nil?
    options = {:basic_auth => {:username => user.foursquare[:username], :password => user.foursquare[:password]}}
    response = make_request("http://api.foursquare.com/v1/history.json", options)

    if response and response.code < 400 and response["checkins"] and response["checkins"].count > 0
      checkin = response["checkins"][0]
      user.service_name = "foursquare"
      user.service_url = "http://foursquare.com/venue/#{checkin["venue"]["id"]}"
      user.spot = checkin["venue"]["name"]
      user.lat = checkin["venue"]["geolat"]
      user.lng = checkin["venue"]["geolong"]
      user.updated_at = Time.parse(checkin["created"])
    end
  end

   # TODO: Skip other sections if latest is within last 30 min

  # Gowalla
  unless user.gowalla.nil? and ENV["GOWALLA_API_KEY"].nil?
    options = {:headers => {"X-Gowalla-API-Key" => ENV["GOWALLA_API_KEY"], "Accept" => "application/json"}}
    response = make_request("http://api.gowalla.com/users/#{user.gowalla}", options)

    if response and response.code < 400
      last_checkin = response["last_checkins"][0]
      last_checkin_spot = last_checkin["spot"]["url"] rescue nil

      if last_checkin and (user.updated_at.nil? or last_checkin["created_at"] > user.updated_at)
        spot_data = HTTParty.get("http://api.gowalla.com/#{last_checkin_spot}", options)
        user.service_name = "gowalla"
        user.service_url = "http://www.gowalla.com#{last_checkin['url']}"
        user.spot = spot_data["name"]
        user.lat = spot_data["lat"]
        user.lng = spot_data["lng"]
        user.updated_at = last_checkin["created_at"]
      end
    end
  end

  # Twitter
  unless user.twitter.nil?
    response = make_request("http://api.twitter.com/status/user_timeline/#{user.twitter}.json?count=20")

    if response and response.code < 400
      user.avatar_url = response.first["user"]["profile_image_url"] if user.avatar_url.nil?

      response.each do |tweet|
        if tweet['place'] and (user.updated_at.nil? or (Time.parse(tweet["created_at"]) > user.updated_at))
          coordinates = tweet["place"]["bounding_box"]["coordinates"][0]
          user.service_name = "twitter"
          user.service_url = "http://www.twitter.com/#{user.twitter}/statuses/#{tweet['id']}"
          user.spot = nil
          user.lat = (coordinates[1][1] + coordinates[2][1]) / 2
          user.lng = (coordinates[0][0] + coordinates[1][0]) / 2
          user.updated_at = Time.parse(tweet["created_at"])
        end
      end
    end

  end

  # Place name
  begin
    place = Geocoder.search("#{user.lat},#{user.lng}").first
    user.city =  "#{place.city}, #{place.state}"
  rescue
    user.city = nil
  end

  # Replace nil avatars
  user.avatar_url = "http://ext.youversion.com/img/avatars/default.png" if user.avatar_url.nil?

  # Finalize
  user.foursquare = nil
  @users << user if user.valid?

end

dalli.set('users', @users)
LOGGER.info "Cache set. #{@users.size} users."
LOGGER.info "Next data pull in #{PULL_INTERVAL / 60} minutes"
sleep PULL_INTERVAL
