module DataSeeder
  class Config
    attr_accessor :seed_dir, :logger, :loaders

    def initialize
      @seed_dir = 'db/seed'
      @logger   = Logger.new
      @loaders  = default_loaders
    end

    def verbose=(verbose)
      @logger.verbose = verbose
    end

    def verbose
      @logger.verbose
    end

    def default_loaders
      {
        'json' => Loader::JSON.new,
        'yaml' => Loader::YAML.new,
        'yml'  => Loader::YAML.new,
        'txt'  => Loader::Txt.new,
      }
    end

    def loaders=(loaders)
      @loaders = @loaders.merge(loaders)
    end
  end
end
