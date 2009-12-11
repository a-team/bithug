require 'fileutils'
require 'user'
require 'ohm'
require 'ohm_ext'

class Repository < Ohm::Model
  attribute :name
  attribute :public
  attribute :owner
  attribute :vcs
  set :readaccess
  set :writeaccess

  index :name
  index :owner

  def validate
    assert_present :name
  end

  def username(user)
    if user.respond_to? :to_str 
      user
    else
      user.name
    end
  end

  def grant_readaccess(user)
    self.readaccess << username(user) unless username(user) == owner
  end
  
  def grant_writeaccess(user)
    grant_readaccess(user)
    self.writeaccess << username(user) unless username(user) == owner
  end

  def check_access_rights(user, writeaccess=false)
    user_name = username(user)
    unless self.owner == user_name
      unless self.readaccess.include?(user_name) || (self.public == true)
        raise ReadAccessDeniedError, "#{self.owner} User #{user_name} does not have read-access"
      else
        unless (self.writeaccess.include?(user_name) || !writeaccess)
          raise WriteAccessDeniedError, "User #{user_name} does not have write-access"
        end
      end
    end
  end

  def self.writeable_repos_for_user(user)
    self.all.select do |repo|
      repo.writeaccess.include?(user)
    end
  end

  def self.readable_repos_for_user(user)
    self.all.select do |repo|
      repo.readaccess.include?(user)
    end
  end

  def self.repo_path_for(hash)
    "#{File.expand_path("~")}/#{hash[:owner].name}/#{hash[:name]}"
  end

  def self.create_empty_repo(path)
    const_get(vcs.camelize).new(path).init
  end

  def self.import_repo(path, remote)
    const_get(vcs.camelize).new(path, remote).clone
  end

  def self.delete_repo(path)
    FileUtils.rm_rf(path)
  end

  def self.create(*args)
    hash = args.first
    create_empty_repo(repo_path_for(hash))
    repo = super(:name => "#{hash[:owner].name}/#{hash[:name]}", :owner => hash[:owner].name)
    repo.save
    repo
  end

  def self.delete
    delete_repo(repo_path_for(hash))
    super
  end
end
