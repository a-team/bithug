module Bithug

  # We use the Repository class in the 
  # logging infos, so we will need it here 
  class Repository < Ohm::Model
  end

  module AbstractRepository
    include ServiceHelper
  
    attribute :name
    attribute :public
    attribute :vcs
    attribute :remote
    set :owners, Bithug::User
    set :readers, Bithug::User
    set :writers, Bithug::User

    set :commits, Bithug::LogInfo::CommitInfo
    set :forks, Bithug::LogInfo::ForkInfo
    set :rights, Bithug::LogInfo::RightsInfo

    index :name
    index :owners
    
    # Ohm only provides class matching for sets. Owner should be 
    # only one, anyhow, so provide accessors...  
    def owner=(user)
      owners.clear
      owners.add(user)
    end

    def public?
      self.public == "true"
    end
    
    def owner
      owners.first
    end

    def validate
      assert_present :name
      assert_present :vcs
    end
    
    def create_repository
      raise ConfigurationError, "#{vcs.to_s} is an unhandled VCS"
    end

    def remove_repository
      raise ConfigurationError, "#{vcs.to_s} is an unhandled VCS"
    end

    def fork(new_owner)
      name_without_owner = name.gsub(owner.name,"").gsub("/","")
      new_repo = self.class.create(:vcs => vcs, :name => name_without_owner, 
                                   :owner => new_owner, :remote => absolute_path)
      Bithug::LogInfo::ForkInfo.create.tap do |f|
        f.original = self
        f.fork = new_repo
        f.user = new_owner
      end.save
      new_repo
    end

    def tree(path_options={})
      # Empty per default. Takes a hash for max 
      # flexibility in underlying wrappers
      {} 
    end

    def log_access(user)
      Bithug::LogInfo::RightsInfo.create.tap do |f|
        f.changed_user = user
        f.admin = owner
        f.repository = self
      end.save
    end    
    
    def grant_access(options)
      readers.add(options[:user])
      writers.add(options[:user]) if "#{options[:access]}" == 'w'
    end

    def revoke_access(options)
      writers.delete(options[:user])
      readers.delete(options[:user]) if "#{options[:access]}" == 'r'
    end
    
    # This is used by the shell
    def check_access_rights(user, writeaccess=false)
      unless self.owner == user
        unless self.readers.include?(user) || self.public?
          raise ReadAccessDeniedError, 
              "#{self.name}: User #{user.name} does not have read-access"
        else
          unless (self.writers.include?(user) || !writeaccess)
            raise WriteAccessDeniedError, 
                "#{self.name}: User #{user.name} does not have write-access"
          end
        end
      end
    end
    
    def log_recent_activity(user=nil)
      # Do nothing here, logging actions must be done
      # by the wrappers
    end

    class_methods do
      # This is overwritten to immediately create the underlying repo using the 
      # configured method, and also modify the name for uniqueness in the system 
      def create(options = {})
        owner = options.delete(:owner)
        raise(RuntimeError, "There can be no repository without an owner") if owner.nil?
        options[:name] = owner.name / options[:name]
        super.tap do |repo|
          repo.create_repository
          repo.owner = owner
          repo.save
          owner.repositories.add(repo)
          owner.save
        end
      end

      # This is overwritten to actually remove the repository from storage or 
      # whatever is configured on delete
      def delete
        remove_repository
        super
      end
    end
  end

  class Repository < Ohm::Model
    include AbstractRepository unless ancestors.include? AbstractRepository
  end

end
