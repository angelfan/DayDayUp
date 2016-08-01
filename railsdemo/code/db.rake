# lib/tasks/db.rake
namespace :db do
  DUMP_FMT = 'p' # 'c', 'p', 't', 'd'

  desc 'Dumps the database to backups'
  task sql_dump: :environment do
    dump_sfx = suffix_for_format(DUMP_FMT)
    backup_dir = backup_directory(true)
    cmd = nil
    with_config do |app, host, db, user|
      file_name = Time.now.strftime("%Y%m%d%H%M%S") + "_" + db + '.' + dump_sfx
      cmd = "pg_dump -F #{DUMP_FMT} -U #{user} -v --no-owner -h #{host} -d #{db} -f #{backup_dir}/#{file_name}"
    end
    puts cmd
    exec cmd
  end

  desc 'Dumps a specific table to backups'
  task sql_dump_table: :environment do |_task, args|
    table_name = ENV['table']
    fail ArgumentError unless table_name
    dump_sfx = suffix_for_format(DUMP_FMT)
    backup_dir = backup_directory(true)
    cmd = nil
    with_config do |app, host, db, user|
      file_name = Time.now.strftime("%Y%m%d%H%M%S") + "_" + db + "_#{table_name.parameterize.underscore}" + '.' + dump_sfx
      cmd = "pg_dump --table #{table_name} --no-owner -F #{DUMP_FMT} -U #{user} -v -h #{host} -d #{db} -f #{backup_dir}/#{file_name}"
    end
    puts cmd
    exec cmd
  end

  desc 'Show the existing database backups'
  task list_backups: :environment do
    backup_dir = backup_directory
    puts "#{backup_dir}"
    exec "/bin/ls -lt #{backup_dir}"
  end

  desc 'Restores the database from a backup using PATTERN'
  task :sql_restore, [:pat] => :environment do |task,args|
    if args.pat.present?
      cmd = nil
      with_config do |app, host, db, user|
        backup_dir = backup_directory
        files = Dir.glob("#{backup_dir}/*#{args.pat}*")
        case files.size
          when 0
            puts "No backups found for the pattern '#{args.pat}'"
          when 1
            file = files.first
            fmt = format_for_file file
            if fmt.nil?
              puts "No recognized dump file suffix: #{file}"
            else
              cmd = "pg_restore -F #{fmt} -v -c -C #{file}"
            end
          else
            puts "Too many files match the pattern '#{args.pat}':"
            puts ' ' + files.join("\n ")
            puts "Try a more specific pattern"
        end
      end
      unless cmd.nil?
        Rake::Task["db:drop"].invoke
        Rake::Task["db:create"].invoke
        puts cmd
        exec cmd
      end
    else
      puts 'Please pass a pattern to the task'
    end
  end

  private

  def suffix_for_format suffix
    case suffix
      when 'c' then 'dump'
      when 'p' then 'sql'
      when 't' then 'tar'
      when 'd' then 'dir'
      else nil
    end
  end

  def format_for_file file
    case file
      when /\.dump$/ then 'c'
      when /\.sql$/  then 'p'
      when /\.dir$/  then 'd'
      when /\.tar$/  then 't'
      else nil
    end
  end

  def backup_directory(create=false)
    backup_dir = "#{Rails.root}/db/backups"
    if create and not Dir.exists?(backup_dir)
      puts "Creating #{backup_dir} .."
      Dir.mkdir(backup_dir)
    end
    backup_dir
  end

  def with_config
    yield Rails.application.class.parent_name.underscore,
        ActiveRecord::Base.connection_config[:host],
        ActiveRecord::Base.connection_config[:database],
        ActiveRecord::Base.connection_config[:username]
  end
end

=begin
  # dump the development db
  # rake db:dump

  # dump the production db
  # RAILS_ENV=production rake db:dump

  # dump the production db & restore it to the development db
  # RAILS_ENV=production rake db:dump
  # rake db:restore

  # note: config/database.yml is used for database configuration,
  #       but you will be prompted for the database user's password

  # dump the development db
  rake db:sql_dump

  # dump a given table from the dev db
  rake db:sql_dump_table table=users

  # dump the production db
  RAILS_ENV=production rake db:sql_dump

  # dump the production db & restore it to the development db
  RAILS_ENV=production rake db:sql_dump
  rake db:sql_restore

  # note: config/database.yml is used for database configuration,
  #       but you will be prompted for the database user's password
=end