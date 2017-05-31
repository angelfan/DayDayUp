## 设置密码
sudo -u postgres psql postgres

sudo apt-get update
sudo apt-get install curl git-core nginx -y

curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
rvm install 2.1.0
rvm use 2.1.0 --default
rvm rubygems current

gem install bundler

ssh-keygen -t rsa 

sudo apt-get install nodejs
sudo apt-get install postgresql postgresql-contrib libpq-dev


https://coderwall.com/p/ttrhow/deploying-rails-app-using-nginx-puma-and-capistrano-3