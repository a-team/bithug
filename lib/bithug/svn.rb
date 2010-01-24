# This module wraps tracking remote SVN repositories
# On inclusion into another module/class this is put
# in-between (if I understand the semantics correctly)
# thus, Ohm::Model methods will be available on inclusion 
# and this repo type can add an attribute to the model
module Bithug::Svn
  module Repository
    include ServiceHelper

    attribute :remote

    def create_repository
      super if vcs.to_s != "svn"
      svn = Bithug::GitSvn.new(absolute_path, remote)
      svn.init
    end

    def remove_repository
      super if vcs.to_s != "svn"
      svn = Bithug::GitSvn.new(absolute_path, remote)
      svn.remove
    end

    def absolute_path
      "#{Pathname.expand_path("~")}/#{name}"
    end
  end
end
