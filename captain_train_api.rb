require 'sinatra'
require 'csv'
require 'json'
require 'pry'


class StationCollection
	CSV_PARAMS = { headers: true, col_sep: ";", encoding: "UTF-8" }
  
	def initialize
		rows = CSV.read('stations.csv', CSV_PARAMS)
		@stations = rows.map { |row| Station.new(row.to_hash) }.select { |s| s.valid? }
	end

  def random
    @stations.sample
  end

  def find_named(name)
    @results = []
    @stations.each { |station| @results.push(station.name) }
    @results.select { |station| station.match(name) }
  end

  def find_country(initials)
    @stations.select { |station| station.country.match(initials) }
  end

  def by_distance(position)
    @stations.map { |station| station.distance(position) }.sort
  end

  def size
    @stations.size
  end

  def all
    @stations
  end
end

class Station
	def initialize(attributes)
		@attributes = attributes
	end

	def name
		@attributes['name']
	end

  def country
    @attributes['country']
  end

	def valid?
		name
	end

	def to_json(options = {})
		@attributes.to_json(options)
	end

  def position
    lat_lon = @attributes.values_at('latitude', 'longitude')
    Position.new(*lat_lon)
  end

  def distance(destination)
    origin = self.position

    rad_per_deg = Math::PI/180
    rkm = 6371

    dlat_rad = (destination.lat - origin.lat) * rad_per_deg
    dlon_rad = (destination.lon - origin.lon) * rad_per_deg

    lat1_rad = origin.lat * rad_per_deg
    lat2_rad = destination.lat * rad_per_deg

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    distance_in_km = rkm * c

    Distance.new(distance_in_km, self)
  end
end

class Position
  attr_accessor :lat, :lon

  def initialize(lat, lon)
    @lat = lat.to_f
    @lon = lon.to_f
  end
end

class Distance
  attr_reader :distance
  
  def initialize(distance, station)
    @distance = distance
    @station = station
  end

  def <=>(other)
    @distance <=> other.distance
  end

  def to_json(options = {})
    { distance: @distance, station: @station }.to_json(options)
  end
end

stations = StationCollection.new

before do
  content_type :json
end

configure :development do
  set :show_exceptions, :after_handler
end

not_found do
  { message: 'Not Found', code: 404 }.to_json
end

error do
  { message: env['sinatra.error'], code: 500 }.to_json
end

get '/' do
	'Welcome to the train API'
end

get '/random' do
	stations.random.to_json
end

get '/find/by_distance' do
  lat_lon = params.values_at('latitude', 'longitude')
  position = Position.new(*lat_lon)
  stations.by_distance(position).take(10).to_json
end

get '/find/country/:initials' do |initials|
  stations.find_country(initials).to_json
end

get '/find/:name' do |name|
  stations.find_named(name).to_json
end