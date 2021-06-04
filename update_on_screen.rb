require './scraping_on_screen.rb'
module Everyday
 def self.update_on_screen_data
    @theaters=Theater.all
    headers = %w[title movie_id finish theater]
    CSV.open('Today_on_screen.csv', 'w') { |csv| csv << headers }
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
    
    @movies.each do |movie|
        movie[3]=theater.name
        add=CSV.open('Today_on_screen.csv', 'a:utf-8')
        add.puts movie
        add.close
    end
    end
 end
end