module DataSeeder
  class Config
    attr_accessor :seed_dirs, :verbose
    attr_reader :loaders
    attr_writer :logger

    def initialize
      @seed_dirs        = ['db/seed'].freeze
      @loaders          = default_loaders
      @verbose          = true
      @is_default       = true
      @indent_level     = 0
      @indent           = ''
    end

    def logger
      @logger ||= begin
        logger = Logger.new($stdout)
        logger.formatter = ->(severity, datetime, progname, msg) { "#{@indent}#{msg}\n" }
        logger
      end
    end

    def default_loaders
      {
        'csv'  => Loader::CSV,
        'json' => Loader::JSON,
        'txt'  => Loader::Txt,
        'yaml' => Loader::YAML,
        'yml'  => Loader::YAML,
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

    def log_indent(&block)
      @indent_level += 1
      @indent = '  ' * @indent_level
      yield
    ensure
      @indent_level -= 1
      @indent = '  ' * @indent_level
    end
  end
end
