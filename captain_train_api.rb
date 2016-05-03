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

  def random_min
    @results = @stations.each { |station| station.assign_attributes }
    @results.sample
  end

  def random
    @stations.sample
  end

  def find_id(id)
    @stations.select { |station| station.id == (id) }
  end

  def find_named_min(name)
    @results = @stations.select { |station| station.name.match(name) }
    @stations_minimised = []
    @results.each { |station| @stations_minimised.push(station.assign_attributes) }
  end

  def find_named(name)
    @stations.select { |station| station.name.match(name) }
  end

  def find_country_min(initials)
    @results = @stations.select { |station| station.country.match(initials) }
    @stations_minimised = []
    @results.each { |station| @stations_minimised.push(station.assign_attributes) }
  end

  def find_country(initials)
    @stations.select { |station| station.country.match(initials) }
  end

  def by_distance_min(position)
    @results = @stations.each { |station| station.assign_attributes }
    @results.map { |station| station.distance(position) }.sort
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

class StationMinimised
  attr_accessor :name, :longitude, :latitude, :parent_station_id, :country, :is_main_station, :is_city, :time_zone
  def initialize(name, longitude, latitude, parent_station_id, country, is_main_station, is_city, time_zone)
    @name = name
    @longitude = longitude
    @latitude = latitude
    @parent_station_id = parent_station_id
    @country = country
    @is_main_station = is_main_station
    @is_city = is_city
    @time_zone = time_zone
  end
end

class Station
  attr_reader :attributes
	def initialize(attributes)
		@attributes = attributes
	end

	def name
		@attributes['name']
	end

  def country
    @attributes['country']
  end

  def latitude
    @attributes['latitude']
  end

  def longitude
    @attributes['longitude']
  end

  def slug
    @attributes['slug']
  end

  def id
    @attributes['id']
  end

  def uic
    @attributes['uic']
  end

  def uic8_sncf
    @attributes['uic8_sncf']
  end

  def parent_station_id
    @attributes['parent_station_id']
  end

  def is_city
    @attributes['is_city']
  end

  def is_main_station
    @attributes['is_main_station']
  end

  def time_zone
    @attributes['time_zone']
  end

  def is_suggestable
    @attributes['is_suggestable']
  end

  def sncf_id
    @attributes['sncf_id']
  end

  def sncf_tvs_id
    @attributes['sncf_tvs_id']
  end

  def sncf_is_enabled
    @attributes['sncf_is_enabled']
  end

  def idtgv_id
    @attributes['idtgv_id']
  end

  def idtgv_is_enabled
    @attributes['idtgv_is_enabled']
  end

  def db_id
    @attributes['db_id']
  end

  def db_is_enabled
    @attributes['db_is_enabled']
  end

  def idbus_id
    @attributes['idbus_id']
  end

  def idbus_is_enabled
    @attributes['idbus_is_enabled']
  end

  def ouigo_id
    @attributes['ouigo_id']
  end

  def ouigo_is_enabled
    @attributes['ouigo_is_enabled']
  end

  def trenitalia_id
    @attributes['trenitalia_id']
  end

  def trenitalia_is_enabled
    @attributes['trenitalia_is_enabled']
  end

  def ntv_id
    @attributes['ntv_id']
  end

  def ntv_is_enabled
    @attributes['ntv_is_enabled']
  end

  def hkx_id
    @attributes['hkx_id']
  end

  def hkx_is_enabled
    @attributes['hkx_is_enabled']
  end

  def sncf_self_service_machine
    @attributes['sncf_self_service_machine']
  end

  def same_as
    @attributes['same_as']
  end

  def info_de
    @attributes['info:de']
  end

  def info_en
    @attributes['info:en']
  end

  def info_es
    @attributes['info:es']
  end

  def info_fr
    @attributes['info:fr']
  end

  def info_it
    @attributes['info:it']
  end

  def info_nl
    @attributes['info:nl']
  end

  def info_cs
    @attributes['info:cs']
  end

  def info_da
    @attributes['info:da']
  end

  def info_hu
    @attributes['info:hu']
  end

  def info_ja
    @attributes['info:ja']
  end

  def info_ko
    @attributes['info:ko']
  end

  def info_pl
    @attributes['info:pl']
  end

  def info_pt
    @attributes['info:pt']
  end

  def info_ru
    @attributes['info:ru']
  end

  def info_sv
    @attributes['info:sv']
  end

  def info_tr
    @attributes['info:tr']
  end

  def info_zh
    @attributes['info:zh']
  end

	def valid?
		name
	end

	def to_json(options = {})
		@attributes.to_json(options)
	end

  def assign_attributes
    keepers = ["name", "longitude", "latitude", "parent_station_id", "country", "is_main_station", "is_city", "time_zone"]
    info = @attributes.keep_if { |key,_| keepers.include? key }
    StationMinimised.new(*info)
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
  attr_reader :distance, :station, :longitude, :latitude, :id, :slug, :country
  
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
  headers["X-Usage"] = "7"
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
	'Welcome to the awesome train API'
end

get '/v3' do
  stations.random.to_json
end

get '/random/min.json' do
  stations.random_min.to_json
end

get '/find_by_id/:id' do |id|
  stations.find_id(id).to_json
end

get '/find/by_distance' do
  lat_lon = params.values_at('latitude', 'longitude')
  position = Position.new(*lat_lon)
  stations.by_distance(position).take(5).to_json
end

get '/find/by_distance/min' do
  lat_lon = params.values_at('latitude', 'longitude')
  position = Position.new(*lat_lon)
  stations.by_distance_min(position).take(5).to_json
end

get '/find/country/:initials/min' do |initials|
  stations.find_country_min(initials).to_json
end

get '/find/country/:initials' do |initials|
  stations.find_country(initials).to_json
end

get '/find/:name' do |name|
  stations.find_named(name).to_json
end

get '/find/:name/min' do |name|
  stations.find_named_min(name).to_json
end