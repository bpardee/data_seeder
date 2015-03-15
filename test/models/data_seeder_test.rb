require 'test_helper'

describe DataSeeder, :model do
  before do
    @name = 'test1'
    @seed_dir = setup_seed_dir(@name, 'countries.txt', 'states.txt')
  end

  after do
    cleanup_seed_dir('test1')
  end

  describe 'when run' do
    it 'should load seed files' do
      modify_seed_file(@name, 'states.txt') do |body|
        body.sub('KY Kentucky', 'KV Kentucky').sub('VT Vermont', 'VT Vermount')
      end
      DataSeeder.run(seed_dir: @seed_dir)
      assert_equal 50, State.count
      assert_equal 'United States', Country.find_by(code: 'US').try(:name)
      assert_equal 'Kentucky', State.find_by(code: 'KV').try(:name)
      assert_equal 'Vermount', State.find_by(code: 'VT').try(:name)
      modify_seed_file(@name, 'states.txt') do |body|
        body.sub('KV Kentucky', 'KY Kentucky').sub('VT Vermount', 'VT Vermont')
      end
      DataSeeder.run(seed_dir: @seed_dir)
      assert_equal 50, State.count
      assert_equal 'Kentucky', State.find_by(code: 'KY').try(:name)
      assert_equal 'Vermont', State.find_by(code: 'VT').try(:name)
      assert_nil   State.find_by(code: 'KV')
    end
  end

  def setup_seed_dir(name, *files)
    dir_name = seed_dir_name(name)
    Dir.mkdir(dir_name)
    files.each do |file|
      FileUtils.cp(Rails.root.join('db', 'seed.test', file), dir_name)
    end
    return dir_name
  end

  def cleanup_seed_dir(name)
    FileUtils.rm_rf(seed_dir_name(name))
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
