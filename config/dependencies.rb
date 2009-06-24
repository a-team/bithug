require 'pathname'

module Bithug
  ROOT = Pathname(__FILE__).dirname.join('..').expand_path
  $LOAD_PATH.unshift ROOT.join("lib").to_s, *Dir.glob(ROOT.join("vendor/**/lib").to_s)
end 

require "pp"
pp $LOAD_PATH

%w[                      
  dm-core dm-aggregates dm-migrations dm-timestamps dm-types dm-validations dm-serializer 
  data_objects do_sqlite3
  grit erubis haml
  bithug
].each { |lib| require lib }

DataMapper.setup :default, "sqlite3:///#{Bithug::ROOT}/#{Bithug.environment}.db" 