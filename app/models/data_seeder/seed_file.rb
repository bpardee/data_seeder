require 'digest'

module DataSeeder
  class SeedFile < ActiveRecord::Base
    def self.file_hash
      @path_hash ||= begin
        hash = {}
        all.each do |seed_file|
          hash[seed_file.path] = seed_file
        end
        hash
      end
    end

    def self.load(path)
      seed_file = self.file_hash[path] || new(path: path)
      seed_file.load
    end

    def load
      new_sha256 = Digest::SHA256.file(path).hexdigest
      if self.sha256 != new_sha256
        self.sha256 = new_sha256
        ext = File.extname(self.path)[1..-1]
        return unless ext
        loader = DataSeeder.config.loaders[ext]
        unless loader
          DataSeeder.logger.info { "Warning: No loader for #{path}"}
          return
        end
        loader.load(path)
        save!
      end
    end
  end
end
