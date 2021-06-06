class AddLineid < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :line_id, :string, default: ''
  end
end
