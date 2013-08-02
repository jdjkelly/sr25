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
    erb :search
  end

  post "/search" do
    results = []
    foods = DB[:food_des]
    query = params[:q]
    query.gsub!(/(\w)\ (\w)/i, "\\1 & \\2") unless query.match(/\||\&|\!/)
    search = foods.filter("tsv @@ to_tsquery('english', ?)", query)
    search.order(:long_desc).each do |row|
      results.push({ id: row[:ndb_no], description: row[:long_desc] })
    end
    json results
  end

  get "/:ndb_no" do
    food = DB[:food_des].where(ndb_no: params[:ndb_no]).first
    result = { description: food[:long_desc], group: nil, nutrients: [] }

    grp = DB[:fd_group].where(fdgrp_cd: food[:fdgrp_cd]).first[:fdgrp_desc]
    result[:group] = grp

    nut_data = DB[:nut_data].where(ndb_no: params[:ndb_no]).order(:nutr_no).all
    nut_data.each do |nutrient|
      nutr = DB[:nutr_def].where(nutr_no: nutrient[:nutr_no]).first
      result[:nutrients].push({
        name: nutr[:nutrdesc],
        value: nutrient[:nutr_val],
        units: nutr[:units]
      })
    end

    json result
  end
end

__END__

@@ search
<!DOCTYPE html>
<title>search sr25</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="/css/bootstrap.min-9546fc9.css">
<style>body{margin-top:40px}</style>
<div class="container">
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
</div>
