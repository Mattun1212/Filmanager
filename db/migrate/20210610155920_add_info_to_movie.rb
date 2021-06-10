class AddInfoToMovie < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :detail, :string, default: ''
    add_column :movies, :img, :string, default: ''
    add_column :movies, :youtube, :string, default: ''
    add_column :todays, :img, :string, default: ''
  end
end
