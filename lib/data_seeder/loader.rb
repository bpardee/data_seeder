require 'English'

module DataSeeder
  module Loader
    attr_reader :seeder_config, :config, :key_attribute, :klass, :path, :path_minus_ext

    def initialize(config)
      @seeder_config  = DataSeeder.config
      @config         = config
      @key_attribute  = config[:key_attribute] || :id
      @klass          = config[:klass]
      @path           = config[:path]
      @path_minus_ext = config[:path_minus_ext]
      # Default purge to true if unspecified
      @config[:purge] = true unless config.has_key?(:purge)
      @old_ids        = Set.new
    end

    def logger
      @seeder_config.logger
    end

    def process(io)
      setup
      load(io)
      teardown
    end

    def setup
      @old_ids = klass.all.pluck(:id).to_set if config[:purge]
      call_method(:setup)
    end

    def teardown
      call_method(:teardown)
      destroy_models(klass, @old_ids)
    end

    def destroy_models(klass, ids)
      ids.each do |id|
        if model = klass.find_by(id: id)
          destroy_model(model)
        end
      end
    end

    # The information displayed when creating, updating, or destroying a model.
    # The changes argument will be the model.changes on an update.
    def model_info(model, changes=nil)
      if changes
        if attr = config[:update_display_method]
          "#{model.send(attr)}: #{changes.inspect}"
        elsif @key_attribute.kind_of?(Enumerable)
          label = @key_attribute.map {|k| "#{k}=#{model.send(k)}"}.join(' ')
          "#{label}: #{changes.inspect}"
        else
          "#{model.send(@key_attribute)}: #{changes.inspect}"
        end
      else
        model.inspect
      end
    end

    def load(io)
      throw 'Must override load'
    end

    # This doesn't work in some versions of JRuby (version 9.0.3.0?)
    def line_number
      $INPUT_LINE_NUMBER
    end

    def save(attr)
      attr = call_method(:postprocess, attr) || attr
      if config[:use_line_number_as_id]
        find_hash = { @key_attribute => self.line_number }
      elsif @key_attribute.kind_of?(Enumerable)
        find_hash = {}
        @key_attribute.each do |k|
          find_hash[k] = attr[k.to_s] || attr[k.to_sym]
        end
      else
        key = attr[@key_attribute.to_s] || attr[@key_attribute.to_sym]
        raise "No #{@key_attribute} in #{attr.inspect}" unless key
        find_hash = { @key_attribute => key }
      end
      model = self.klass.find_or_initialize_by(find_hash)
      model.attributes = attr
      save_model(model)
    end

    def save_model(model)
      if model.new_record?
        log_save(model)
      else
        @old_ids.delete(model.id)
        return unless model.changed?
        log_update(model)
      end
      model.save!
    end

    # Allow override for potential soft-delete
    def destroy_model(model)
      log_destroy(model)
      model.destroy
    end

    def log_save(model)
      logger.debug { "Saving #{model_info(model)}" }
    end

    def log_update(model)
      logger.debug { "Updating #{model_info(model, model.changes)}" }
    end

    def log_destroy(model)
      logger.debug { "Destroying #{model_info(model)}" }
    end

    def log_indent(&block)
      @seeder_config.log_indent(&block)
    end

    def call_method(name, *args)
      if ![:setup,:teardown].include?(name) && self.respond_to?(name)
        return send(name, *args)
      elsif val = config[name]
        if val.kind_of?(Proc)
          return val.call(*args)
        else
          return val
        end
      else
        if @klass
          class_method = "data_seeder_#{name}"
          return @klass.send(class_method, *args) if @klass.respond_to?(class_method)
        end
      end
      return nil
    end
  end
end

require 'data_seeder/loader/csv'
require 'data_seeder/loader/json'
require 'data_seeder/loader/yaml'
require 'data_seeder/loader/txt'
