# When git executes via ssh, it sets the environment
# variable SSH_ORIGINAL_COMMAND to:
#   git-upload-pack/git upload-pack for pull
#   git-receive-pack/git receive-pack for push
# So this is basically the git-user's shell on the server

require 'exceptions'
require 'fileutils'

class Shell
  @@read_command = Regexp.new "git[ |-]upload-pack"
  @@write_command = Regexp.new "git[ |-]receive-pack"

  def initialize(username) 
    @user = User.find(:name, username).first
    ENV["SSH_ORIGINAL_COMMAND"] =~ /(git[-| ]upload-pack) (.*)/
    @command = $1
    @repository = $2.delete("'") # Git quotes the path, so unquote that
    @writeaccess = ((@@write_command =~ @command) == 0)
  end

  def run
    unless repo = Repository.find(:name, @repository).first
      raise UnknownRepositoryError, "Could not find a repository named #{@repository}" 
    end
    repo.check_access_rights(@user, @writeaccess) 
    exec(@command, File.join(File.expand_path("~"), @repository))
  end
end

# Run with first argument as user name like this:
#   Shell.new(ARGV[0]).run
