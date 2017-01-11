require 'test_helper'

describe DataSeeder::Loader, :model do
  include SeedHelper

  describe 'allow a configurable logger' do
    before do
      @name      = 'test_loader_logger'
      @seed_dirs = setup_seed_dirs(@name, 'states_txt')
      @logfile   = Rails.root.join('tmp', "loader_test.log.#{$$}")
    end

    after do
      cleanup_seed_dir(@name)
      FileUtils.rm(@logfile)
    end

    it 'should load seed files' do
      loader = DataSeeder::Loader::Txt.new(logger: Logger.new(@logfile))
      loader.logger.info('hello foobar')
      buf = File.read(@logfile)
      assert buf.match(/hello foobar/)
    end
  end
end
