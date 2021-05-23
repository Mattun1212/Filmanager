class Addtitle < ActiveRecord::Migration[6.1]
  def change
    add_column :counts, :title, :text
  end
end
