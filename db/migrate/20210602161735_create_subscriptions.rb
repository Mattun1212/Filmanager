class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :movie_id
      t.string :theater
      t.timestamps null: false
    end
  end
end
