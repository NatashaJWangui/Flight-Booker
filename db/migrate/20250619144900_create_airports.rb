class CreateAirports < ActiveRecord::Migration[8.0]
  def change
    create_table :airports do |t|
      t.string :airport_code, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :airports, :airport_code, unique: true
  end
end
