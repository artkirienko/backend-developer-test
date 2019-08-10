# 1. Database indexes/indices
# 2. Eager loading associations
# 3. Conditional GETs (HTTP feature) caching
# 4. View Fragment Caching

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
