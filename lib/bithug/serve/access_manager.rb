module Bithug
  module Serve
    class AccessManager
      require 'fileutils'
      KEYS_FILE = "#{ENV["HOME"]}/.ssh/authorized_keys"

      def initialize(user)
        @user = User.find(:name, user).first
      end

      def add_key(key)
        @user.keys << key

        default_options='command="bithug-serve USER",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty '
        File.open(KEYS_FILE, 'a+') do |f|
          f << default_options.gsub("USER", @user.name) << key << "\n"
        end
      end

      def add_key(key, name)
        key.name = name
        @user.keys << key

        default_options='command="bithug-serve USER",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty '
        File.open(KEYS_FILE, 'a+') do |f|
          f << default_options.gsub("USER", @user.name) << key << "\n"
        end
      end

      def remove_key(key)
        # BUG: SANITIZE USERNAME FOR REGEX!
        @user.keys.remove(key)

        File.open(KEYS_FILE+Time.now.to_i.to_s, 'w') do |out|
          File.open(KEYS_FILE, 'r+') do |infile|
            line = infile.readline
            unless line == "environment=\"GITUSER=#{@user.name}\" #{key}"
              out << line
            end
          end
        end

        # BUG: LOCKING HAS TO BE PLACED HERE, OR CHECK IF THE TSTAMP
        # OF THE OLD FILE CHANGED
        FileUtils.mv(KEYS_FILE+Time.now.to_i.to_s, KEYS_FILE)
      end

      def add_repository(project_name)
        repo = Repository.create(:name => project_name, :owner => @user)    
      end

      def remove_repository(project_name)
        unless repo = Repository.find(:name, project_name)
          raise UnknownRepositoryError, "Could not find repository #{project_name}" 
        end
        unless repo.owners.include?(@user) 
          raise AdminAccessDeniedError
        end
        repo.delete 
      end
    end
  end
end
