require "bithug"
require "thor"

class Bithug::Cli < Thor
  include Thor::Actions
  default_task :help
  class_option :ext,    :aliases => "-x", :desc => "Ruby extension library to use", :banner => "LIB"
  class_option :env,    :aliases => "-e", :desc => "Sets environment (you know, like in rails)", :default => "development"
  class_option :config, :aliases => "-c", :desc => "Config file to load", :banner => "FILE", :default => "config.rb"

  no_tasks do
    def setup_environment
      options.each { |k,v| send "setup_#{k}", v if respond_to? "setup_#{k}" }
    end

    def setup_ext(value)
      Monkey.backend = value
    end

    def setup_config(file)
      Bithug.config ||= Bithug::ConfigDsl.new options[:env]
      if File.exist? file
        Bithug.instance_eval File.read(file), file, 1
      elsif file == "config.rb" and File.exist? "config.example.rb"
        setup_config "config.example.rb"
      else
        puts "config file #{file} does not exist"
      end
    end

    def initialize(args=[], opts={}, config={})
      super
      setup_environment
    end
  end
end