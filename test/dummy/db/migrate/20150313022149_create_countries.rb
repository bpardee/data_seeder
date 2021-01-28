class CreateCountries < ActiveRecord::Migration[4.2]
  def change
    create_table :countries do |t|
      t.string :code
      t.string :name
    end
  end
end
