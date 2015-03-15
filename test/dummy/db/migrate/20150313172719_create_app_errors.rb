class CreateAppErrors < ActiveRecord::Migration
  def change
    create_table :app_errors do |t|
      t.references :app, index: true
      t.string :code
      t.string :message
    end
    add_foreign_key :app_errors, :apps
  end
end
