module Everyday
 def self.update_on_screen_data
    @theaters=Theater.all
    Today.destroy_all
    @theaters.each do |theater|
    url='https://www.unitedcinemas.jp/'+theater.name+'/daily.php'
    @movies = Scraping_on_screen.load_schedule_data(url)
    
    @movies.each do |movie|
      unless Movie.find_by(title: movie[0], movie_id: movie[1],theater: theater.name)
       Movie.create(title: movie[0], movie_id: movie[1], theater: theater.name)
      end
      if movie[2]
       date = Date.today
       
       datearray = movie[2].split('/')
       puts datearray[1]
       formatteddate = Date.new(date.year, datearray[0], datearray[1])
       Movie.find_by(title: movie[0], movie_id: movie[1], theater: theater.name).update(finish: formatteddate)
      end
    end
    
    
    today = Date.today
    finishedmovies = Movie.where("finish < ?", today)
    finishedmovies.each do |fin|
     if Subscription.find_by(movie_id: fin.id).present?
       Subscription.find_by(movie_id: fin.id).destroy
     end
     fin.destroy
    end
  
    
    @movies.each do |movie|
        movie[3]=theater.name
        Today.create(title: movie[0], movie_id: movie[1], finish: movie[2] ,theater: movie[3])
       end
       # puts theater.name
    end
 end
end