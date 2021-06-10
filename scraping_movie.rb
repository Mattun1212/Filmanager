require './update_on_screen.rb'
require './scraping_on_screen.rb'
require './scraping_movie.rb'
require 'sinatra/activerecord'
require 'open-uri'
require 'nokogiri'
require './models.rb'
require 'date'
require 'net/http'
module Scraping_movie
 def self.load_movie_data(url)
   charset = nil
   redirect_url = Net::HTTP.get_response(URI.parse(url))['location']
   html =  OpenURI.open_uri(redirect_url) do |f|
     sleep(1)
     charset = f.charset
     f.read
   end

   data = []
   
   doc = Nokogiri::HTML.parse(html, nil, charset)
      m_data = []
      m_data.push(doc.css('.movieDetailInfoFilm p').text.chomp)
      m_data.push(doc.css('#movieImage img')[0][:src])
    #   m_data.push(doc.css('.movieDetailInfoFilm iframe')[0][:src])
  data.push(m_data)
  return data
 end
end

data=Scraping_movie.load_movie_data('https://www.unitedcinemas.jp/urasoe/film.php?film=12637')
# puts data