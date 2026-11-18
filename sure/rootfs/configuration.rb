require 'json'
require 'securerandom'
require 'uri'
require 'fileutils'

module SureHA
  class ConfigError < StandardError; end
  SECRET_KEYS = %w[secret_key_base active_record_encryption_primary_key active_record_encryption_deterministic_key active_record_encryption_key_derivation_salt].freeze
  OPTIONAL = %w[smtp_address smtp_port smtp_username smtp_password smtp_tls_enabled email_sender openai_access_token openai_model openai_uri_base].freeze

  def self.environment(options, data)
    %w[db_host postgres_user postgres_db postgres_password redis_url].each do |key|
      raise ConfigError, "Set #{key} in app configuration" unless options[key].is_a?(String) && !options[key].empty?
    end
    raise ConfigError, 'Use a dedicated Sure database, never a Maybe database' if options['postgres_db'].downcase.include?('maybe')
    redis = URI.parse(options['redis_url'])
    raise ConfigError, 'redis_url must be a redis:// or rediss:// URL with an explicit database number' unless %w[redis rediss].include?(redis.scheme) && redis.host && redis.path.match?(%r{\A/\d+\z})
    threads = Integer(options.fetch('rails_max_threads', 3))
    ai = Integer(options.fetch('rails_ai_max_threads', 1))
    port = Integer(options.fetch('db_port', 5432))
    timeout = Integer(options.fetch('dependency_timeout', 180))
    raise ConfigError, 'Invalid thread counts, port or dependency timeout' unless (2..16).cover?(threads) && (1...threads).cover?(ai) && (1..65535).cover?(port) && (30..600).cover?(timeout)
    supplied = SECRET_KEYS.to_h { |key| [key, options[key].to_s] }
    encryption = SECRET_KEYS.drop(1)
    count = encryption.count { |key| !supplied[key].empty? }
    raise ConfigError, 'Provide all three encryption keys or none' unless [0, 3].include?(count)
    if !supplied['secret_key_base'].empty? && supplied['secret_key_base'].length < 64
      raise ConfigError, 'secret_key_base must contain at least 64 characters'
    end
    path = File.join(data, 'secrets.json')
    if File.exist?(path)
      secrets = JSON.parse(File.read(path))
      SECRET_KEYS.each do |key|
        raise ConfigError, 'Persistent secrets are incomplete; restore your backup' if secrets[key].to_s.empty?
        raise ConfigError, 'Changing established secrets is forbidden; restore the original configuration' if !supplied[key].empty? && supplied[key] != secrets[key]
      end
    else
      raise ConfigError, 'Secrets missing from initialized storage; restore your backup' if File.exist?(File.join(data, 'storage', '.ha-initialized'))
      secrets = supplied.transform_values { |value| value.empty? ? SecureRandom.hex(64) : value }
      File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0600) { |file| file.write(JSON.generate(secrets)); file.flush; file.fsync }
    end
    File.chmod(0600, path)
    env = {
      'DB_HOST' => options['db_host'], 'DB_PORT' => port.to_s,
      'POSTGRES_USER' => options['postgres_user'], 'POSTGRES_DB' => options['postgres_db'],
      'POSTGRES_PASSWORD' => options['postgres_password'], 'REDIS_URL' => options['redis_url'],
      'RAILS_MAX_THREADS' => threads.to_s, 'RAILS_AI_MAX_THREADS' => ai.to_s,
      'SELF_HOSTED' => 'true', 'RAILS_ENV' => 'production', 'WEB_CONCURRENCY' => '1',
      'BINDING' => '0.0.0.0', 'PORT' => '3000', 'RAILS_LOG_LEVEL' => 'info',
      # HTTP /up stays usable by HA. Proxy mode marks cookies and generated URLs HTTPS.
      'RAILS_FORCE_SSL' => 'false', 'RAILS_ASSUME_SSL' => options.fetch('https_proxy', false).to_s,
      'APP_DOMAIN' => options.fetch('app_domain', '').to_s
    }
    secrets.each { |key, value| env[key.upcase] = value }
    OPTIONAL.each { |key| env[key.upcase] = options[key].to_s if options.key?(key) && !options[key].to_s.empty? }
    env
  rescue URI::InvalidURIError, ArgumentError, TypeError
    raise ConfigError, 'Invalid configuration value'
  end
end
