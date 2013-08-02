require "logger"
require "multi_json"
require "pp"
require "sequel"
require "sinatra/base"
require "sinatra/json"
require "sinatra/reloader"

DB = Sequel.connect(ENV["DB"], logger: Logger.new(STDOUT))

class Search < Sinatra::Base
  enable :inline_templates
  helpers Sinatra::JSON

  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    erb :search
  end

  post "/" do
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
end

class View < Sinatra::Base
  helpers Sinatra::JSON

  configure :development do
    register Sinatra::Reloader
  end

  get "/:ndb_no" do
    return if params[:ndb_no] == "favicon.ico"

    food = DB[:food_des].where(ndb_no: params[:ndb_no]).first

    result = { name: food[:long_desc], nutrients: [] }

    # grp = DB[:fd_group].where(fdgrp_cd: food[:fdgrp_cd]).first[:fdgrp_desc]
    # result[:food_group] = grp

    nut_data = DB[:nut_data].where(ndb_no: params[:ndb_no]).all
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
<style>
input, button { font-size: 200%; }
input { width: 50%; }
</style>
<form name="search" action="/search" method="post">
  <input name="q" type="text">
  <button type="submit">Search</button>
</form>
