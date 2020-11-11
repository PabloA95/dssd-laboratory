class CreateProtocols < ActiveRecord::Migration[6.0]
  def change
    create_table :protocols do |t|
      t.string :name
      t.boolean :local

      t.timestamps
    end
  end
end
