require "./app"

use Rack::Deflater

map "/search" do
  run Search
end

map "/" do
  run View
end
