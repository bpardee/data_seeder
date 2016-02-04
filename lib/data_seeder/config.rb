module DataSeeder
  class Config
    attr_accessor :seed_dirs, :logger, :loaders

    def initialize
      @seed_dirs  = ['db/seed'].freeze
      @logger     = Logger.new
      @loaders    = default_loaders
      @is_default = true
    end

    def verbose=(verbose)
      @logger.verbose = verbose
    end

    def verbose
      @logger.verbose
    end

    def default_loaders
      {
        'csv'  => Loader::CSV.new,
        'json' => Loader::JSON.new,
        'txt'  => Loader::Txt.new,
        'yaml' => Loader::YAML.new,
        'yml'  => Loader::YAML.new,
      }
    end

    def loaders=(loaders)
      @loaders = default_loaders.merge(loaders)
    end

    def add_loaders(loaders)
      @loaders = @loaders.merge(loaders)
    end

    def add_loader(ext, loader)
      @loaders[ext] = loader
    end

    def seed_dir=(seed_dir)
      @seed_dirs = [seed_dir]
    end

    def seed_dir
      @seed_dirs.first
    end

    def add_seed_dir(seed_dir)
      if @seed_dirs.frozen?
        @seed_dirs = [seed_dir]
      else
        @seed_dirs << seed_dir
      end
    end
  end
end
