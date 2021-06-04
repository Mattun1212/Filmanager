class CreateUsers < ActiveRecord::Migration[6.1]
  def change
     create_table :users do |t|
      t.string :name
      t.string :mail
      t.string :my_theater
      t.string :password_digest
      t.timestamps null: false
     end
  end
end
