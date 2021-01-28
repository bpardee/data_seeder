class CreateStates < ActiveRecord::Migration[4.2]
  def change
    create_table :states do |t|
      t.string :code
      t.string :name
    end
  end
end
