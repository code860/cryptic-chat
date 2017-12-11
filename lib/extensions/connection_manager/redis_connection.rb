require 'connection_pool'
module ConnectionManager
  module RedisConnection
    class << self
      def redis_pool(&block)
        ConnectionBuilder.reset_config
        ConnectionBuilder.build &block
      end
    end

    class ConnectionBuilder
      class << self
        def build(&config_block)
          raise "Error no block given!" unless block_given?
          builder = self.new &config_block
          return builder.connection
        end

        def reset_config
          @config = nil
        end
      end
      attr_reader :config, :connection
      def initialize(&config_block)
        @config ||= RedisConfiguration.new &config_block
        @connection ||= RedisPool.new(@config.formatted_options)
      end
    end

    class RedisConfiguration
      RedisOptions = Struct.new(:host, :db, :namespace, :password)
      PoolOptions = Struct.new(:size, :timeout)

      def initialize(&config_block)
        raise "No Configuration block given!" unless block_given?
        config_block.call self
        @pool_options ||= PoolOptions.new(size: 10, timeout: 10)
        @redis_options ||= RedisOptions.new(host: "redis://localhost:6379", db: 2)
      end

      def formatted_options
        [{redis_options: @redis_options.to_h.delete_if{|k,v| v.blank?}},
         {pool_options: @pool_options.to_h.delete_if{|k,v| v.blank?}}].reduce(:merge)
      end

      def pool_options
        @pool_options = PoolOptions.new
        yield(@pool_options) if block_given?
      end

      def redis_options
        @redis_options = RedisOptions.new
        yield(@redis_options) if block_given?
      end
    end

    class RedisPool
      attr_reader :conn_pool
      def initialize(options = {})
        redis_options = options.delete(:redis_options) unless options[:redis_options].blank?
        pool_options = options.delete(:pool_options) unless options[:pool_options].blank?
        raise ArgumentError, "Error redis and pool options can not be blank!" if pool_options.blank? || redis_options.blank?
        if redis_options[:namespace].present?
          set_pool(pool_options, redis_namespaced_connection(redis_options[:namespace], redis_connection(redis_options.delete(:namespace))))
        else
          set_pool(pool_options, redis_connection(redis_options))
        end
      end

      def disconnect
        conn_pool.shutdown{|conn| conn.close}
      end
      private
      def redis_connection(opts)
        proc { Redis.new opts}
      end

      def redis_namespaced_connection(namespace, redis_conn)
        proc { Redis::Namespace.new(namespace.to_sym, :redis => redis_conn.call) }
      end

      def set_pool(pool_opts, redis_conn)
        @conn_pool ||= ConnectionPool.new(pool_opts, &redis_conn)
      end
    end
  end
end
