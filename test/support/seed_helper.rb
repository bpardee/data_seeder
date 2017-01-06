module SeedHelper
  def setup_seed_dirs(name, *dirs)
    dir_name = seed_dir_name(name)
    FileUtils.mkdir_p(dir_name)
    return dirs.map do |dir|
      FileUtils.cp_r(Rails.root.join('db', 'seed.test', dir), dir_name)
      "#{dir_name}/#{dir}"
    end
  end

  def cleanup_seed_dir(name)
    FileUtils.rm_rf(seed_dir_name(name))
    # Reset config stuff
    DataSeeder.reset
  end

  def modify_seed_file(name, file, &block)
    file_name = seed_file_name(name, file)
    body = File.read(file_name)
    File.open(file_name, 'w') do |f|
      f.write yield(body)
    end
  end

  def seed_dir_name(name)
    Rails.root.join('tmp', "db.seed.#{name}.#{$$}")
  end

  def seed_file_name(name, file)
    File.join(seed_dir_name(name), file)
  end
end
