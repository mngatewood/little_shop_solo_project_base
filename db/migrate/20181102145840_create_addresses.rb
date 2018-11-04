class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :nickname
      t.boolean :default, default: false
      t.boolean :active, default: true

      t.timestamps
      t.references :user, foreign_key: true
    end
  end
end
