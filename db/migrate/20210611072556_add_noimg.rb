class AddNoimg < ActiveRecord::Migration[6.1]
  def change
    change_column :movies, :img, :string, default: 'no_img.png'
    change_column :todays, :img, :string, default: 'no_img.png'
  end
end
