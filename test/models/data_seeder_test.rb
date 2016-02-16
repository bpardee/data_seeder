require 'test_helper'

describe DataSeeder, :model do
  describe 'when run with txt files' do
    before do
      @name      = 'test.txt'
      @seed_dirs = setup_seed_dirs(@name, 'countries_txt', 'states_txt')
    end

    after do
      cleanup_seed_dir(@name)
    end

    it 'should load seed files' do
      modify_seed_file(@name, 'states_txt/states.txt') do |body|
        body.sub('KY Kentucky', 'KV Kentucky').sub('VT Vermont', 'VT Vermount')
      end
      DataSeeder.run(seed_dirs: @seed_dirs)
      assert_equal 50, State.count
      assert_equal 'United States', Country.find_by(code: 'US').try(:name)
      assert_equal 'Kentucky', State.find_by(code: 'KV').try(:name)
      assert_equal 'Vermount', State.find_by(code: 'VT').try(:name)
      modify_seed_file(@name, 'states_txt/states.txt') do |body|
        body.sub('KV Kentucky', 'KY Kentucky').sub('VT Vermount', 'VT Vermont')
      end
      DataSeeder.run
      assert_equal 50, State.count
      assert_equal 'Kentucky', State.find_by(code: 'KY').try(:name)
      assert_equal 'Vermont', State.find_by(code: 'VT').try(:name)
      assert_nil   State.find_by(code: 'KV')
    end
  end

  %w(csv json yml).each do |loader_type|
    describe "when run with #{loader_type} files" do
      before do
        @name      = "test.#{loader_type}"
        @dir       = "states_#{loader_type}"
        @file      = "#{@dir}/states.#{loader_type}"
        @seed_dirs = setup_seed_dirs(@name, @dir)
      end

      after do
        cleanup_seed_dir(@name)
      end

      it 'should load seed files' do
        modify_seed_file(@name, @file) do |body|
          body.sub('Alaska', 'Alaskaska')
        end
        DataSeeder.run(seed_dirs: @seed_dirs)
        assert_equal 50, State.count
        assert_equal 'Alaskaska', State.find_by(code: 'AK').try(:name)
        modify_seed_file(@name, @file) do |body|
          body.sub('Alaskaska', 'Alaska')
        end
        DataSeeder.run(seed_dirs: @seed_dirs)
        assert_equal 50, State.count
        assert_equal 'Alaska', State.find_by(code: 'AK').try(:name)
      end
    end
  end

  describe 'when run with use_line_number_as_id' do
    before do
      @name      = "test.use_line_number_as_id"
      @dir       = "states_csv"
      @seed_dirs = setup_seed_dirs(@name, @dir)
    end

    after do
      cleanup_seed_dir(@name)
    end

    it 'should use the line number as the id' do
      modify_seed_file(@name, 'states_csv/states.csv') do |body|
        # Remove the id column
        body.gsub(/^.*?,/,'')
      end
      File.open(seed_file_name(@name, 'states_csv/states.cfg'), 'w') {|f| f.write '{ use_line_number_as_id: true }'}
      DataSeeder.run(seed_dirs: @seed_dirs)
      assert_equal 'AK', State.find(1).code
      assert_equal 'WY', State.find(50).code
    end
  end

  describe 'when run with postprocess config' do
    before do
      @name      = "test.postprocess"
      @dir       = "countries_csv"
      @seed_dirs = setup_seed_dirs(@name, @dir)
    end

    after do
      cleanup_seed_dir(@name)
    end

    it 'should allow the postprocess config to modify attributes' do
      DataSeeder.run(seed_dirs: @seed_dirs)
      assert_equal 'United States', Country.find_by(code: 'US').try(:name)
    end
  end


  describe 'when run with a custom loader' do
    before do
      @name      = 'test.custom'
      @seed_dirs = setup_seed_dirs(@name, 'states_txt', 'foo_err', 'bar_err')
    end

    after do
      cleanup_seed_dir(@name)
    end

    it 'should load seed files' do
      modify_seed_file(@name, 'states_txt/states.txt') do |body|
        body.sub('KY Kentucky', 'KV Kentucky').sub('VT Vermont', 'VT Vermount')
      end
      DataSeeder.run(seed_dirs: @seed_dirs, loaders: {'err' => AppErrorDataSeeder})
      assert_equal 50, State.count
      assert_equal 'Kentucky', State.find_by(code: 'KV').try(:name)
      assert_equal 'Vermount', State.find_by(code: 'VT').try(:name)
      assert_equal 2, App.count
      assert App.find_by(name: 'foo')
      bar = App.find_by(name: 'bar')
      assert bar
      assert 3, bar.app_errors.count
      assert_equal 'Error message for B1', bar.app_errors.find_by(code: 'B1').try(:message)

      modify_seed_file(@name, 'states_txt/states.txt') do |body|
        body.sub('KV Kentucky', 'KY Kentucky').sub('VT Vermount', 'VT Vermont')
      end
      modify_seed_file(@name, 'bar_err/bar.err') do |body|
        body.sub('B1 Error message for B1', 'C1 Error message for C1')
      end
      DataSeeder.run(seed_dirs: @seed_dirs, loaders: {'err' => AppErrorDataSeeder})
      assert_equal 50, State.count
      assert_equal 'Kentucky', State.find_by(code: 'KY').try(:name)
      assert_equal 'Vermont', State.find_by(code: 'VT').try(:name)
      assert_nil   State.find_by(code: 'KV')
      assert_equal 2, App.count
      assert App.find_by(name: 'foo')
      bar = App.find_by(name: 'bar')
      assert bar
      assert 3, bar.app_errors.count
      assert_nil bar.app_errors.find_by(code: 'B1')
      assert_equal 'Error message for C1', bar.app_errors.find_by(code: 'C1').try(:message)

      FileUtils.cp_r(Rails.root.join('db', 'seed.test', 'zulu_err'), seed_dir_name(@name))
      DataSeeder.config.add_seed_dir(seed_file_name(@name, 'zulu_err'))
      DataSeeder.run
      assert_equal 50, State.count
      assert_equal 3, App.count
      zulu = App.find_by(name: 'zulu')
      assert zulu
      assert_equal 2, zulu.app_errors.count
      assert zulu.app_errors.find_by(code: 'Z1')
    end
  end


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
