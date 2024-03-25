class AddColumnToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :urlI, :string
  end
end
