unless RUBY_ENGINE == "maglev"
  source :rubygems
  gem "timfel-krb5-auth", :require => 'krb5_auth'
  gem "ohm"
else
  source :rubygems
  gem "json_pure"
  gem "maglev-webtools", :git => "https://github.com/MagLev/webtools.git"
end

gem "net-ssh", "~> 2.2"
gem "bcrypt-ruby"

gem "big_band", :git => "https://github.com/rkh/big_band.git"
gem "monkey-lib", :git => "https://github.com/rkh/monkey-lib.git", :require => false

gem "chronic_duration"
gem "compass"
gem "extlib"
gem "haml"
gem "mime-types"
gem "oauth"
gem "sinatra", "~> 1.2.0"
gem "rack-contrib"
gem "ruby-hmac"
gem "twitter_oauth"
gem "yard"

group :test do
  gem "rspec"
end

platforms :jruby do
  gem "jruby-openssl"
end
