module ConnectionManager
  module KeyPassConnection
    attr_reader :key_pass_connection
    def key_pass_connection
      @key_pass_connection ||= ConnectionManager::RedisConnection.redis_pool &CONFIG_BLOCK
    end
    YAML_CONFIG = YAML.load(Rails.root.join("config", "redis.yml").read).fetch("#{Rails.env}_key_pass") { fail "No Redis Config found in config/redis.yml" }
    CONFIG_BLOCK = Proc.new{|config|
      config.redis_options do |redis_options|
        redis_options.host = YAML_CONFIG.fetch('host'){}
        redis_options.db = YAML_CONFIG.fetch('db'){}
        redis_options.namespace = YAML_CONFIG.fetch('namespace'){}
      end
    }
  end
end
