class AddLineParamsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :line_name, :string
    add_column :users, :line_icon_url, :string
  end
end
