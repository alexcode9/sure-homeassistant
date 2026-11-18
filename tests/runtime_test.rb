require 'minitest/autorun'
require 'tmpdir'
require 'rbconfig'
require_relative '../sure/rootfs/configuration'
require_relative '../sure/rootfs/supervisor'

class ConfigurationTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @options = {'db_host'=>'db', 'postgres_user'=>'sure', 'postgres_db'=>'sure_test', 'postgres_password'=>"x'\n$(touch /tmp/unsafe)", 'redis_url'=>'redis://:password@redis:6379/1'}
  end
  def teardown; FileUtils.remove_entry(@dir); end
  def test_secret_persistence_permissions_and_literal_password
    a = SureHA.environment(@options, @dir)
    b = SureHA.environment(@options, @dir)
    assert_equal a, b
    assert_equal @options['postgres_password'], a['POSTGRES_PASSWORD']
    assert_equal 0600, File.stat(File.join(@dir,'secrets.json')).mode & 0777
    assert_equal 128, a['SECRET_KEY_BASE'].size
    refute_equal a['SECRET_KEY_BASE'], a['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
  end
  def test_reject_secret_rotation
    SureHA.environment(@options, @dir)
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options.merge('secret_key_base'=>'a'*128), @dir) }
  end
  def test_missing_secret_on_initialized_storage_fails
    FileUtils.mkdir_p(File.join(@dir,'storage'))
    File.write(File.join(@dir,'storage','.ha-initialized'),'1')
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options, @dir) }
  end
  def test_partial_keys_and_invalid_threads
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options.merge('active_record_encryption_primary_key'=>'abc'), @dir) }
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options.merge('rails_ai_max_threads'=>3), @dir) }
  end
  def test_reject_legacy_database_and_bad_redis
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options.merge('postgres_db'=>'maybe_production'), @dir) }
    assert_raises(SureHA::ConfigError) { SureHA.environment(@options.merge('redis_url'=>'https://redis'), @dir) }
  end
  def test_no_arbitrary_environment_injection
    env = SureHA.environment(@options.merge('RUBYOPT'=>'malicious','database_url'=>'bad'), @dir)
    refute env.key?('RUBYOPT')
    refute env.key?('DATABASE_URL')
  end
end

class SupervisorTest < Minitest::Test
  def setup; @sup = SureHA::Supervisor.new(grace: 0.3); end
  def teardown; @sup.shutdown; end
  def test_child_failure_stops_sibling
    sibling = @sup.start('sibling', RbConfig.ruby, '-e', 'sleep 60')
    @sup.start('failure', RbConfig.ruby, '-e', 'exit 7')
    assert_equal 1, @sup.monitor
    @sup.shutdown
    assert_raises(Errno::ESRCH) { Process.kill(0, sibling) }
  end
  def test_migration_failure_and_timeout
    refute @sup.run_once('migration', 5, RbConfig.ruby, '-e', 'exit 1')
    refute @sup.run_once('timeout', 0.1, RbConfig.ruby, '-e', 'sleep 60')
  end
  def test_term_and_forced_shutdown
    pid = @sup.start('stubborn', RbConfig.ruby, '-e', 'trap("TERM") {}; sleep 60')
    sleep 0.2
    Process.kill('TERM', Process.pid)
    assert_equal 0, @sup.monitor
    @sup.shutdown
    assert_raises(Errno::ESRCH) { Process.kill(0, pid) }
  end
end
