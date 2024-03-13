module Thumb
  # 全ての映画の有効な画像URLをキャッシュし、更新処理を効率化
  def self.update_img
    # "no_img.png"以外の画像を持つ映画のmovie_idと画像URLをキャッシュする
    valid_images_cache = Movie.where.not(img: "no_img.png").pluck(:movie_id, :img).to_h

    Today.all.each do |today|
      # 既に有効な画像URLを持っている場合は、処理をスキップ
      next if today.img != "no_img.png" && valid_image_url?(today.img)
      
      # 映画レコードを探すか、新しく初期化
      movie = Movie.find_or_initialize_by(movie_id: today.movie_id, theater: today.theater)
      
      # キャッシュに有効な画像がある場合は、それを使用して映画レコードを更新
      if valid_images_cache[today.movie_id]
        movie.img = valid_images_cache[today.movie_id]
      else
        # キャッシュに画像がない場合は、Webからスクレイピングして画像URLを取得
        m_url = "https://www.unitedcinemas.jp/#{today.theater}/film.php?film=#{today.movie_id}"
        info = Scraping_movie.load_movie_data(m_url)
        # スクレイピングした画像URLが有効であることを確認
        next unless info[1].present? && valid_image_url?(info[1].strip)
        movie.img = info[1].strip
        # 新しい画像URLをキャッシュに追加
        valid_images_cache[today.movie_id] = info[1].strip 
      end
      
      # 映画レコードに変更があれば保存、Todayレコードの画像URLが変更された場合は、それを更新
      movie.save if movie.changed?
      today.update(img: movie.img) if today.img != movie.img
    end
  end

  # 与えられたURLが有効な画像URLであるかをチェック
  def self.valid_image_url?(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    # HTTPのステータスコードが成功（200 OKなど）であればtrueを返す
    response.is_a?(Net::HTTPSuccess)
  rescue
    # URLの解析やHTTPリクエストでエラーが発生した場合はfalseを返す
    false
  end
end