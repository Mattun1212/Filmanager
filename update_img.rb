module Thumb
  def self.update_img
    Today.all.each do |today|
      m_url = "https://www.unitedcinemas.jp/#{today.theater}/film.php?film=#{today.movie_id}"
      begin
        info = Scraping_movie.load_movie_data(m_url)
        movie = Movie.find_by(movie_id: today.movie_id, theater: today.theater)
        next unless info[1].present? && info[1].strip != "no_img.png"
        movie.update(img: info[1].strip) if movie.img == "no_img.png" || !valid_image_url?(movie.img)
        today.update(img: movie.img)
      rescue => e
        puts e
      end
    end
  end

  def self.valid_image_url?(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue
    false
  end
end
