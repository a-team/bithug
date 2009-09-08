module Project
  class Routes < Monk::Glue

    configure do
      Compass.configuration do |config|
        config.project_path = root_path
        config.sass_dir = root_path("views", "stylesheets")
        config.output_style = :compact
      end
    end
    
    helpers do
      def compass(file, options = {})
        options[:sass] ||= {}
        options[:sass].merge! Compass.sass_engine_options
        sass file, options
      end
    end

    get '/stylesheets/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      compass :"stylesheets/#{params[:name]}"
    end 

  end
end