require 'bundler'
Bundler.require

require './app'
run Sinatra::Application

Dotenv.load
use OmniAuth::Builder do
  provider :line, ENV["LINE_CHANNEL_ID"], ENV["LINE_CHANNEL_SECRET"]
end