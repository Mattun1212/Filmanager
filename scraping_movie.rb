require 'open-uri'
require 'nokogiri'
require 'kconv'

module Scraping_movie
  def self.load_movie_data(url)
    response = Net::HTTP.get_response(URI.parse(url))
    redirect_url = response['location'] || url  # リダイレクトがない場合は元のURLを使用
    html = OpenURI.open_uri(redirect_url, "r:binary").read
    html = html.sub(/^<!DOCTYPE html(.*)$/, '<!DOCTYPE html>')
    doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

    m_data = []
    m_data.push(doc.css('.movieDetailInfoFilm p').text.strip.presence || 'タイトル不明')
    img_src = doc.css('#movieImage img')[0] ? doc.css('#movieImage img')[0][:src] : 'no_img.png'
    m_data.push(img_src)
    iframe_src = doc.css('.movieDetailInfoFilm iframe')[0] ? doc.css('.movieDetailInfoFilm iframe')[0][:src] : 'no_video'
    m_data.push(iframe_src)
    return m_data
  end
end