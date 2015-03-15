require 'data_seeder/config'
require 'data_seeder/engine'
require 'data_seeder/loader'
require 'data_seeder/logger'

module DataSeeder
  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
  end

  def self.configure
    yield(config)
  end

  def self.logger
    config.logger
  end

  def self.run(new_config={})
    msec = Benchmark.ms do
      new_config.each do |key, value|
        self.config.send("#{key}=", value)
      end
      Dir.chdir(config.seed_dir) do
        Dir['**/*'].each do |path|
          SeedFile.load(path) if File.file?(path)
        end
      end
    end
    logger.info { "DataSeeder.run took #{msec.to_i} msec" }
  end

  def self.test_run(new_config={})
    self.config.logger = Rails.logger
    run(new_config)
  end

  @@a_ord         = ?A.ord
  @@zero_ord      = ?0.ord
  @@numeric_range = (?0.ord)..(?9.ord)

  def self.to_id(len, str)
    id = 0
    str = str.upcase.gsub(/[^A-Z0-9]/, '')
    len.times do |i|
      char = str[i]
      if char
        ord = char.ord
        if @@numeric_range.include?(ord)
          id = id * 37 + ord - @@zero_ord
        else
          id = id * 37 + ord - @@a_ord + 10
        end
      else
        id = id * 37 + 36
      end
    end
    return id
  end
end
