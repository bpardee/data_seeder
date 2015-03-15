class CreateDataSeederSeedFiles < ActiveRecord::Migration
  def change
    create_table :data_seeder_seed_files do |t|
      t.string :path, null: false
      t.string :sha256, null: false
    end
    add_index :data_seeder_seed_files, :path, unique: true
  end
end
