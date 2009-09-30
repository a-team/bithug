require "fileutils"
require "yaml"

module Bithug
  class Routes < Sinatra::Base
  
    def self.config_path(*args)
      root_path("config", *args)
    end
    
    configure :development, :production do
      set :settings_file, config_path("settings.yml")
    end
    
    configure :test do
      set :settings_file, root_path("spec", "settings.yml")
    end
    
    def self.settings(*args)
      @settings ||= begin
        FileUtils.cp config_path("settings.example.yml"), settings_file unless File.exist? settings_file
        YAML.load_file settings_file
      end
      args.inject(@settings) { |s,a| s[a.to_s] }
    end

    helpers do
      def settings(*args)
        Bithug::Routes.settings(*args)
      end
    end

  end
end