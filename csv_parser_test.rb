require 'minitest/autorun'
require_relative 'captain_train_api'

class StationCollectionTest < Minitest::Test

  @@station_collection = StationCollection.new
  
  def test_stations_size
    assert_equal 20537, @@station_collection.size
  end

  def test_to_json
    station = @@station_collection.all.first
    assert_kind_of Station, station
  end
end

class StationTest < Minitest::Test
	def test_to_json
		station = Station.new(name: 'my station')
		assert_equal '{"name":"my station"}', station.to_json
	end

	def test_name
		assert_equal 'foo', Station.new('name' => 'foo').name
	end

	def test_valid?
		assert Station.new('name' => 'foo').valid?
		refute Station.new({}).valid?
	end

	def test_position
		station = Station.new('latitude' => '40.567', 'longitude' => '50.432')
		assert_kind_of Position, station.position
		assert_equal 40.567, station.position.lat
		assert_equal 50.432, station.position.lon
	end

	def test_distance
		station = Station.new('latitude' => '36.12', 'longitude' => '-86.67')
		destination = Position.new(33.94, -118.4)

		distance = station.distance(destination)
		assert_equal 2886.4, distance.distance.round(1)
	end
end


class PositionTest < Minitest::Test
  def test_new
    position = Position.new('40.456', '-50.456')

        assert_equal 40.456, position.lat
        assert_equal (-50.456), position.lon
  end
end

class DistanceTest < Minitest::Test
	def test_to_json
		distance = Distance.new(1337, { name: 'foo'})
		assert_equal '{"distance":1337,"station":{"name":"foo"}}', distance.to_json
	end
end