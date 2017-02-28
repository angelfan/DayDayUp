#!/usr/bin/env puma

environment 'production'
threads 2, 4
workers 4

app_name = "angelfan"
application_path = "/srv/www/#{app_name}"
directory "#{application_path}/current"

pidfile "#{application_path}/shared/tmp/pids/puma.pid"
state_path "#{application_path}/shared/tmp/sockets/puma.state"
stdout_redirect "#{application_path}/shared/log/puma.stdout.log", "#{application_path}/shared/log/puma.stderr.log"
activate_control_app "unix://#{application_path}/shared/tmp/sockets/pumactl.sock"
bind "unix://#{application_path}/shared/tmp/sockets/#{app_name}.sock"

daemonize true
on_restart do
  puts 'On restart...'
end


directory "/srv/www/baihu/current"

pidfile "/srv/www/baihu/shared/tmp/pids/puma.pid"
state_path "/srv/www/baihu/shared/tmp/sockets/puma.state"
stdout_redirect "/srv/www/baihu/shared/log/puma.stdout.log", "/srv/www/baihu/shared/log/puma.stderr.log", true
activate_control_app "unix:///srv/www/baihu/shared/tmp/sockets/pumactl.sock"
bind "unix:///srv/www/baihu/shared/tmp/sockets/puma.sock"



upstream myapp {
           server unix:///srv/www/baihu/shared/tmp/sockets/puma.sock;
         }

server {
  listen 80;
  server_name _;

  # ~2 seconds is often enough for most folks to parse HTML/CSS and
  # retrieve needed images/icons/frames, connections are cheap in
  # nginx so increasing this is generally safe...
  keepalive_timeout 5;

  # path for static files
  root /srv/www/baihu/current/public;
  access_log /var/log/nginx/baihu.commandp.com.cn.access.log;
  error_log /var/log/nginx/baihu.commandp.com.cn.error.log info;

  location /health_check {
      return 200 'gangnam style!';
  }
  location ^~ /sidekiq {
