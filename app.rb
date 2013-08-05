require "logger"
require "multi_json"
require "newrelic_rpm"
require "pp"
require "sequel"
require "sinatra/base"
require "sinatra/json"
require "sinatra/reloader"

DB = Sequel.connect(ENV["DB"], logger: Logger.new(STDOUT))

class SR25 < Sinatra::Base
  enable :inline_templates
  helpers Sinatra::JSON

  configure :development do
    register Sinatra::Reloader
  end

  get "/search" do
    @title = "National Nutrient Database for Standard Reference Release 25"
    erb :search_form
  end

  post "/search" do
    @results = []
    foods = DB[:food_des]
    query = params[:q]
    query.gsub!(/(\w)\ (\w)/i, "\\1 & \\2") unless query.match(/\||\&|\!/)
    search = foods.filter("tsv @@ to_tsquery('english', ?)", query)
    search.each do |row|
      @results.push({ id: row[:ndb_no], description: row[:long_desc] })
    end

    if request.env["HTTP_ACCEPT"].match(/application\/json/i)
      json @results
    else
      @title = "Results for <code>#{query}</code>"
      erb :search_results
    end
  end

  get "/:ndb_no" do
    food = DB[:food_des].where(ndb_no: params[:ndb_no]).first
    @result = { description: food[:long_desc], group: nil, nutrients: [] }

    grp = DB[:fd_group].where(fdgrp_cd: food[:fdgrp_cd]).first[:fdgrp_desc]
    @result[:group] = grp

    nut_data = DB[:nut_data].where(ndb_no: params[:ndb_no]).order(:nutr_no).all
    nut_data.each do |nutrient|
      nutr = DB[:nutr_def].where(nutr_no: nutrient[:nutr_no]).first
      @result[:nutrients].push({
        name: nutr[:nutrdesc],
        value: nutrient[:nutr_val],
        units: nutr[:units]
      })
    end

    if request.env["HTTP_ACCEPT"].match(/application\/json/i)
      json @result
    else
      @title = @result[:description]
      erb :food_information
    end
  end
end

__END__
@@ layout
<!DOCTYPE html>
<title>search sr25</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="/css/bootstrap.min-9546fc9.css">
<style>
body { margin-top: 70px; }
.navbar-brand { max-width: 100%; }
.navbar-brand b { font-weight: 400; padding-left: 10px; }
</style>
<div class="navbar navbar-fixed-top">
  <div class="container">
    <span class="navbar-brand pull-left">
      <%= @title %>
      <% if @result %><b class="h6 text-muted"><%= @result[:group] %></b><% end %>
    </span>
    <% if @result || @results %>
    <form name="search" action="/search" method="post" class="navbar-form pull-right">
      <input type="text" name="q" placeholder="eggs" class="form-control" style="width: 300px;">
      <button type="submit" class="btn btn-default">Search</button>
    </form>
    <% end %>
  </div>
</div>
<div class="container">
  <%= yield %>
</div>

@@ search_form
<form name="search" action="/search" method="post">
  <div class="form-group">
    <p class="help-block">
      Enter a food name or description.
      Use logical operators (&amp;, |, !) for advanced search; e.g. <code>(duck | quail) & ! eggs</code>
    </p>
    <input autofocus name="q" type="text" placeholder="eggs" class="form-control input-large">
  </div>
  <button type="submit" class="btn btn-primary btn-large pull-right">
    Search
  </button>
</form>

@@ search_results
<div class="list-group">
  <% @results.each do |r| %>
  <a href="/<%= r[:id] %>" class="list-group-item">
    <%= r[:description] %>
  </a>
  <% end %>
</div>

@@ food_information
<table class="table table-stripped table-hover table-bordered">
  <thead>
    <tr>
      <th>Nutrient</th>
      <th>per 100g</th>
      <th>Unit</th>
    </tr>
  </thead>
  <tbody>
    <% @result[:nutrients].each do |n| %>
      <% if n[:value] > 0 %>
        <tr>
          <td><%= n[:name] %></td>
          <td><%= n[:value] %></td>
          <td><%= n[:units] %></td>
        </tr>
      <% end %>
    <% end %>
  </tbody>
</table>
