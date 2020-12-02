class AddBonitaPasswordToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bonitaPassword, :string
  end
end
