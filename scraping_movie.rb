require 'kconv'
module Scraping_movie
 def self.load_movie_data(url)
   redirect_url = Net::HTTP.get_response(URI.parse(url))['location']
   html = OpenURI.open_uri(redirect_url, "r:binary").read
   html = html.sub(/^<!DOCTYPE html(.*)$/, '<!DOCTYPE html>')
   doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
   m_data = []
   m_data.push(doc.css('.movieDetailInfoFilm p').text.strip)
   m_data.push(doc.css('#movieImage img')[0][:src])
   m_data.push(doc.css('.movieDetailInfoFilm iframe')[0][:src])
  return m_data
 end
end
