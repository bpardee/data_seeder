require 'data_seeder/config'
require 'data_seeder/engine'
require 'data_seeder/loader'

module DataSeeder
  class << self
    attr_writer :config
  end

  @@mutex = Mutex.new

  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
  end

  def self.configure
    yield(config)
  end

  def self.run(new_config={})
    @@mutex.synchronize do
      msec = Benchmark.ms do
        new_config.each do |key, value|
          self.config.send("#{key}=", value)
        end
        # Keep track of the seed files that have dependencies that aren't fulfilled
        pending = []
        config.seed_dirs.each do |seed_dir|
          Dir.chdir(seed_dir) do
            Dir['**/*'].each do |path|
              next if path.end_with?('.cfg')
              if File.file?(path)
                unless SeedFile.load(path)
                  pending << [seed_dir, path]
                end
              end
            end
          end
        end
        # Loop thru the ones that couldn't be processed previously because they depended on another seed being loaded first
        until pending.empty?
          new_pending = []
          pending.each do |seed_dir, path|
            Dir.chdir(seed_dir) do
              unless SeedFile.load(path)
                new_pending << [seed_dir, path]
              end
            end
          end
          if pending.size == new_pending.size
            msg = "Error: Circular dependency in DataSeeder, seeds=#{pending.inspect}"
            config.logger.error msg
            raise msg
          end
          pending = new_pending
        end
      end
      config.logger.info "DataSeeder.run took #{msec.to_i} msec"
    end
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
