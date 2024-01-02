require 'kconv'
module Scraping_on_screen
 def self.load_schedule_data(url)
   data = []
   html = OpenURI.open_uri(url, "r:binary").read
   html = html.sub(/^<!DOCTYPE html(.*)$/, '<!DOCTYPE html>')
   doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

   doc.css('li.clearfix').each do |node|
      m_data = []
      m_data.push(node.css('span.movieTitle a').first.text.strip)
      url_before = node.css('span.movieTitle a')[0][:href]
      id = url_before.split("=")[1].split("?")[0]
      m_data.push(id)
      if node.css('p.endInfo').text != ''
       m_data.push(node.css('p.endInfo').text.split("上映")[0])
      end
      data.push(m_data)
   end
   
  return data
 end
end