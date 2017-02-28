require 'mina/rails'
require 'mina/git'
require 'mina/bundler'

# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

#服务器地址,是使用ssh的方式登录服务器
set :domain, 'deploy@139.162.117.170'
#服务器中项目部署位置
set :deploy_to, '/srv/www/angelfan'
#git代码仓库
set :repository, 'git@github.com:angelfan/angelfan.git'
set :rails_env, 'production'
set :branch,             -> { ENV.fetch('BRANCH', 'master') }

shared_dirs = %w(log
                 public/uploads
                 tmp/pids
                 tmp/sockets)

set :shared_dirs, fetch(:shared_dirs, []).push(*shared_dirs)

shared_files = %w(config/database.yml config/secrets.yml)

set :shared_files, fetch(:shared_files, []).push(*shared_files)

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
# 这个块里面的代码表示运行 mina setup时运行的命令
task :environment do
  ruby_version = File.read('.ruby-version').strip
  raise "Couldn't determine Ruby version: Do you have a file .ruby-version in your project root?" if ruby_version.empty?
  command %{
    source /home/deploy/.rvm/bin/rvm
    rvm use #{ruby_version} || exit 1
  }
end

deploy_to = '/srv/www/angelfan'
task :setup => :environment do
  shared_path = 'shared'

  # 在服务器项目目录的shared中创建log文件夹
  command %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  command %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  # 在服务器项目目录的shared中创建config文件夹 下同
  command %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  command %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  command %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  command %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]

  # puma.rb 配置puma必须得文件夹及文件
  command %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  command %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  command %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  command %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  command %[touch "#{deploy_to}/shared/config/puma.rb"]
  command  %[echo "-----> Be sure to edit 'shared/config/puma.rb'."]

  # tmp/sockets/puma.state
  command %[touch "#{deploy_to}/shared/tmp/sockets/puma.state"]
  command  %[echo "-----> Be sure to edit 'shared/tmp/sockets/puma.state'."]

  # log/puma.stdout.log
  command %[touch "#{deploy_to}/shared/log/puma.stdout.log"]
  command  %[echo "-----> Be sure to edit 'shared/log/puma.stdout.log'."]

  # log/puma.stdout.log
  command %[touch "#{deploy_to}/shared/log/puma.stderr.log"]
  command  %[echo "-----> Be sure to edit 'shared/log/puma.stderr.log'."]

  command  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]
end


desc "Deploys the current version to the server."
task :deploy => :environment do
  on :before do
    command "rvm rvmrc load"
  end

  "rvm rvmrc load"
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'
    on :launch do
      command "mkdir -p #{deploy_to}/current/tmp/"
      command "touch #{deploy_to}/current/tmp/restart.txt"
    end
  end
end

# task :deploy do
#   # uncomment this line to make sure you pushed your local branch to the remote origin
#   # invoke :'git:ensure_pushed'
#   deploy do
#     # Put things that will set up an empty directory into a fully set-up
#     # instance of your project.
#     invoke :'git:clone'
#     invoke :'deploy:link_shared_paths'
#     invoke :'bundle:install'
#     invoke :'rails:db_migrate'
#     invoke :'rails:assets_precompile'
#     invoke :'deploy:cleanup'
#
#     on :launch do
#       in_path(fetch(:current_path)) do
#         command %{mkdir -p tmp/}
#         command %{touch tmp/restart.txt}
#       end
#     end
#   end
#
#   # you can use `run :local` to run tasks on local machine before of after the deploy scripts
#   # run(:local){ say 'done' }
# end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
