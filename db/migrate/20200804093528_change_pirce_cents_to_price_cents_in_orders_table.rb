class ChangePirceCentsToPriceCentsInOrdersTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :orders, :pirce_cents, :price_cents
  end
end
