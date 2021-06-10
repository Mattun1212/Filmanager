require './update_on_screen.rb'
require './scraping_on_screen.rb'
require 'sinatra/activerecord'
require 'open-uri'
require 'nokogiri'
require './models.rb'
require 'date'
Everyday.update_on_screen_data