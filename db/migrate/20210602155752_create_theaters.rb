class CreateTheaters < ActiveRecord::Migration[6.1]
  def change
     create_table :theaters do |t|
      t.string :official
      t.string :name
      t.timestamps null: false
     end
  end
end
