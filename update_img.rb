module Thumb
 def self.update_img
#   movies=Movie.all
#   movies.each do |movie|
#     m_url='https://www.unitedcinemas.jp/'+movie.theater+'/film.php?film='+movie.movie_id.to_s
#         begin
#         info = Scraping_movie.load_movie_data(m_url)
#         Movie.find_by(movie_id: movie.movie_id, theater: movie.theater).update(img: info[1].strip)
#         Today.find_by(movie_id: movie.movie_id, theater: movie.theater).update(img: info[1].strip)
#         rescue => e
#           puts e
#         end
#     end
    
    todays = Today.all   
    todays.each do |today|
    m_url='https://www.unitedcinemas.jp/'+today.theater+'/film.php?film='+today.movie_id.to_s
        begin
        info = Scraping_movie.load_movie_data(m_url)
        movie = Movie.find_by(movie_id: today.movie_id, theater: today.theater)
        if movie.img == "no_img.png"
            Movie.find_by(movie_id: today.movie_id, theater: today.theater).update(img: info[1].strip)
        end
        Today.find_by(movie_id: today.movie_id, theater: today.theater).update(img: info[1].strip)
        rescue => e
          puts e
        end
    end
 end
end