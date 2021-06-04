require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require './scraping_on_screen.rb'
require './scraping_movie.rb'
module Scraping_movie
 def self.load_movie_data(url)
   charset = nil
   
   html =  OpenURI.open_uri(url) do |f|
     sleep(1)
     charset = f.charset
     f.read
   end

   data = []
   
   doc = Nokogiri::HTML.parse(html, nil, charset)
      m_data = []
      m_data.push(doc.css('.movieDetailInfoFilm p').text.chomp)
      m_data.push(doc.css('#movieImage img')[0][:src])
      m_data.push(doc.css('.movieDetailInfoFilm iframe')[0][:src])
  data.push(m_data)
  return data
 end
end

data=Scraping_movie.load_movie_data('https://www.unitedcinemas.jp/all/film.php?film=12901?mute=1&amp;from=daily')
puts data