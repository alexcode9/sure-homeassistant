require_relative 'configuration'
require_relative 'supervisor'
require 'etc'
require 'pg'
require 'redis'

$stdout.sync = true
$stderr.sync = true
File.umask(0077)
supervisor = SureHA::Supervisor.new
status = 1
begin
  data = '/data'
  options = JSON.parse(File.read(File.join(data, 'options.json')))
  env = SureHA.environment(options, data)
  FileUtils.mkdir_p(File.join(data, 'storage'), mode: 0700)
  File.write(File.join(data, 'storage', '.ha-initialized'), '1')
  if Process.uid.zero?
    rails = Etc.getpwnam('rails')
    # Do not follow symlinks while fixing restored ownership.
    FileUtils.chown_R(rails.uid, rails.gid, File.join(data, 'storage'))
    File.chown(rails.uid, rails.gid, File.join(data, 'secrets.json'))
    File.chmod(0711, data)
    Process.initgroups(rails.name, rails.gid)
    Process::GID.change_privilege(rails.gid)
    Process::UID.change_privilege(rails.uid)
  end
  # Do not pass Supervisor API tokens or inherited DB overrides to Rails.
  %w[SUPERVISOR_TOKEN HASSIO_TOKEN DATABASE_URL SECRET_KEY_BASE_DUMMY RAILS_MASTER_KEY].each { |key| ENV.delete(key) }
  ENV.update(env)
  jemalloc = Dir['/usr/lib/*-linux-gnu/libjemalloc.so.2'].first
  ENV['LD_PRELOAD'] = jemalloc if jemalloc
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + options.fetch('dependency_timeout', 180).to_i
  ready = false
  until supervisor.stopping?
    begin
      PG.connect(host: ENV['DB_HOST'], port: ENV['DB_PORT'], user: ENV['POSTGRES_USER'], password: ENV['POSTGRES_PASSWORD'], dbname: ENV['POSTGRES_DB'], connect_timeout: 5) { |db| db.exec('SELECT 1') }
      redis = Redis.new(url: ENV['REDIS_URL'], connect_timeout: 5, read_timeout: 5, write_timeout: 5)
      redis.ping
      ready = true
      break
    rescue StandardError
      # Never print exceptions containing connection URLs or passwords.
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
      puts 'sure-ha: waiting for authenticated PostgreSQL and Redis connections'
      sleep 2
    ensure
      redis.close if redis
    end
  end
  if ready && !supervisor.stopping?
    puts 'sure-ha: preparing dedicated Sure database'
    if supervisor.run_once('migration', 600, './bin/rails', 'db:prepare')
      puts 'sure-ha: starting Puma and Sidekiq as unprivileged user'
      supervisor.start('puma', './bin/rails', 'server', '-b', '0.0.0.0', '-p', '3000')
      supervisor.start('sidekiq', 'bundle', 'exec', 'sidekiq', '-t', '55')
      status = supervisor.monitor
    else
      warn 'sure-ha: database preparation failed or was interrupted'
    end
  else
    warn 'sure-ha: dependencies unavailable or shutdown requested'
  end
rescue SureHA::ConfigError => e
  warn "sure-ha: #{e.message}"
rescue StandardError
  warn 'sure-ha: startup failed; check options and persistent files (details suppressed to protect secrets)'
ensure
  supervisor.shutdown
end
exit status
