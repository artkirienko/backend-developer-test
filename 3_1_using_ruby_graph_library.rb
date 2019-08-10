# frozen_string_literal: true

# you need to install Ruby Graph Library to use this solution
# `gem install rgl`
require 'rgl/adjacency'
require 'rgl/traversal'

POSSIBLE_TRIP = 'Trip is Possible'
IMPOSSIBLE_TRIP = 'Trip is impossible'

# @param start [String] start of the trip
# @param target [String] trip destination
# @param stations [Array<String>]
# @param station_links [Hash<String, Array<String>>]
# @return [String] if trip is possible
def check_trip(start, target, stations, station_links)
  graph = RGL::DirectedAdjacencyGraph.new

  stations.each { |station| graph.add_vertex(station) }
  station_links.each do |head, tails|
    tails.each { |tail| graph.add_edge head, tail }
  end
  graph.dfs_iterator(start).any?(target) ? POSSIBLE_TRIP : IMPOSSIBLE_TRIP
end

stations = %w[ADL BRI MEL SYD]
links = { 'ADL' => %w[MEL], 'MEL' => %w[ADL SYD], 'SYD' => %w[BRI] }
puts check_trip('ADL', 'BRI', stations, links) # => 'Trip is Possible'
puts check_trip('MEL', 'BRI', stations, links) # => 'Trip is Possible'
puts check_trip('SYD', 'ADL', stations, links) # => 'Trip is impossible'
