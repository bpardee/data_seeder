class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.references :app, index: true
      t.string :code
      t.string :message

      t.timestamps null: false
    end
    add_foreign_key :errors, :apps
  end
end
