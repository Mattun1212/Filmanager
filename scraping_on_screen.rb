module Scraping_on_screen
 def self.load_schedule_data(url)
   charset = nil
   
   html =  OpenURI.open_uri(url) do |f|
     sleep(2)
     charset = f.charset
     f.read
   end

   data = []
   
   doc = Nokogiri::HTML.parse(html, nil, charset)

   doc.css('li.clearfix').each do |node|
      m_data = []
      m_data.push(node.css('span.movieTitle a').text.chomp)
      url_before = node.css('span.movieTitle a')[0][:href]
      id = url_before.split("=")[1].split("?")[0]
      m_data.push(id)
      if  node.css('p.endInfo').text != ''
       m_data.push(node.css('p.endInfo').text.split("上映")[0])
      end
      data.push(m_data)
   end
   
  return data
 end
end