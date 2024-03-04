module Thumb
  def self.update_img
    valid_images_cache = Movie.where.not(img: "no_img.png").pluck(:movie_id, :img).to_h

    Today.all.each do |today|
      next if today.img != "no_img.png" && valid_image_url?(today.img)
      
      movie = Movie.find_or_initialize_by(movie_id: today.movie_id, theater: today.theater)
      
      # 有効な画像URLを他のレコードから再利用
      if valid_images_cache[today.movie_id]
        movie.img = valid_images_cache[today.movie_id]
      else
        info = Scraping_movie.load_movie_data(m_url)
        next unless info[1].present? && valid_image_url?(info[1].strip)
        movie.img = info[1].strip
        valid_images_cache[today.movie_id] = info[1].strip # キャッシュを更新
      end
      
      movie.save if movie.changed?
      today.update(img: movie.img) if today.img != movie.img
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
