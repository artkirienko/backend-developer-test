# frozen_string_literal: true

POSSIBLE_TRIP = 'Trip is Possible'
IMPOSSIBLE_TRIP = 'Trip is impossible'

# @param start [String] start of the trip
# @param target [String] trip destination
# @param _stations [Array<String>]
# @param station_links [Hash<String, Array<String>>]
# @return [String] if trip is possible
def check_trip(start, target, _stations, station_links)
  visited = []
  queue = []
  queue.push(start)
  visited.push(start)
  while queue.any?
    node = queue.pop
    return POSSIBLE_TRIP if node == target

    station_links.fetch(node, []).each do |child|
      unless visited.include?(child)
        queue.push(child)
        visited.push(child)
      end
    end
  end
  IMPOSSIBLE_TRIP
end

stations = %w[ADL BRI MEL SYD]
links = { 'ADL' => %w[MEL], 'MEL' => %w[ADL SYD], 'SYD' => %w[BRI] }
puts check_trip('ADL', 'BRI', stations, links) # => 'Trip is Possible'
puts check_trip('ADL', 'BRI', stations, links) # => 'Trip is Possible'
puts check_trip('MEL', 'BRI', stations, links) # => 'Trip is Possible'
puts check_trip('SYD', 'ADL', stations, links) # => 'Trip is impossible'
