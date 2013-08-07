require 'nokogiri'
require 'addressable/uri'
require 'json'
require 'net/http'
require 'rest-client'
require 'htmlentities'

# //maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
# COMMENTS!!!!!!!!!

# App Academy = 37.76 N, 122.4 W

test_key = "AIzaSyB_oydJRd192f1gnAaw-qPHEduEb9Uhnb4"

geocode = Addressable::URI.new(
  :scheme => "http",
  :host => "maps.googleapis.com",
  :path => "maps/api/geocode/json",
  :query_values => {
    :address => "1061+Market+Street,+San+Francisco,+CA",
    :sensor => "false"
  }
).to_s

#geo_result = JSON.parse(Net::HTTP.get(URI(geocode)))
geo_result = JSON.parse(RestClient.get(geocode))
geo_result = geo_result["results"].first["geometry"]["location"]
lat = geo_result["lat"]
lng = geo_result["lng"]

address = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/place/nearbysearch/json",
  :query_values => {
    :key => test_key,
    :location => "#{lat},#{lng}",
    :radius => "1000",
    :sensor => "false",
    :keyword => "ice cream"
  }
).to_s
puts "address str = " + address

# This code allows us to access https:// via Net::HTTP
# Which the Net::HTTP method for the geo_result will not do
# this_uri = URI(address)
# http = Net::HTTP.new(this_uri.host, this_uri.port)
# http.use_ssl = true
# request = Net::HTTP::Get.new(this_uri.request_uri)
# response = http.request(request)
# puts response.body

nearby = JSON.parse(RestClient.get(address))
puts "count = #{nearby["results"].count}"
nearby["results"].each do |result|
  puts "===================================================="
  puts "#{result["name"]} -- #{result["geometry"]["location"]}"
end

dest_lat = nearby["results"].first["geometry"]["location"]["lat"]
dest_lng = nearby["results"].first["geometry"]["location"]["lng"]

directions = Addressable::URI.new(
  :scheme => "http",
  :host => "maps.googleapis.com",
  :path => "maps/api/directions/xml",
  :query_values => {
    :origin => "#{lat},#{lng}",
    :destination => "#{dest_lat},#{dest_lng}",
    :sensor => "false",
    :mode => "walking"
  }
).to_s

noko = Nokogiri::HTML(RestClient.get(directions))
noko = HTMLEntities.new.decode(noko.xpath("//html_instructions"))
noko = noko.to_s
noko.split("</html_instructions><html_instructions>").each do |substr|
  puts Nokogiri::HTML(substr).text
end
#puts Nokogiri::HTML(noko).text
#noko.find("<html_instructions>(.)</html_instructions>")

#http://maps.googleapis.com/maps/api/geocode/json?address=1061+Market+Street,+San+Francisco,+CA&sensor=false