class AddBonitaIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bonitaId, :integer
  end
end
