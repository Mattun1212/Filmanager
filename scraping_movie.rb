module Scraping_movie
 def self.load_movie_data(url)
   charset = nil
   redirect_url = Net::HTTP.get_response(URI.parse(url))['location']
   html =  OpenURI.open_uri(redirect_url) do |f|
     sleep(1)
     charset = f.charset
     f.read
   end

   
   doc = Nokogiri::HTML.parse(html, nil, charset)
      m_data = []
      m_data.push(doc.css('.movieDetailInfoFilm p').text.chomp)
      m_data.push(doc.css('#movieImage img')[0][:src])
    #   m_data.push(doc.css('.movieDetailInfoFilm iframe')[0][:src])
  return m_data
 end
end

