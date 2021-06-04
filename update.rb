require 'csv'
require './update_on_screen.rb'
require './scraping_on_screen.rb'
require 'sinatra/activerecord'
require 'open-uri'
require 'nokogiri'
require './models.rb'
Everyday.update_on_screen_data