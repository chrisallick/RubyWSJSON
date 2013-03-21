set :application, "touch"

set :scm, :git
set :repository, "git@github.com:GSPBetaGroup/RubyWSServer.git"
set :scm_passphrase, ""

set :user, "ubuntu"

server "54.245.111.204", :app, :primary => true
set :deploy_to, "/home/ubuntu/RubyWSServer"

set :normalize_asset_timestamps, false