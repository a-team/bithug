require "bithug"

module Bithug::Hpi
  module Repository
    include Bithug::ServiceHelper
    stack Bithug::Git::Repository, Bithug::Svn::Repository
  end

  module User
    include Bithug::ServiceHelper
    attribute :real_name
    attribute :email
    
    stack Bithug::Local::User

  end
end
