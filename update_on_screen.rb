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
       Movie.find_by(title: movie[0], movie_id: movie[1], theater: theater.name).update(finish: movie[2])
      end
    end
    
    
    today = Date.today
    dates = Movie.all
    dates.each do |date|
     if date.finish.present?
      finish=date.finish.split('/')
      if today.month==finish[0].to_i
        if today.day > finish[1].to_i
         if Subscription.find_by(movie_id: date.id).present?
          Subscription.find_by(movie_id: date.id).destroy
         end
        end
      elsif today.month >finish[0].to_i
       if Subscription.find_by(movie_id: date.id).present?
         Subscription.find_by(movie_id: date.id).destroy
       end
      end
     end
    end
    
    
    @movies.each do |movie|
        movie[3]=theater.name
        Today.create(title: movie[0], movie_id: movie[1], finish: movie[2] ,theater: movie[3])
       end
       # puts theater.name
    end
 end
end