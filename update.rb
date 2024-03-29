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

Everyday.update_on_screen_data #今日の上映情報を更新
Thumb.update_img　#no_imgを回避するため同一のタイトルから画像を引き継ぎ

#画像URLをうまく取得できなかった場合を回避、no_imgを設定
no_imgs = Today.where(img: "no_img.png")
no_imgs.each do |img|
 m_img = Movie.find_by(movie_id: img.movie_id, theater: img.theater)
 img.update(img: m_img.img) if m_img && m_img.img != "no_img.png"
end
