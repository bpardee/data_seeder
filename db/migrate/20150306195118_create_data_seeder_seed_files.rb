class CreateDataSeederSeedFiles < ActiveRecord::Migration
  def change
    create_table :data_seeder_seed_files do |t|
      t.string :path
      t.string :sha256
    end
  end
end
