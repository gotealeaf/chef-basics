execute "apt-get update" do
  command "apt-get update"
end

# OS Dendencies
%w(git ruby-dev build-essential libsqlite3-dev libssl-dev).each do |pkg|
  package pkg
end

# Deployer user
user_account 'deployer' do
  create_group true
end
cookbook_file "id_rsa" do
  source "id_rsa"
  path "/home/deployer/.ssh/id_rsa"
  group "deployer"
  owner "deployer"
  mode 0600
  action :create_if_missing
end
cookbook_file "id_rsa.pub" do
  source "id_rsa.pub"
  path "/home/deployer/.ssh/id_rsa.pub"
  group "deployer"
  owner "deployer"
  mode 0644
  action :create_if_missing
end
ssh_known_hosts_entry 'github.com'

# Ruby Version
include_recipe 'ruby_build'

ruby_build_ruby '2.1.2'

link "/usr/bin/ruby" do
  to "/usr/local/ruby/2.1.2/bin/ruby"
end

gem_package 'bundler' do
  options '--no-ri --no-rdoc'
end

# Rails Application
include_recipe "runit"
application 'capistrano-first-steps' do
  owner 'deployer'
  group 'deployer'
  path '/var/www/capistrano-first-steps'
  repository 'git@github.com:jlebrijo/capistrano-first-steps.git'
  rails do
    bundler true
    database do
      adapter "sqlite3"
      database "db/production.sqlite3"
    end
  end
  unicorn do
    worker_processes 2
  end
end
