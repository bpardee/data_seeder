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
      if self.sha256 != new_sha256
        ext = File.extname(self.path)[1..-1]
        return true unless ext
        loader = DataSeeder.config.loaders[ext]
        unless loader
          DataSeeder.logger.info { "Warning: No loader for #{path}"}
          return true
        end
        return false unless loader.process(path)
        self.sha256 = new_sha256
        save!
      end
      self.class.add_processed(path)
      return true
    end
  end
end
