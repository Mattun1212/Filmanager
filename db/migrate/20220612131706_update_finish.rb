class UpdateFinish < ActiveRecord::Migration[6.1]
  def change
     remove_column :movies, :finish, :string
     add_column :movies, :finish, :date
  end
end
