[![Build Status](https://img.shields.io/travis/artkirienko/backend-developer-test/master.svg?style=flat-square&logo=travis-ci&logoColor=orange)](https://travis-ci.org/artkirienko/backend-developer-test)
[![GitHub Actions Ruby](https://github.com/artkirienko/backend-developer-test/workflows/Ruby/badge.svg)](https://github.com/artkirienko/backend-developer-test/actions)
[![HitCount](http://hits.dwyl.io/artkirienko/backend-developer-test.svg)](http://hits.dwyl.io/artkirienko/backend-developer-test)

# Backend Developer Test

## Task 1

What is the major concern of the following code and how would you improve it?
Please explain your concerns using in-line comments

```ruby
class InfographicsController < ApplicationController # allows user to change their infographic title
  def update
    @infographic = Infographic.find(params[:id])
    if @infographic.update_attributes(update_params)
      render json: @infographic
    else
      render json: { errors: @infographic.errors.full_messages }, status: 422
    end
  end

  private

  def update_params
    params.require(:infographic).permit(:title)
  end
end
```

### Solution

<details><summary>CLICK TO EXPAND!</summary>
<p>

```ruby
class InfographicsController < ApplicationController
  # allows user to change their infographic title
  #
  # we need to authorize user: check if a user has permission to update
  # this infographic (check if a user owns it)
  # if we use gem 'cancancan', we can simply add
  #
  # load_and_authorize_resource
  #
  # to the top of our controller. It will use a before action to load
  # the resource into an instance variable and authorize it for every action.
  #
  def update
    # another option is to change this line
    @infographic = Infographic.find(params[:id])
    #
    # @infographic = Infographic.find_by!(id: 3, user: current_user)
    #
    # so we only use current_user variable (e.g. from gem 'devise')
    # or we can just add this line here (uses gem 'cancancan'):
    #
    # authorize! :update, @infographic
    #
    if @infographic.update_attributes(update_params)
      render json: @infographic
      # Codestyle concern: we have 'status: 422' two lines below
      # why there is no 'status: 200' here
      # and status: :ok is friendlier for human then status: 200
      #
      # We don't send location header (we need, since we updated object)
      #
      # We render all the object attributes (even if js-frontend/microservice/client
      # don't need all of them and shouldn't really know about existence of some of them)
      # because we skip the view layer
      # (some erb/jbuilder/rabl templates / ActiveModel::Serializer / fast_jsonapi)
      #
      # my variant:
      # render :show, status: :ok, location: @infographic
    else
      render json: { errors: @infographic.errors.full_messages }, status: 422
      # The main concern here is about error messages
      # right now it is useless for js-frontend/microservice/client since
      # js-frontend/microservice/client don't know what field the message is
      # related to:
      # {
      #   "errors": [
      #     "Title is too short (minimum is 5 characters)"
      #   ]
      # }
      # should be:
      # {
      #   "title": [
      #     "is too short (minimum is 5 characters)"
      #   ]
      # }
      #
      # codestyle concern: 'unprocessable_entity' is friendlier for human
      # then '422'
      #
      # my variant:
      # render json: { errors: @infographic.errors }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.require(:infographic).permit(:title)
  end
end
```

</p>
</details>

## Task 2

What kind of situation(s) would trigger the line where 'status: 422'?

```ruby
class InfographicsController < ApplicationController
  def show
    @infographic = Infographic.find(params[:id])
    if @infographic
      render json: @infographic
    else
      render json: {}, status: 422
    end
  end
end
```

### Solution

<details><summary>CLICK TO EXPAND!</summary>
<p>

```ruby
# in general, this if-condition is useless here, since
# to get `status: 422` we need @infographic to be falsy and
# in a daily life it couldn't be falsy

# if `find` method couldn't find a record with id provided
# it raises `ActiveRecord::RecordNotFound` error

# but if we redefine `find` method like this (or any other way
# to return `nil` or `false`):

class Infographic < ApplicationRecord
  def self.find(id)
    Infographic.find_by(id: id)
  end
end

# it will return `nil` and thus we'll get `status: 422`
```

</p>
</details>

## Task 3

A friend of yours is planning a trip across the country via train, but they can't read the train information! They've asked you to help and they want you to check if they can get from place to place on the rail network. You hit a snag while trying to help when you've found that the trains don't always return to a station they've departed from! That is to say that a train route might go from Station X to Station Y, but it might not go from Station Y to Station X.

They love train trips so they don't care how many trains it takes as long as it's possible to reach their target destination.

You've decided to write a program to help you with the job and the format you've decide to use is as follows:

`check_trip(start, target, stations, station_links)`

You want the method to return "Trip is Possible" if the trip is possible and "Trip is impossible" if otherwise

Example usages:

```ruby
stations = ["ADL", "BRI", "MEL", "SYD"]
links = { "ADL" => ["MEL"], "MEL" => ["ADL", "SYD"], "SYD" => ["BRI"] }
check_trip("ADL", "BRI", stations, links) # => "Trip is Possible"
check_trip("MEL", "BRI", stations, links) # => "Trip is Possible"
check_trip("SYD", "ADL", stations, links) # => "Trip is impossible"
```

Note: The Hash provided for the 'links' argument will always have default = []

```ruby
def check_trip(start, target, stations, station_links)
  # your code here
end
```

### Solution (using Ruby Graph Library)

<details><summary>CLICK TO EXPAND!</summary>
<p>

```ruby
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
```

</p>
</details>

### Solution (Plain Ruby)

<details><summary>CLICK TO EXPAND!</summary>
<p>

```ruby
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
```

</p>
</details>

## Task 4

What strategies would you use to optimize the rendering time? (Hint: there’s more than 1 strategy to be implemented)

Controller

```ruby
def index
  @themes = Theme.published.order(created_at: :desc) # takes an average of 350ms
  respond_to do |format|
    format.html
    format.json { render json: @themes }
  end
end
```

View (part of it) - this portion takes an average of 1000ms to render

```erb
<% @themes.each do |theme| %>
  <li id="pikto-theme-item-<%= theme.id %>" class="theme-items">
    <div class="<%= 'protemplate' if theme.pro? && current_user.is_free? %>">
      <% if theme.is_new? %>
        <i class="icon-tagnew"></i>
      <% end %>
      <% if theme.is_featured? %>
        <i class="icon-tagfeatured"></i>
      <% end %>
      <div class="the-infographic-img">
        <a href="#"><%= image_tag(theme.snapshot.url(:medium)) %></a>
      </div>
    </div>
    <div class="infographic-details">
      <%= theme.title %>
    </div>
  </li>
<% end %>
```

### Solution

<details><summary>CLICK TO EXPAND!</summary>
<p>

```ruby
# 1. Database indexes/indices
# 2. Eager loading associations
# 3. Conditional GETs (HTTP feature) caching
# 4. View Fragment Caching
# 5. !IMPORTANT: if nothing helps, just cache this stuff
#    using memcached/redis (Google: Rails Model Caching with Redis),
#    cache two queries: one for free user, one for paid user

# app/models/theme.rb
class Theme < ApplicationRecord
  has_one :snapshot

  scope :published, -> { where.not(published_at: nil) }
end

# app/models/snapshot.rb
class Snapshot < ApplicationRecord
  belongs_to :theme, touch: true # used to expire cache
  # ...
end

# app/controllers/themes_controller.rb
class ThemesController < ApplicationController
  def index
    # eager_loading snapshot association
    @themes =
      Theme
      .published
      .order(created_at: :desc)
      .eager_load(:snapshot)

    # using Conditional GETs (HTTP feature) caching
    return unless stale?([@themes, current_user])

    respond_to do |format|
      format.html
      format.json { render json: @themes }
    end
  end
end

# app/views/themes/index.html.erb
# using Fragment Caching
<% @themes.each do |theme| %>
  <li id="pikto-theme-item-<%= theme.id %>" class="theme-items">
    <div class="<%= 'protemplate' if theme.pro? && current_user.is_free? %>">
      <% cache theme do %>
        <% if theme.is_new? %>
          <i class="icon-tagnew"></i>
        <% end %>
        <% if theme.is_featured? %>
          <i class="icon-tagfeatured"></i>
        <% end %>
        <div class="the-infographic-img">
          <a href="#"><%= image_tag(theme.snapshot.url(:medium)) %></a>
        </div>
      <% end %>
    </div>
    <div class="infographic-details">
      <%= theme.title %>
    </div>
  </li>
<% end %>

# db/schema.rb
# using indexes/indices
create_table "snapshots", force: :cascade do |t|
  # ...
  t.integer "theme_id"
  t.index ["theme_id"], name: "index_snapshots_on_theme_id"
end

create_table "themes", force: :cascade do |t|
  # ...
  t.index ["published_at", "created_at"], name: "index_themes_on_published_at_and_created_at", order: { created_at: :desc }
end
```

</p>
</details>
