class CreatePassengers < ActiveRecord::Migration[8.0]
  def change
    create_table :passengers do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
