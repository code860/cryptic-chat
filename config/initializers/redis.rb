Redis::Objects.redis = POOLED_CONNECTIONS.key_pass_connection.conn_pool if defined?(POOLED_CONNECTIONS)
