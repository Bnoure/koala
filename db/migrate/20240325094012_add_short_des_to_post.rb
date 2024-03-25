class AddShortDesToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :short, :string
  end
end
