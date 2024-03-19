require "sinatra"
require "sinatra/reloader"
require "http"
require "net/http"
require "uri"
require "json"


# app that determines if you get attacked by an elephant

# 1. do you like this rug
# 2. are you at a funeral?
# 3. where are you?

# if user likes the rug they get attacked
# if user doesnt like the rug, is at a funeral, and is near a zoo, they witness an attack
# if the user doesnt like the rug, isnt at a funeral and isnt at a zoo they dont get attacked but should be careful 
# to get user distance from from zoo just use a distance formula with entered location and set location of zoo

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
  erb(:home)
end

get("/elephant") do
  erb(:elephant)

end

get("/elephant_maybe") do
  @rug = params.fetch("rug")
  @funeral = params.fetch("a_funeral")
 

  @user_local = params.fetch("user_local")
  gmaps = ENV.fetch("GMAPS_KEY")
  @local_url = @user_local.gsub(" ","+")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@local_url}&key=#{gmaps}"
  

  raw_gmaps = HTTP.get(gmaps_url)
  parsed_gmaps = JSON.parse(raw_gmaps)
  @results = parsed_gmaps.fetch("results")
  result_hash = @results.at(0)
  geohash = result_hash.fetch("geometry")
  @localhash = geohash.fetch("location")
  @latitude = @localhash.fetch("lat")
  @longitude = @localhash.fetch("lng")

  @lat2 = 87.8368
  @lon2 = 41.8327

  def distance(lat1, lon1, lat2, lon2, unit)
    if (lat1 == lat2) && (lon1 == lon2)
      return 0
    else
      theta = lon1 - lon2
      dist = Math.sin(lat1 * Math::PI / 180) * Math.sin(lat2 * Math::PI / 180) + Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) * Math.cos(theta * Math::PI / 180)
      dist = Math.acos(dist)
      dist = dist * 180 / Math::PI
      miles = dist * 60 * 1.1515
      unit = unit.upcase
  
      if unit == 'K'
        return miles * 1.609344
      elsif unit == 'N'
        return miles * 0.8684
      else
        return miles
      end
    end
  end
  
  @ele_distance = distance(@latitude, @longitude, -87.8368, 41.8327, "M")

  if @rug == "yes"
    @result = "An elephant has succusfully trampled you. RIP."
  elsif @ele_distance <= 9500 && @funeral == "yes" && @rug == "no"
    @result = "You just witnessed someone get trampled by an elephant. RIP."
  elsif @ele_distance >= 9500 && @funeral == "yes" && @rug == "no"
    @result = "You're safe... for now."
  elsif @ele_distance <= 9500 && @funeral == "no" && @rug == "no"
    @result = "You're safe... for now."
  elsif @ele_distance >= 9500 && @funeral == "no" && @rug == "no"
    @result = "You're safe... for now."
  else
    @result = "Please try again. Must answer 'yes', 'no', or enter a location in respective fields."
  end
  erb(:elephant_maybe)
end
