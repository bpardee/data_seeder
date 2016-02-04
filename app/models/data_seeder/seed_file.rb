require 'digest'

module DataSeeder
  class SeedFile < ActiveRecord::Base
    def self.file_hash
      @file_hash ||= begin
        hash = Hash.new { |hash, path| hash[path] = new(path: path) }
        all.each do |seed_file|
          hash[seed_file.path] = seed_file
        end
        hash
      end
    end

    def self.load(path)
      seed_file = self.file_hash[path]
      return seed_file.load
    end

    def self.processed_set
      @processed_set ||= Set.new
    end

    def self.add_processed(path)
      self.processed_set.add(path)
    end

    def self.processed?(paths)
      self.processed_set.proper_superset?(Array(paths).to_set)
    end

    def load
      new_sha256 = Digest::SHA256.file(path).hexdigest
      dot_index      = path.rindex('.')
      path_minus_ext = path[0, dot_index]
      if self.sha256 != new_sha256
        cfg_file       = "#{path_minus_ext}.cfg"
        config         = {}
        if File.exist?(cfg_file)
          config = eval(File.read(cfg_file))
        end
        begin
          config[:klass] ||= path_minus_ext.classify.constantize
        rescue NameError => e
        end
        ext = File.extname(self.path)[1..-1]
        return true unless ext
        loader_klass = config[:loader] || DataSeeder.config.loaders[ext]
        unless loader_klass
          DataSeeder.logger.warn { "Warning: No loader for #{path}"}
          return true
        end
        config[:path]           = path
        config[:path_minus_ext] = path_minus_ext
        loader                  = loader_klass.new(config)
        depends                 = loader.config[:depends]
        return false if depends && !self.class.processed?(depends)
        DataSeeder.logger.info "Loading #{path}"
        File.open(path, 'r') do |io|
          loader.process(io)
        end
        self.sha256 = new_sha256
        save!
      end
      self.class.add_processed(path_minus_ext)
      return true
    end
  end
end
