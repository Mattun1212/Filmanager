class ChangeUseridOfSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :line_id, :string
  end
end
