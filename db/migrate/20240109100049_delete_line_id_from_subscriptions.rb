class DeleteLineIdFromSubscriptions < ActiveRecord::Migration[6.1]
  def change
    remove_column :subscriptions, :line_id, :string
  end
end
