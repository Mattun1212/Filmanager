require './update_on_screen.rb'
require './scraping_on_screen.rb'
require './scraping_movie.rb'
require './update_img.rb'
require 'sinatra/activerecord'
require 'open-uri'
require 'nokogiri'
require './models.rb'
require 'date'
require 'net/http'

Everyday.update_on_screen_data
Thumb.update_img

no_imgs = Today.where(img: "no_img.png")
no_imgs.each do |img|
 m_img = Movie.find_by(movie_id: img.movie_id, theater: img.theater)
 img.update(img: m_img.img) if m_img && m_img.img != "no_img.png"
end
