module ConnectionManager
  module SidekiqConnection
    attr_reader :sidekiq_connection_client, :sidekiq_connection_server
    def sidekiq_connection_client
      @sidekiq_connection_client ||= ConnectionManager::RedisConnection.redis_pool &CLIENT_CONFIG_BLOCK
    end
    def sidekiq_connection_server
      @sidekiq_connection_server ||= ConnectionManager::RedisConnection.redis_pool &SERVER_CONFIG_BLOCK
    end
    REDIS_YAML_CONFIG = YAML.load(Rails.root.join("config", "redis.yml").read).fetch("#{Rails.env}_sidekiq") { fail "No Redis Config found in config/redis.yml" }
    SIDEKIQ_YAML_CONFIG = YAML.load(Rails.root.join("config", "sidekiq.yml").read).fetch("#{Rails.env}") { fail "No Sidekiq Config found in config/sidekiq.yml" }
    CLIENT_CONFIG_BLOCK = Proc.new{|config|
      config.redis_options do |redis_options|
        redis_options.host = REDIS_YAML_CONFIG.fetch('host'){}
        redis_options.db = REDIS_YAML_CONFIG.fetch('db'){}
        redis_options.namespace = REDIS_YAML_CONFIG.fetch('namespace'){}
      end
      config.pool_options do |pool_options|
        pool_options.size = SIDEKIQ_YAML_CONFIG.fetch('concurrency'){5}
        pool_options.timeout = SIDEKIQ_YAML_CONFIG.fetch('concurrency'){5}
      end;config
    }
    SERVER_CONFIG_BLOCK = Proc.new{|config|
      config.redis_options do |redis_options|
        redis_options.host = REDIS_YAML_CONFIG.fetch('host'){}
        redis_options.db = REDIS_YAML_CONFIG.fetch('db'){}
        redis_options.namespace = REDIS_YAML_CONFIG.fetch('namespace'){}
      end
      config.pool_options do |pool_options|
        pool_options.size = Integer(SIDEKIQ_YAML_CONFIG.fetch('concurrency'){5} + 2)
        pool_options.timeout = Integer(SIDEKIQ_YAML_CONFIG.fetch('concurrency'){5} + 2)
      end;config
    }
  end
end
