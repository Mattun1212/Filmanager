module Everyday
  def self.update_on_screen_data
    Theater.all.each do |theater|
      url = "https://www.unitedcinemas.jp/#{theater.name}/daily.php"
      movies = Scraping_on_screen.load_schedule_data(url)
      
      movies.each do |movie|
        formatted_date = format_date(movie[2])
        movie_record = Movie.find_or_create_by(title: movie[0], movie_id: movie[1], theater: theater.name)
        movie_record.update(finish: formatted_date) if formatted_date
        
        Today.create(title: movie[0], movie_id: movie[1], finish: movie[2], theater: theater.name, img: movie_record.img)
      end
    end
    
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
    Movie.where("finish < ?", Date.today).each do |movie|
      Subscription.where(movie_id: movie.id).destroy_all
      movie.destroy
    end
  end
end
