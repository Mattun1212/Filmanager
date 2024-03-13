module Everyday
  def self.update_on_screen_data
    Theater.all.each do |theater|
      url = "https://www.unitedcinemas.jp/#{theater.name}/daily.php"
      movies = Scraping_on_screen.load_schedule_data(url)
      
       # 同じ日のデータを一旦削除
      Today.where(theater: theater.name).delete_all
      movies.each do |movie|
        formatted_date = format_date(movie[2])
        movie_record = Movie.find_or_create_by(title: movie[0], movie_id: movie[1], theater: theater.name)
        movie_record.update(finish: formatted_date) if formatted_date
        
        # レコードが存在しない場合のみ新しいレコードを作成
        Today.find_or_create_by(title: movie[0], movie_id: movie[1], theater: theater.name) do |today|
          today.finish = movie[2]
          today.img = movie_record.img
        end
      end
    end
    
    # 上映が終了するに伴いデータを削除
    cleanup_finished_movies
  end

  private

  def self.format_date(date_string)
    return nil unless date_string
    date_array = date_string.split('/')
    Date.new(Date.today.year, date_array[0].to_i, date_array[1].to_i)
  rescue ArgumentError
    nil
  end

  def self.cleanup_finished_movies
    modified_today_date = Date.today + 1 #タイムゾーンの影響を解消するべく1日足す
    Movie.where("finish < ?", modified_today_date).each do |movie|
      Subscription.where(movie_id: movie.id).destroy_all
      movie.destroy
    end
  end
end