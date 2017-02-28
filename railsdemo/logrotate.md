/etc/logrotate.d/rails_log.conf 
rails_log.conf
/var/www/app/current/log/*.log {
    daily
    size=200M
    rotate 10
    compress
    nodelaycompress
    missingok
    notifempty
    su deploy deploy
    create 664 deploy deploy
    copytruncate
}

$ logrotate -f /etc/logrotate.conf


"/srv/www/commandp_service/shared/log/*.log" {
  daily
  create 644 deploy www-data
  rotate 14
  su deploy www-data
  sharedscripts
  compress
  missingok
  delaycompress
  notifempty
  postrotate
          /bin/kill -USR1 `cat /srv/www/commandp_service/shared/pids/unicorn.pid`
      cat /srv/www/commandp_service/shared/pids/sidekiq[0-9]* | xargs kill -USR2

  endscript
}