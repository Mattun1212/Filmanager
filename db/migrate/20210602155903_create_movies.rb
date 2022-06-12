class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :movie_id
      t.string :theater
      t.date :finish, default: ''
      t.timestamps null: false
    end
  end
end
