class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :orderNo
      t.string :orderTime
      t.string :agentNo
      t.string :agentName
      t.string :type
      t.string :details
      t.string :visitorInfo
      t.timestamps
    end
  end
end
