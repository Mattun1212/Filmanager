require 'csv'
require './update_on_screen.rb'
require './scraping_on_screen.rb'
require 'bundler/setup'
Bundler.require
require './models.rb'
Everyday.update_on_screen_data