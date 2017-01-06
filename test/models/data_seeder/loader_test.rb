require 'test_helper'

describe DataSeeder::Loader, :model do
  include SeedHelper

  describe 'allow a configurable logger' do
    before do
      @name      = 'test_loader_logger'
      @seed_dirs = setup_seed_dirs(@name, 'states_txt')
    end

    after do
      cleanup_seed_dir(@name)
    end

    it 'should load seed files' do
      logfile = Rails.root.join('tmp', "loader_test.log.#{$$}")
      loader = DataSeeder::Loader::Txt.new(logger: Logger.new(logfile))
      loader.logger.info('hello foobar')
      buf = File.read(logfile)
      assert buf.match(/hello foobar/)
    end
  end
end
