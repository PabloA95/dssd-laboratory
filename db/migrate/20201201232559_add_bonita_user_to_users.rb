class AddBonitaUserToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bonitaUser, :string
  end
end
