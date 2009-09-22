# Setting up the path
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("lib", *Dir.glob(File.join(ROOT_DIR, "vendor", "*", "lib")))

require "monkey-lib"
require "compass"
require "sinatra/base"
require "haml"
require "sass"

module Bithug   
  class Routes < Sinatra::Base
    
    configure :development do
      require "bithug/reloader"
      use Reloader
    end
    
    def self.root_path(*args); File.join(ROOT_DIR, *args); end
    def self.root_glob(*args, &block); Dir.glob(root_path(*args), &block); end
    def self.route_files(&block); root_glob("routes", "**", "*.rb", &block); end
    def root_path(*args); self.class.root_path(*args); end
    def root_glob(*args, &block); self.class.root_glob(*args, &block); end
    
    set :app_file, __FILE__
    set :views, root_path("views")
    set :haml, :format => :html5, :escape_html => true
    
    use Rack::Session::Cookie
    enable :sessions
    
    require root_path("config", "settings")
    root_glob("{config,routes}", "**", "*.rb") { |f| require f }
    run! if __FILE__ == $0  
    
  end
end
