class CreateToday < ActiveRecord::Migration[6.1]
  def change
    create_table :todays do |t|
      t.string :title
      t.integer :movie_id
      t.string :theater
      t.string :finish, default: ''
      t.timestamps null: false
    end
  end
end
